
'use strict';

const crypto = require('node:crypto');
const { getAdminFirestore } = require('./firebase_admin');
const { QUOTA } = require('./quota_rules');

const COLLECTION = 'ai_quotas';
const MIGRATION_VERSION = 1;

// Gemini timeout is 45 seconds.
// Lease allows additional time for Firestore operations.
const PROCESSING_LEASE_MS = 5 * 60 * 1000;
const RECOVERY_AFTER_MS = 15 * 60 * 1000;

function requireUid(uid) {
  if (
    typeof uid !== 'string' ||
    !/^[A-Za-z0-9_-]{1,128}$/.test(uid)
  ) {
    throw new Error('Invalid Firebase user ID');
  }
  return uid;
}

function requireRequestId(requestId) {
  if (
    typeof requestId !== 'string' ||
    !/^[A-Za-z0-9_-]{8,128}$/.test(requestId)
  ) {
    throw new Error('Invalid request ID');
  }
  return requestId;
}

function requireCount(value, name) {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new Error(`Invalid ${name}`);
  }
  return value;
}

function safeAdd(a, b) {
  const result = a + b;

  if (!Number.isSafeInteger(result)) {
    throw new Error('Question balance overflow');
  }

  return result;
}

function requireReadyQuota(snapshot) {
  if (!snapshot.exists) {
    throw new Error('QUOTA_MIGRATION_REQUIRED');
  }

  const data = snapshot.data();

  if (data.migrationVersion !== MIGRATION_VERSION) {
    throw new Error('QUOTA_MIGRATION_NOT_VERIFIED');
  }

  const freeUsed = requireCount(
    data.freeUsed,
    'free usage'
  );

  const freeRefunded = requireCount(
    data.freeRefunded ?? 0,
    'free refunds'
  );

  const paidBalance = requireCount(
    data.paidBalance,
    'paid balance'
  );

  if (freeRefunded > freeUsed) {
    throw new Error('Invalid free refund balance');
  }

  const expiry = data.subscriptionExpiresAt ?? null;

  if (
    expiry !== null &&
    (
      typeof expiry !== 'string' ||
      !Number.isFinite(Date.parse(expiry))
    )
  ) {
    throw new Error('Invalid subscription expiry');
  }

  return {
    freeUsed,
    freeRefunded,
    paidBalance,
    subscriptionExpiresAt: expiry
  };
}

function freeRemaining(quota) {
  return Math.max(
    0,
    QUOTA.FREE_LIFETIME -
      (quota.freeUsed - quota.freeRefunded)
  );
}

function subscriptionActive(quota, now = new Date()) {
  if (!quota.subscriptionExpiresAt) {
    return false;
  }

  return (
    Date.parse(quota.subscriptionExpiresAt) >
    now.getTime()
  );
}

function quotaReference(uid) {
  return getAdminFirestore()
    .collection(COLLECTION)
    .doc(requireUid(uid));
}

function questionFingerprint(question, language) {
  if (
    typeof question !== 'string' ||
    !question.trim() ||
    question.length > 4000
  ) {
    throw new Error('Invalid question');
  }

  if (
    !['sinhala', 'english', 'tamil'].includes(language)
  ) {
    throw new Error('Invalid language');
  }

  return crypto
    .createHash('sha256')
    .update(JSON.stringify({
      question,
      language
    }))
    .digest('hex');
}

async function getQuota(uid) {
  const snapshot = await quotaReference(uid).get();
  const quota = requireReadyQuota(snapshot);

  const active = subscriptionActive(quota);

  return {
    freeRemaining: freeRemaining(quota),
    paidBalance: quota.paidBalance,
    subscriptionActive: active,
    availablePaid: active ? quota.paidBalance : 0,
    subscriptionExpiresAt: quota.subscriptionExpiresAt
  };
}

async function authorizeQuestion(
  uid,
  requestId,
  question,
  language,
  isAdmin = false
) {
  requireRequestId(requestId);

  const fingerprint = questionFingerprint(
    question,
    language
  );

  const db = getAdminFirestore();
  const quotaRef = quotaReference(uid);
  const requestRef = quotaRef
    .collection('requests')
    .doc(requestId);

  return db.runTransaction(async (tx) => {
    const quotaSnap = await tx.get(quotaRef);
    const requestSnap = await tx.get(requestRef);

    const quota = requireReadyQuota(quotaSnap);

    if (requestSnap.exists) {
      const previous = requestSnap.data();

      if (
        previous.requestId !== requestId ||
        previous.fingerprint !== fingerprint ||
        previous.success !== true
      ) {
        return {
          success: false,
          reason: 'REQUEST_ID_CONFLICT'
        };
      }

      const { ownerTokenHash, ...publicPrevious } = previous;
      return { ...publicPrevious, repeated: true };
    }

    const now = new Date();
    let source;

    if (isAdmin === true) {
      source = 'admin';
    } else if (freeRemaining(quota) > 0) {
      quota.freeUsed = safeAdd(quota.freeUsed, 1);
      source = 'free';
    } else if (
      subscriptionActive(quota, now) &&
      quota.paidBalance > 0
    ) {
      quota.paidBalance -= 1;
      source = 'paid';
    } else {
      return {
        success: false,
        reason: 'NO_AVAILABLE_QUESTIONS'
      };
    }

    const reservedAt = now.toISOString();

    const leaseExpiresAt = new Date(
      now.getTime() + PROCESSING_LEASE_MS
    ).toISOString();

    const ownerToken = crypto.randomBytes(32).toString('hex');

    const result = {
      success: true,
      requestId,
      fingerprint,
      source,
      status: 'reserved',
      reservedAt,
      leaseExpiresAt,
      ownerTokenHash: crypto.createHash('sha256').update(ownerToken).digest('hex')
    };

    tx.update(quotaRef, {
      freeUsed: quota.freeUsed,
      freeRefunded: quota.freeRefunded,
      paidBalance: quota.paidBalance,
      updatedAt: reservedAt
    });

    tx.create(requestRef, result);

    return { success: true, requestId, source, status: 'reserved', ownerToken };
  });
}

