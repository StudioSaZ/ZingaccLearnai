'use strict';

function isSubscriptionActive(expiresAt, now = new Date()) {
  if (!(expiresAt instanceof Date) ||
      !Number.isFinite(expiresAt.getTime())) {
    return false;
  }

  if (!(now instanceof Date) ||
      !Number.isFinite(now.getTime())) {
    return false;
  }

  return expiresAt.getTime() > now.getTime();
}

module.exports = { isSubscriptionActive };
