'use strict';

const { verifyStudentToken } = require('./auth_verify');

async function requireStudentAuth(req, res, next) {
  const header = req.headers.authorization;

  if (typeof header !== 'string' ||
      !header.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Authentication required'
    });
  }

  const token = header.slice(7).trim();

  try {
    req.student = await verifyStudentToken(token);
    return next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired authentication'
    });
  }
}

module.exports = { requireStudentAuth };
