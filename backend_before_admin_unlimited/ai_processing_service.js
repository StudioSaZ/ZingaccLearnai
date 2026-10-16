
'use strict';

const crypto = require('node:crypto');

const {
  authorizeQuestion,
  refundQuestion
} = require('./quota_firestore_service');

const {
  getSavedAnswer,
  saveAIAnswer
} = require('./ai_answer_store');

const {
  generateGeminiAnswer
} = require('./gemini_ai_service');

class AIProcessingError extends Error {
  constructor(message, code) {
    super(message);
    this.name = 'AIProcessingError';
    this.code = code;
  }
}

function validateRequestId(requestId) {
  if (
    typeof requestId !== 'string' ||
    !/^[A-Za-z0-9_-]{8,128}$/.test(requestId)
  ) {
    throw new AIProcessingError(
      'Invalid request ID',
      'INVALID_REQUEST_ID'
    );
  }
}

function validateInput(question, language) {
  if (
    typeof question !== 'string' ||
    !question.trim() ||
    question.length > 4000
  ) {
    throw new AIProcessingError(
      'Invalid question',
      'INVALID_QUESTION'
    );
  }

  if (
    !['sinhala', 'english', 'tamil'].includes(language)
  ) {
    throw new AIProcessingError(
      'Invalid language',
      'INVALID_LANGUAGE'
    );
  }
}

function questionFingerprint(question, language) {
  return crypto
    .createHash('sha256')
    .update(JSON.stringify({
      question,
      language
    }))
    .digest('hex');
}

/*
 * Server-controlled AI processing.
 *
 * Quota reservation and question fingerprint
 * are stored atomically by authorizeQuestion().
 *
 * Answer saving and request completion
 * are stored atomically by saveAIAnswer().
 */
async function processAIQuestion({
  uid,
  requestId,
  question,
  language
}) {
  validateRequestId(requestId);
  validateInput(question, language);

  const fingerprint = questionFingerprint(
    question,
    language
  );

  /*
   * First reserve a question.
   *
   * authorizeQuestion() checks the fingerprint
   * and prevents duplicate quota deduction.
   */
  const reservation = await authorizeQuestion(
    uid,
    requestId,
    question,
    language
  );

  if (!reservation.success) {
    throw new AIProcessingError(
      'AI question reservation failed',
      reservation.reason || 'QUOTA_UNAVAILABLE'
    );
  }

  /*
   * Repeated request:
   * Return its stored answer if completed.
   * Never call Gemini again for this ID.
   */
  if (reservation.repeated) {
    if (reservation.fingerprint !== fingerprint) {
      throw new AIProcessingError(
        'Request ID conflict',
        'REQUEST_ID_CONFLICT'
      );
    }

    if (reservation.status === 'completed') {
      const saved = await getSavedAnswer(
        uid,
        requestId
      );

      if (saved) {
        return saved;
      }

      throw new AIProcessingError(
        'Completed answer requires recovery',
        'ANSWER_RECOVERY_REQUIRED'
      );
    }

    if (reservation.status === 'refunded') {
      throw new AIProcessingError(
        'This request was refunded',
        'REQUEST_ALREADY_REFUNDED'
      );
    }

    throw new AIProcessingError(
      'Request is processing or needs recovery',
      'REQUEST_ALREADY_RESERVED'
    );
  }

  let completed = false;

  try {
    const answer = await generateGeminiAnswer({
      question,
      language
    });

    if (
      typeof answer !== 'string' ||
      !answer.trim()
    ) {
      throw new AIProcessingError(
        'AI returned an empty answer',
        'EMPTY_AI_ANSWER'
      );
    }

    /*
     * One Firestore transaction saves the answer
     * and completes the reserved request.
     */
    const result = await saveAIAnswer({
      uid,
      requestId,
      answer,
      source: reservation.source,
      ownerToken: reservation.ownerToken
    });

    if (!result.success) {
      throw new AIProcessingError(
        'Unable to save AI answer',
        'ANSWER_SAVE_FAILED'
      );
    }

    completed = true;

    if (result.alreadyExists) {
      const saved = await getSavedAnswer(
        uid,
        requestId
      );

      if (saved) {
        return saved;
      }

      throw new AIProcessingError(
        'Saved answer unavailable',
        'ANSWER_RECOVERY_REQUIRED'
      );
    }

    return {
      success: true,
      requestId,
      answer,
      charged: true,
      source: reservation.source
    };

  } catch (error) {
    /*
     * A refund must never occur if an answer
     * was successfully completed.
     *
     * The refund service also checks Firestore
     * request status and saved answer existence.
     */
    if (!completed) {
      try {
        const saved = await getSavedAnswer(
          uid,
          requestId
        );

        if (!saved) {
          const refund = await refundQuestion(
            uid,
            requestId,
            { ownerToken: reservation.ownerToken }
          );

          if (!refund.success) {
            console.error(
              'AI refund requires review:',
              refund.reason || 'UNKNOWN'
            );
          }
        }
      } catch (refundError) {
        console.error(
          'AI refund reconciliation required:',
          refundError.code || 'UNKNOWN'
        );
      }
    }

    throw error;
  }
}

module.exports = {
  AIProcessingError,
  processAIQuestion
};
