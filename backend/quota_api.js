
'use strict';

const express = require('express');

const {
  requireStudentAuth
} = require('./auth_middleware');

const {
  getSafeQuotaBalance
} = require('./quota_safe_balance');

const router = express.Router();

// Every request requires Firebase Authentication.
router.use(requireStudentAuth);

// Read-only quota balance.
router.get('/balance', async (req, res) => {
  try {
    const result = await getSafeQuotaBalance(
      req.student.uid
    );

    if (!result.ready) {
      return res.status(409).json({
        success: false,
        ready: false,
        reason: result.reason,
        message: 'AI quota setup is not complete'
      });
    }

    return res.status(200).json({
      success: true,
      ready: true,
      quota: result.quota,
      isAdmin: req.student.isAdmin === true,
      unlimited: req.student.isAdmin === true
    });
  } catch (error) {
    console.error(
      'Quota API error:',
      error.code || 'UNKNOWN'
    );

    return res.status(500).json({
      success: false,
      message: 'Quota service unavailable'
    });
  }
});

// No student-accessible authorize, complete or refund routes.
router.use((req, res) => {
  return res.status(404).json({
    success: false,
    message: 'API endpoint not found'
  });
});

module.exports = {
  quotaRouter: router
};

