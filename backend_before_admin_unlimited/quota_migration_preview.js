
'use strict';

const {
  getAdminFirestore
} = require('./firebase_admin');

const {
  QUOTA
} = require('./quota_rules');

function validCount(value) {
  return Number.isSafeInteger(value) && value >= 0;
}

async function previewMigration() {
  const db = getAdminFirestore();

  const users = await db.collection('users').get();

  const summary = {
    totalLegacyUsers: users.size,
    readyForMigration: 0,
    alreadyMigrated: 0,
    needsReview: 0,
    missingUsageField: 0,
    invalidUsageField: 0,
    existingQuotaNeedsReview: 0
  };

  for (const userDoc of users.docs) {
    const user = userDoc.data();

    const quotaDoc = await db
      .collection('ai_quotas')
      .doc(userDoc.id)
      .get();

    if (quotaDoc.exists) {
      if (quotaDoc.data().migrationVersion === 1) {
        summary.alreadyMigrated++;
      } else {
        summary.existingQuotaNeedsReview++;
        summary.needsReview++;
      }

      continue;
    }

    const used = user.free_questions_used;

    if (used === undefined || used === null) {
      summary.missingUsageField++;
      summary.needsReview++;
      continue;
    }

    if (!validCount(used)) {
      summary.invalidUsageField++;
      summary.needsReview++;
      continue;
    }

    const remaining = Math.max(
      0,
      QUOTA.FREE_LIFETIME - used
    );

    // Do not display student identifiers or emails.
    // This is only a read-only eligibility preview.
    if (remaining >= 0) {
      summary.readyForMigration++;
    }
  }

  console.log('\nZingacc Quota Migration Preview');
  console.log('--------------------------------');
  console.log(JSON.stringify(summary, null, 2));
  console.log('\nREAD ONLY - No Firestore data changed.');

  return summary;
}

if (require.main === module) {
  previewMigration().catch((error) => {
    console.error(
      'Migration preview failed:',
      error.code || error.message
    );
    process.exitCode = 1;
  });
}

module.exports = {
  previewMigration
};
