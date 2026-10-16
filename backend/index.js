'use strict';

const express = require('express');
const { quotaBalanceRouter } = require('./quota_balance_api');
const { aiRequestRouter } = require('./ai_request_api');

const app = express();
const PORT = 3000;

app.disable('x-powered-by');

// CORS for local Flutter Web development only.
app.use((req, res, next) => {
  const origin = req.headers.origin;
  let allowed = false;

  if (origin) {
    try {
      const url = new URL(origin);

      allowed =
        url.protocol === 'http:' &&
        (url.hostname === 'localhost' ||
         url.hostname === '127.0.0.1') &&
        url.username === '' &&
        url.password === '';
    } catch (_) {
      allowed = false;
    }
  }

  if (allowed) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Vary', 'Origin');
    res.setHeader(
      'Access-Control-Allow-Methods',
      'GET, POST, OPTIONS'
    );
    res.setHeader(
      'Access-Control-Allow-Headers',
      'Authorization, Content-Type, Accept'
    );
  }

  if (req.method === 'OPTIONS') {
    return res.sendStatus(allowed ? 204 : 403);
  }

  next();
});

app.use(express.json({ limit: '32kb' }));

app.get('/health', (req, res) => {
  return res.status(200).json({
    success: true,
    app: 'Zingacc Learn AI Backend',
    status: 'running'
  });
});

app.use('/api/quota', quotaBalanceRouter);
app.use('/api/ai', aiRequestRouter);

app.use((req, res) => {
  return res.status(404).json({
    success: false,
    message: 'API endpoint not found'
  });
});

app.listen(PORT, '127.0.0.1', () => {
  console.log(
    `Zingacc Backend running at http://127.0.0.1:${PORT}`
  );
});
