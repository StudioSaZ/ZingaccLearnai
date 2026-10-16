'use strict';

const { isSubscriptionActive } = require('./subscription_status');

function availablePaidQuestions(savedBalance, expiresAt, now = new Date()) {
  if (!Number.isSafeInteger(savedBalance) || savedBalance < 0) {
    throw new Error('Invalid saved balance');
  }

  return isSubscriptionActive(expiresAt, now)
    ? savedBalance
    : 0;
}

module.exports = { availablePaidQuestions };
