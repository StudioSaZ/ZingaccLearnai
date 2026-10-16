
'use strict';

const { getAdminFirestore } = require('./firebase_admin');
const { QUOTA } = require('./quota_rules');
const {
  verifyPaymentAuthorization
} = require('./payment_authorization');

const COLLECTION = 'ai_quotas';

function checkUid(uid) {
  if (
    typeof uid !== 'string' ||
    !/^[A-Za-z0-9_-]{1,128}$/.test(uid)
  ) {
    throw new Error('Invalid Firebase user ID');
  }
  return uid;
}

function checkOperationId(operationId) {
  if (
    typeof operationId !== 'string' ||
    !/^[A-Za-z0-9_-]{8,128}$/.test(operationId)
  ) {
    throw new Error('Invalid operation ID');
  }
  return operationId;
}

function checkBalance(value) {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new Error('Invalid question balance');
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

function quotaRef(uid) {
  return getAdminFirestore()
    .collection(COLLECTION)
    .doc(checkUid(uid));
}

function parseExpiry(value) {
  if (value == null) return null;

  if (typeof value !== 'string') {
    throw new Error('Invalid subscription expiry');
  }

  const date = new Date(value);

  if (!Number.isFinite(date.getTime())) {
    throw new Error('Invalid subscription expiry');
  }

  return date;
}

async function renewSubscription(
  uid,
  operationId,
  paymentEvidence
) {
  checkUid(uid);
  checkOperationId(operationId);

  // This must succeed BEFORE any balance changes.
  // Currently it always rejects unverified payments.
  await verifyPaymentAuthorization(paymentEvidence);

  const db = getAdminFirestore();
  const ref = quotaRef(uid);

  const operationRef = ref
    .collection('operations')
    .doc(operationId);

  return db.runTransaction(async (tx) => {
    const quotaSnap = await tx.get(ref);
    const operationSnap = await tx.get(operationRef);

    if (operationSnap.exists) {
      const previous = operationSnap.data();

      if (previous.type !== 'renewal') {
        throw new Error('Operation ID already used');
      }

      return {
        ...previous,
        repeated: true
      };
    }

    const data = quotaSnap.exists
      ? quotaSnap.data()
      : {};

    const oldBalance = checkBalance(
      data.paidBalance ?? 0
    );

    const newBalance = safeAdd(
      oldBalance,
      QUOTA.MONTHLY_QUESTIONS
    );

    const now = new Date();

    const oldExpiry = parseExpiry(
      data.subscriptionExpiresAt
    );

    const start = (
      oldExpiry && oldExpiry > now
    ) ? oldExpiry : now;

    const expiry = new Date(
      start.getTime() +
      QUOTA.SUBSCRIPTION_DAYS * 86400000
    );

    const result = {
      success: true,
      type: 'renewal',
      operationId,
      addedQuestions: QUOTA.MONTHLY_QUESTIONS,
      paidBalance: newBalance,
      subscriptionExpiresAt: expiry.toISOString()
    };

    tx.set(ref, {
      paidBalance: newBalance,
      subscriptionExpiresAt: expiry.toISOString(),
      updatedAt: now.toISOString()
    }, { merge: true });

    tx.create(operationRef, result);

    return result;
  });
}

async function addTopUp(
  uid,
  operationId,
  questions,
  paymentEvidence
) {
  checkUid(uid);
  checkOperationId(operationId);

  if (!QUOTA.TOP_UP_OPTIONS.includes(questions)) {
    throw new Error('Invalid top-up package');
  }

  // No verified payment = no additional questions.
  await verifyPaymentAuthorization(paymentEvidence);

  const db = getAdminFirestore();
  const ref = quotaRef(uid);

  const operationRef = ref
    .collection('operations')
    .doc(operationId);

  return db.runTransaction(async (tx) => {
    const quotaSnap = await tx.get(ref);
    const operationSnap = await tx.get(operationRef);

    if (operationSnap.exists) {
      const previous = operationSnap.data();

      if (
        previous.type !== 'topup' ||
        previous.addedQuestions !== questions
      ) {
        throw new Error('Operation ID already used');
      }

      return {
        ...previous,
        repeated: true
      };
    }

    const data = quotaSnap.exists
      ? quotaSnap.data()
      : {};

    const oldBalance = checkBalance(
      data.paidBalance ?? 0
    );

    const newBalance = safeAdd(
      oldBalance,
      questions
    );

    const now = new Date();

    const result = {
      success: true,
      type: 'topup',
      operationId,
      addedQuestions: questions,
      paidBalance: newBalance
    };

    tx.set(ref, {
      paidBalance: newBalance,
      updatedAt: now.toISOString()
    }, { merge: true });

    tx.create(operationRef, result);

    return result;
  });
}

module.exports = {
  renewSubscription,
  addTopUp
};
