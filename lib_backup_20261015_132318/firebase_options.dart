import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'Firebase Android is not configured yet.',
        );

      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Firebase iOS is not configured yet.',
        );

      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firebase macOS is not configured yet.',
        );

      case TargetPlatform.windows:
        throw UnsupportedError(
          'Firebase Windows is not configured yet.',
        );

      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase Linux is not configured yet.',
        );

      default:
        throw UnsupportedError(
          'Firebase is not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCU5bDk7nBGHZVv0l0z_pj3yz-NMUFoLUc',
    authDomain: 'zingacc-learn-ai.firebaseapp.com',
    projectId: 'zingacc-learn-ai',
    storageBucket: 'zingacc-learn-ai.firebasestorage.app',
    messagingSenderId: '206138519919',
    appId: '1:206138519919:web:705e0bbc80de3a383bf89a',
    measurementId: 'G-N389BJBDJT',
  );
}