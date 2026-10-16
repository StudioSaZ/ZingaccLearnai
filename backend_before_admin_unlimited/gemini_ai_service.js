'use strict';

/* Zingacc Learn AI - server-side Gemini service. Keep API keys off clients. */

const GEMINI_ENDPOINT = 'https://generativelanguage.googleapis.com/v1beta/models';
const MODEL = 'gemini-3.8-flash';
const REQUEST_TIMEOUT_MS = 45000;
const MAX_ATTEMPTS = 2;

function getLanguageName(language) {
  const languages = { sinhala: 'Sinhala', english: 'English', tamil: 'Tamil' };
  if (!Object.prototype.hasOwnProperty.call(languages, language)) {
    throw new Error('Invalid explanation language');
  }
  return languages[language];
}

function createPrompt(question, language) {
  const languageName = getLanguageName(language);
  return [
    'You are Zingacc Learn AI, a careful educational tutor.',
    `Answer only in ${languageName}.`,
    'Explain the solution clearly, step by step.',
    'Use age-appropriate language.',
    'For mathematics, verify calculations carefully.',
    'Clearly state the final answer.',
    'If information is missing, explain what is missing.',
    'Do not invent facts or pretend to know.',
    '',
    'Student question:',
    question
  ].join('\n');
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function safeGoogleMessage(value) {
  return typeof value === 'string' ? value.slice(0, 500) : '';
}

async function generateGeminiAnswer({ question, language }) {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey || !apiKey.trim()) {
    const error = new Error('Gemini API key is not configured');
    error.code = 'GEMINI_KEY_MISSING';
    throw error;
  }
  if (typeof question !== 'string' || !question.trim() || question.length > 4000) {
    throw new Error('Invalid AI question');
  }

  const prompt = createPrompt(question, language);
  const url = `${GEMINI_ENDPOINT}/${MODEL}:generateContent`;

  for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey
        },
        body: JSON.stringify({
          contents: [{ role: 'user', parts: [{ text: prompt }] }],
          generationConfig: { temperature: 0.2, maxOutputTokens: 4096 }
        }),
        signal: controller.signal
      });

      if (!response.ok) {
        let details = null;
        try { details = await response.json(); } catch (_) { /* No JSON error body */ }
        const error = new Error('Gemini AI request failed');
        error.code = 'GEMINI_REQUEST_FAILED';
        error.status = response.status;
        error.googleStatus = details?.error?.status || 'UNKNOWN';
        error.googleMessage = safeGoogleMessage(details?.error?.message);

        // Only retry an explicit server response indicating temporary unavailability.
        if (response.status === 503 && attempt < MAX_ATTEMPTS) {
          console.warn(`Gemini temporarily unavailable (503), retrying once`);
          await sleep(1500);
          continue;
        }
        throw error;
      }

      const data = await response.json();
      const parts = data?.candidates?.[0]?.content?.parts;
      const answer = Array.isArray(parts)
        ? parts.filter(part => typeof part.text === 'string').map(part => part.text).join('\n').trim()
        : '';
      if (!answer) {
        const error = new Error('Gemini returned no usable answer');
        error.code = 'GEMINI_EMPTY_ANSWER';
        throw error;
      }
      return answer;
    } catch (error) {
      if (error?.name === 'AbortError') {
        const timeoutError = new Error('Gemini request timed out');
        timeoutError.code = 'GEMINI_TIMEOUT';
        throw timeoutError;
      }
      throw error;
    } finally {
      clearTimeout(timeout);
    }
  }
}

module.exports = { generateGeminiAnswer };
