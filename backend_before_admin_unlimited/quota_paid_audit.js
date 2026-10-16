
'use strict';

const {
  getAdminFirestore
} = require('./firebase_admin');

async function auditPaidData() {
  const db = getAdminFirestore();

  const users = await db.collection('users').get();

  const summary = {
    totalUsers: users.size,
    usersWithPaidCoins: 0,
    usersWithPaidBalanceField: 0,
    usersWithSubscriptionExpiry: 0,
    usersNeedingPaidReview: 0,
    usersReadyForFreeOnlyMigration: 0
  };

  for (const doc of users.docs) {
    const data = doc.data();

    const paidCoins = data.paid_coins;
    const paidBalance = data.paid_questions_balance;
    const expiry = data.subscription_expires_at;

    const hasPaidCoins =
      paidCoins !== undefined &&
      paidCoins !== null &&
      paidCoins !== 0;

    const hasPaidBalance =
      paidBalance !== undefined &&
      paidBalance !== null;

    const hasExpiry =
      expiry !== undefined &&
      expiry !== null &&
      expiry !== '';

    if (hasPaidCoins) {
      summary.usersWithPaidCoins++;
    }

    if (hasPaidBalance) {
      summary.usersWithPaidBalanceField++;
    }

    if (hasExpiry) {
      summary.usersWithSubscriptionExpiry++;
    }

    if (
      hasPaidCoins ||
      hasPaidBalance ||
      hasExpiry
    ) {
      summary.usersNeedingPaidReview++;
    } else {
      summary.usersReadyForFreeOnlyMigration++;
    }
  }

  console.log('\nZingacc Paid Data Audit');
  console.log('-----------------------');
  console.log(JSON.stringify(summary, null, 2));
  console.log('\nREAD ONLY - No data changed.');

  return summary;
}

if (require.main === module) {
  auditPaidData().catch((error) => {
    console.error(
      'Audit failed:',
      error.code || error.message
    );
    process.exitCode = 1;
  });
}

module.exports = {
  auditPaidData
};
