
'use strict';

const { getAuth } = require('firebase-admin/auth');
const { getAdminFirestore } = require('./firebase_admin');

async function main() {
  getAdminFirestore();

  const uid = process.env.ZINGACC_ADMIN_UID;

  if (!uid || !/^[A-Za-z0-9_-]{1,128}$/.test(uid)) {
    throw new Error('Valid admin UID is required');
  }

  const auth = getAuth();
  const user = await auth.getUser(uid);

  console.log('Target email:', user.email || 'No email');

  const claims = user.customClaims || {};

  await auth.setCustomUserClaims(uid, {
    ...claims,
    admin: true
  });

  console.log('Admin claim assigned successfully');
}

main().catch(error => {
  console.error('Admin setup failed:', error.code || error.message);
  process.exitCode = 1;
});
