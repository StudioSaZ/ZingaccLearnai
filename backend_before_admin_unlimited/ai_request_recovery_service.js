
'use strict';

/*
 * Zingacc Learn AI
 * Step 149 - AI Request Recovery Service
 *
 * This service must only be called by
 * trusted backend administration code.
 *
 * Do not expose it as a public API.
 */

const {
  getAdminFirestore
} = require('./firebase_admin');

const {
  refundQuestion,
  RECOVERY_AFTER_MS
} = require('./quota_firestore_service');

const MAX_REQUESTS_PER_RUN = 50;

function validateUid(uid) {
  if (
    typeof uid !== 'string' ||
    !/^[A-Za-z0-9_-]{1,128}$/.test(uid)
  ) {
    throw new Error('Invalid user ID');
  }

  return uid;
}

function parseTimestamp(value) {
  if (typeof value !== 'string') {
    return null;
  }

  const timestamp = Date.parse(value);

  return Number.isFinite(timestamp)
    ? timestamp
    : null;
}

function isStaleReservation(
  request,
  now = new Date()
) {
  if (
    !request ||
    request.status !== 'reserved'
  ) {
    return false;
  }

  const reservedAt = parseTimestamp(
    request.reservedAt
  );

  const leaseExpiresAt = parseTimestamp(
    request.leaseExpiresAt
  );

  // Missing or invalid timestamps:
  // Do not automatically refund.
  if (
    reservedAt === null ||
    leaseExpiresAt === null
  ) {
    return false;
  }

  if (
    now.getTime() - reservedAt <
    RECOVERY_AFTER_MS
  ) {
    return false;
  }

  return now.getTime() >= leaseExpiresAt;
}

async function recoverUserRequests(uid) {
  validateUid(uid);

  const db = getAdminFirestore();

  const quotaRef = db
    .collection('ai_quotas')
    .doc(uid);

  const quotaSnapshot = await quotaRef.get();

  if (
    !quotaSnapshot.exists ||
    quotaSnapshot.data().migrationVersion !== 1
  ) {
    return {
      success: false,
      reason: 'QUOTA_MIGRATION_REQUIRED'
    };
  }

  const requestsSnapshot = await quotaRef
    .collection('requests')
    .where('status', '==', 'reserved')
    .limit(MAX_REQUESTS_PER_RUN)
    .get();

  const now = new Date();

  const result = {
    success: true,
    checked: 0,
    recovered: 0,
    skipped: 0,
    needsReview: 0,
    failed: 0
  };

  for (const document of requestsSnapshot.docs) {
    result.checked += 1;

    const request = document.data();
    const requestId = document.id;

    if (
      parseTimestamp(request.reservedAt) === null ||
      parseTimestamp(request.leaseExpiresAt) === null
    ) {
      result.needsReview += 1;
      continue;
    }

    if (!isStaleReservation(request, now)) {
      result.skipped += 1;
      continue;
    }

    try {
      /*
       * Preliminary check.
       *
       * refundQuestion() repeats the critical
       * checks inside its Firestore transaction.
       */
      const answerRef = quotaRef
        .collection('answers')
        .doc(requestId);

      const answerSnapshot = await answerRef.get();

      if (answerSnapshot.exists) {
        result.needsReview += 1;
        continue;
      }

      /*
       * IMPORTANT:
       * Explicitly enable recovery checks.
       */
      const refund = await refundQuestion(
        uid,
        requestId,
        { recovery: true }
      );

      if (refund.success) {
        result.recovered += 1;
      } else {
        result.needsReview += 1;
      }

    } catch (error) {
      result.failed += 1;

      console.error(
        'AI recovery failed:',
        error.code || 'UNKNOWN'
      );
    }
  }

  return result;
}

module.exports = {
  recoverUserRequests,
  isStaleReservation,
  RECOVERY_AFTER_MS
};
