
'use strict';

const {
  getAdminFirestore
} = require('./firebase_admin');

const {
  QUOTA
} = require('./quota_rules');

const USERS_COLLECTION = 'users';
const QUOTA_COLLECTION = 'ai_quotas';

function validateUid(uid) {
  if (
    typeof uid !== 'string' ||
    !/^[A-Za-z0-9_-]{1,128}$/.test(uid)
  ) {
    throw new Error('Invalid Firebase user ID');
  }

  return uid;
}

function validCount(value, fieldName) {
  if (
    !Number.isSafeInteger(value) ||
    value < 0
  ) {
    throw new Error(
      `Invalid legacy field: ${fieldName}`
    );
  }

  return value;
}

function getLegacyFreeUsed(data) {
  if (
    data.free_questions_used === undefined ||
    data.free_questions_used === null
  ) {
    // Do not guess the usage of an existing user.
    throw new Error(
      'Legacy free question usage is missing'
    );
  }

  return validCount(
    data.free_questions_used,
    'free_questions_used'
  );
}

/*
 * Migrate a single authenticated user's
 * legacy free-question usage.
 *
 * Safety:
 * - Never deletes legacy user data.
 * - Never resets an existing quota.
 * - Uses a Firestore transaction.
 * - Never copies legacy coin balances as
 *   paid AI questions.
 * - Does not grant subscriptions or top-ups.
 */
async function migrateUserQuota(uid) {
  validateUid(uid);

  const db = getAdminFirestore();

  const userRef = db
    .collection(USERS_COLLECTION)
    .doc(uid);

  const quotaRef = db
    .collection(QUOTA_COLLECTION)
    .doc(uid);

  return db.runTransaction(async (tx) => {
    // Read all documents before writing.
    const userSnap = await tx.get(userRef);
    const quotaSnap = await tx.get(quotaRef);

    if (quotaSnap.exists) {
      return {
        success: true,
        migrated: false,
        reason: 'QUOTA_ALREADY_EXISTS'
      };
    }

    if (!userSnap.exists) {
      return {
        success: false,
        migrated: false,
        reason: 'LEGACY_USER_NOT_FOUND'
      };
    }

    const legacy = userSnap.data();

    const freeUsed = getLegacyFreeUsed(legacy);

    const now = new Date().toISOString();

    const newQuota = {
      freeUsed,
      paidBalance: 0,
      subscriptionExpiresAt: null,

      migrationVersion: 1,
      migratedFrom: USERS_COLLECTION,
      migratedAt: now,
      createdAt: now,
      updatedAt: now
    };

    tx.create(quotaRef, newQuota);

    return {
      success: true,
      migrated: true,
      freeRemaining: Math.max(
        0,
        QUOTA.FREE_LIFETIME - freeUsed
      ),
      reason: 'LEGACY_FREE_USAGE_PRESERVED'
    };
  });
}

module.exports = {
  migrateUserQuota
};
