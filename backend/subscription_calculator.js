'use strict';

const { QUOTA } = require('./quota_rules');

function balanceAfterRenewal(savedBalance) {
  if (!Number.isSafeInteger(savedBalance) || savedBalance < 0) {
    throw new Error('Invalid saved balance');
  }

  const total = savedBalance + QUOTA.MONTHLY_QUESTIONS;

  if (!Number.isSafeInteger(total)) {
    throw new Error('Balance exceeds safe limit');
  }

  return total;
}

module.exports = { balanceAfterRenewal };
