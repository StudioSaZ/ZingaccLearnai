
'use strict';

const express = require('express');

const {
  requireStudentAuth
} = require('./auth_middleware');

const {
  getSafeQuotaBalance
} = require('./quota_safe_balance');

const { processAIQuestion } = require('./ai_processing_service');
const router = express.Router();

const MAX_QUESTION_LENGTH = 4000;

function validRequestId(value) {
  return (
    typeof value === 'string' &&
    /^[A-Za-z0-9_-]{8,128}$/.test(value)
  );
}

function validQuestion(value) {
  return (
    typeof value === 'string' &&
    value.trim().length > 0 &&
    value.length <= MAX_QUESTION_LENGTH
  );
}

function validLanguage(value) {
  return [
    'sinhala',
    'english',
    'tamil'
  ].includes(value);
}

// Every AI request requires Firebase Authentication.
router.use(requireStudentAuth);

router.post('/ask', async (req, res) => {
  try {
    // Fail closed until security rules, billing and integration are reviewed.
    if (process.env.ENABLE_AI_REQUESTS !== 'true') {
      return res.status(503).json({ success: false, reason: 'AI_PROCESSING_NOT_ENABLED', charged: false });
    }
    if (!process.env.GEMINI_API_KEY) {
      return res.status(503).json({ success: false, reason: 'AI_MODEL_NOT_CONFIGURED', charged: false });
    }
    const body = req.body;

    if (
      !body ||
      typeof body !== 'object' ||
      Array.isArray(body)
    ) {
      return res.status(400).json({
        success: false,
        message: 'Invalid request body'
      });
    }

    const {
      requestId,
      question,
      language
    } = body;

    if (!validRequestId(requestId)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid request ID'
      });
    }

    if (!validQuestion(question)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid question'
      });
    }

    if (!validLanguage(language)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid explanation language'
      });
    }

    // Check that the student's migrated quota exists.
    const balance = await getSafeQuotaBalance(
      req.student.uid
    );

    if (!balance.ready) {
      return res.status(409).json({
        success: false,
        message: 'AI quota migration required',
        reason: balance.reason
      });
    }

    // Reservation is authoritative; a zero balance does not prevent
    // retrieving an answer for an already-completed request ID.
    const result = await processAIQuestion({
      uid: req.student.uid, requestId, question, language
    });
    return res.status(200).json(result);

  } catch (error) {
    console.error(
      'AI request error:',
      error.code || 'UNKNOWN'
    );

    const code = error.code || 'AI_REQUEST_FAILED';
    const statuses = {
      INVALID_REQUEST_ID: 400, INVALID_QUESTION: 400, INVALID_LANGUAGE: 400,
      REQUEST_ID_CONFLICT: 409, REQUEST_ALREADY_RESERVED: 409,
      REQUEST_ALREADY_REFUNDED: 409, ANSWER_RECOVERY_REQUIRED: 409,
      NO_AVAILABLE_QUESTIONS: 403, QUOTA_UNAVAILABLE: 403
    };
    return res.status(statuses[code] || 503).json({
      success: false, reason: code,
      message: 'AI request could not be completed; check balance before retrying'
    });
  }
});

module.exports = {
  aiRequestRouter: router
};
