'use strict';

const { QUOTA } = require('./quota_rules');

function usageWarning(used) {
  if (!Number.isSafeInteger(used) || used < 0) {
    throw new Error('Invalid usage count');
  }

  if (used === QUOTA.WARNING_AT[0]) {
    return 'You have used 120 of 150 AI questions.';
  }

  if (used === QUOTA.WARNING_AT[1]) {
    return 'Only 5 questions remain in your 150-question package.';
  }

  if (used === QUOTA.MONTHLY_QUESTIONS) {
    return 'You have used all 150 package questions. Consider a top-up.';
  }

  return null;
}

module.exports = { usageWarning };
