'use strict';

const express = require('express');
const { requireStudentAuth } = require('./auth_middleware');

const app = express();

app.disable('x-powered-by');

app.get('/api/student/test', requireStudentAuth, (req, res) => {
  res.json({
    success: true,
    message: 'Authenticated student',
    uid: req.student.uid
  });
});

module.exports = { app };
