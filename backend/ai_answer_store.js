
'use strict';
const crypto = require('node:crypto');

const {
  getAdminFirestore
} = require('./firebase_admin');

function validateUid(uid) {
  if (
    typeof uid !== 'string' ||
    !/^[A-Za-z0-9_-]{1,128}$/.test(uid)
  ) {
    throw new Error('Invalid user ID');
  }
  return uid;
}

function validateRequestId(requestId) {
  if (
    typeof requestId !== 'string' ||
    !/^[A-Za-z0-9_-]{8,128}$/.test(requestId)
  ) {
    throw new Error('Invalid request ID');
  }
  return requestId;
}

function getReferences(uid, requestId) {
  const db = getAdminFirestore();

  const quotaRef = db
    .collection('ai_quotas')
    .doc(validateUid(uid));

  const requestRef = quotaRef
    .collection('requests')
    .doc(validateRequestId(requestId));

  const answerRef = quotaRef
    .collection('answers')
    .doc(requestId);

  return {
    db,
    quotaRef,
    requestRef,
    answerRef
  };
}

async function getSavedAnswer(uid, requestId) {
  const { answerRef, requestRef } =
    getReferences(uid, requestId);

  const [answerSnap, requestSnap] =
    await Promise.all([
      answerRef.get(),
      requestRef.get()
    ]);

  if (!answerSnap.exists) {
    return null;
  }

  if (!requestSnap.exists) {
    throw new Error('AI request record missing');
  }

  const answer = answerSnap.data();
  const request = requestSnap.data();

  if (
    answer.status !== 'completed' ||
    request.status !== 'completed' ||
    answer.requestId !== requestId ||
    request.requestId !== requestId ||
    answer.source !== request.source ||
    typeof answer.answer !== 'string' ||
    !answer.answer.trim()
  ) {
    throw new Error('AI answer requires reconciliation');
  }

  return {
    success: true,
    requestId,
    answer: answer.answer,
    charged: answer.source !== 'admin',
    source: answer.source,
    repeated: true
  };
}

/*
 * Save the AI answer and complete its quota
 * reservation in one Firestore transaction.
 */
async function saveAIAnswer({
  uid,
  requestId,
  answer,
  source,
  ownerToken
}) {
  if (
    typeof answer !== 'string' ||
    !answer.trim()
  ) {
    throw new Error('Invalid AI answer');
  }

  if (!['free', 'paid', 'admin'].includes(source)) {
    throw new Error('Invalid quota source');
  }

  const {
    db,
    quotaRef,
    requestRef,
    answerRef
  } = getReferences(uid, requestId);

  return db.runTransaction(async (tx) => {
    // All reads happen before writes.
    const quotaSnap = await tx.get(quotaRef);
    const requestSnap = await tx.get(requestRef);
    const answerSnap = await tx.get(answerRef);

    if (
      !quotaSnap.exists ||
      quotaSnap.data().migrationVersion !== 1
    ) {
      throw new Error('Quota migration required');
    }

    if (!requestSnap.exists) {
      throw new Error('AI request not found');
    }

    const request = requestSnap.data();

    if (
      request.requestId !== requestId ||
      request.source !== source
    ) {
      throw new Error('AI request mismatch');
    }

    if (answerSnap.exists) {
      const existing = answerSnap.data();

      if (
        request.status !== 'completed' ||
        existing.status !== 'completed'
      ) {
        throw new Error('AI answer requires reconciliation');
      }

      return {
        success: true,
        saved: false,
        alreadyExists: true
      };
    }

    const ownerHash = typeof ownerToken === 'string'
      ? crypto.createHash('sha256').update(ownerToken).digest('hex') : null;
    if (!ownerHash || request.ownerTokenHash !== ownerHash) {
      throw new Error('AI processing owner mismatch');
    }

    if (request.status !== 'reserved') {
      throw new Error('AI request is not reserved');
    }

    const now = new Date().toISOString();

    tx.create(answerRef, {
      requestId,
      answer,
      source,
      status: 'completed',
      savedAt: now
    });

    tx.update(requestRef, {
      status: 'completed',
      completedAt: now
    });

    return {
      success: true,
      saved: true,
      completed: true
    };
  });
}

module.exports = {
  getSavedAnswer,
  saveAIAnswer
};


