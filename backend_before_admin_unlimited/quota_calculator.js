'use strict';

const { QUOTA } = require('./quota_rules');

function freeQuestionsRemaining(used) {
  if (!Number.isSafeInteger(used) || used < 0) {
    throw new Error('Invalid free question count');
  }

  return Math.max(0, QUOTA.FREE_LIFETIME - used);
}

module.exports = { freeQuestionsRemaining };
