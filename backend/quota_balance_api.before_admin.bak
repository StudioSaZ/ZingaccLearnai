
'use strict';

const express = require('express');

const {
  requireStudentAuth
} = require('./auth_middleware');

const {
  getSafeQuotaBalance
} = require('./quota_safe_balance');

const router = express.Router();

// A valid Firebase ID Token is required.
router.use(requireStudentAuth);

// Read-only quota balance endpoint.
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
      quota: result.quota
    });
  } catch (error) {
    console.error(
      'Quota balance error:',
      error.code || 'UNKNOWN'
    );

    return res.status(500).json({
      success: false,
      message: 'Unable to load AI question balance'
    });
  }
});

module.exports = {
  quotaBalanceRouter: router
};
