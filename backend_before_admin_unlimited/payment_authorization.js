
'use strict';

// Payment operations are disabled until a trusted
// payment verification process is implemented.
//
// Never trust a student's request to grant paid questions.

class PaymentAuthorizationError extends Error {
  constructor() {
    super('Verified payment authorization required');
    this.name = 'PaymentAuthorizationError';
    this.code = 'PAYMENT_NOT_VERIFIED';
  }
}

async function verifyPaymentAuthorization() {
  // Fail closed: no payment provider is connected yet.
  throw new PaymentAuthorizationError();
}

module.exports = {
  PaymentAuthorizationError,
  verifyPaymentAuthorization
};
