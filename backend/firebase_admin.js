'use strict';

const { initializeApp, getApps, applicationDefault } =
  require('firebase-admin/app');

const { getFirestore } =
  require('firebase-admin/firestore');

function getAdminFirestore() {
  if (getApps().length === 0) {
    initializeApp({
      credential: applicationDefault(),
      projectId: 'zingacc-learn-ai'
    });
  }

  return getFirestore();
}

module.exports = { getAdminFirestore };
