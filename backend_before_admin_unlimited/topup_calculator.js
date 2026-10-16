'use strict';

const { QUOTA } = require('./quota_rules');

function balanceAfterTopUp(savedBalance, topUpQuestions) {
  if (!Number.isSafeInteger(savedBalance) || savedBalance < 0) {
    throw new Error('Invalid saved balance');
  }

  if (!QUOTA.TOP_UP_OPTIONS.includes(topUpQuestions)) {
    throw new Error('Invalid top-up package');
  }

  const total = savedBalance + topUpQuestions;

  if (!Number.isSafeInteger(total)) {
    throw new Error('Balance exceeds safe limit');
  }

  return total;
}

module.exports = { balanceAfterTopUp };
