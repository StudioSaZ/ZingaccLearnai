
'use strict';

const {
  getAdminFirestore
} = require('./firebase_admin');

const {
  getQuota
} = require('./quota_firestore_service');

function validateUid(uid) {
  if (
    typeof uid !== 'string' ||
    !/^[A-Za-z0-9_-]{1,128}$/.test(uid)
  ) {
    throw new Error('Invalid Firebase user ID');
  }

  return uid;
}

async function getSafeQuotaBalance(uid) {
  validateUid(uid);

  const db = getAdminFirestore();

  const quotaRef = db
    .collection('ai_quotas')
    .doc(uid);

  const snapshot = await quotaRef.get();

  if (!snapshot.exists) {
    return {
      success: false,
      ready: false,
      reason: 'QUOTA_MIGRATION_REQUIRED'
    };
  }

  const quota = snapshot.data();

  if (
    quota.migrationVersion !== 1
  ) {
    return {
      success: false,
      ready: false,
      reason: 'QUOTA_MIGRATION_NOT_VERIFIED'
    };
  }

  const balance = await getQuota(uid);

  return {
    success: true,
    ready: true,
    quota: balance
  };
}

module.exports = {
  getSafeQuotaBalance
};
