'use strict';

const { getAuth } = require('firebase-admin/auth');
const { getAdminFirestore } = require('./firebase_admin');

async function verifyStudentToken(idToken) {
  if (typeof idToken !== 'string' || !idToken.trim()) {
    throw new Error('Missing Firebase ID token');
  }

  getAdminFirestore();

  const decoded = await getAuth().verifyIdToken(idToken, true);

  if (!decoded.uid) {
    throw new Error('Invalid Firebase user');
  }

  return {
    uid: decoded.uid,
    email: decoded.email || null,
    isAdmin: decoded.admin === true
  };
}

module.exports = { verifyStudentToken };