async function completeQuestion(uid, requestId) {
  requireRequestId(requestId);

  const db = getAdminFirestore();
  const quotaRef = quotaReference(uid);
  const requestRef = quotaRef
    .collection('requests')
    .doc(requestId);

  return db.runTransaction(async (tx) => {
    const quotaSnap = await tx.get(quotaRef);
    const requestSnap = await tx.get(requestRef);

    requireReadyQuota(quotaSnap);

    if (!requestSnap.exists) {
      return {
        success: false,
        reason: 'REQUEST_NOT_FOUND'
      };
    }

    const request = requestSnap.data();

    if (request.status === 'completed') {
      return { success: true, repeated: true };
    }

    if (request.status !== 'reserved') {
      return {
        success: false,
        reason: 'REQUEST_NOT_RESERVED'
      };
    }

    tx.update(requestRef, {
      status: 'completed',
      completedAt: new Date().toISOString()
    });

    return { success: true };
  });
}

async function refundQuestion(
  uid,
  requestId,
  options = {}
) {
  requireRequestId(requestId);

  const recovery = options.recovery === true;
  const ownerToken = options.ownerToken;

  const db = getAdminFirestore();
  const quotaRef = quotaReference(uid);
  const requestRef = quotaRef
    .collection('requests')
    .doc(requestId);
  const answerRef = quotaRef
    .collection('answers')
    .doc(requestId);

  return db.runTransaction(async (tx) => {
    const quotaSnap = await tx.get(quotaRef);
    const requestSnap = await tx.get(requestRef);
    const answerSnap = await tx.get(answerRef);

    const quota = requireReadyQuota(quotaSnap);

    if (!requestSnap.exists) {
      return {
        success: false,
        reason: 'REQUEST_NOT_FOUND'
      };
    }

    const request = requestSnap.data();

    if (request.status === 'refunded') {
      return { success: true, repeated: true };
    }

    if (
      request.status !== 'reserved' ||
      answerSnap.exists
    ) {
      return {
        success: false,
        reason: 'REQUEST_NOT_REFUNDABLE'
      };
    }

    const now = new Date();

    if (recovery) {
      const reservedAt = Date.parse(
        request.reservedAt
      );

      const leaseExpiresAt = Date.parse(
        request.leaseExpiresAt
      );

      if (
        !Number.isFinite(reservedAt) ||
        !Number.isFinite(leaseExpiresAt) ||
        now.getTime() - reservedAt < RECOVERY_AFTER_MS ||
        now.getTime() < leaseExpiresAt
      ) {
        return {
          success: false,
          reason: 'RECOVERY_NOT_READY'
        };
      }
    } else {
      if (typeof ownerToken !== 'string' || !/^[a-f0-9]{64}$/.test(ownerToken)) {
        return { success: false, reason: 'OWNER_TOKEN_REQUIRED' };
      }
      const hash = crypto.createHash('sha256').update(ownerToken).digest('hex');
      if (request.ownerTokenHash !== hash) {
        return { success: false, reason: 'OWNER_TOKEN_MISMATCH' };
      }
      const leaseEnd = Date.parse(request.leaseExpiresAt);
      if (!Number.isFinite(leaseEnd) || now.getTime() >= leaseEnd) {
        return { success: false, reason: 'PROCESSING_LEASE_EXPIRED' };
      }
    }

    if (request.source === 'free') {
      quota.freeRefunded = safeAdd(
        quota.freeRefunded,
        1
      );

      if (quota.freeRefunded > quota.freeUsed) {
        throw new Error('Invalid free refund balance');
      }
    } else if (request.source === 'paid') {
      quota.paidBalance = safeAdd(
        quota.paidBalance,
        1
      );
    } else if (request.source === 'admin') {
      // Admin requests do not deduct or refund coins.
    } else {
      throw new Error('Unknown question source');
    }

    const refundedAt = now.toISOString();

    tx.update(quotaRef, {
      freeRefunded: quota.freeRefunded,
      paidBalance: quota.paidBalance,
      updatedAt: refundedAt
    });

    tx.update(requestRef, {
      status: 'refunded',
      refundedAt
    });

    return { success: true };
  });
}

module.exports = {
  getQuota,
  authorizeQuestion,
  completeQuestion,
  refundQuestion,
  PROCESSING_LEASE_MS,
  RECOVERY_AFTER_MS
};



