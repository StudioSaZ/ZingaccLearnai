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
        return android;

      case TargetPlatform.iOS:
        return ios;

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
    appId: '1:206138519919:web:705e0bbc80de3a383bf89a',
    messagingSenderId: '206138519919',
    projectId: 'zingacc-learn-ai',
    authDomain: 'zingacc-learn-ai.firebaseapp.com',
    storageBucket: 'zingacc-learn-ai.firebasestorage.app',
    measurementId: 'G-N389BJBDJT',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC9sCgbXMwRQ_4aMYHzPDNn767d2ZFiCwQ',
    appId: '1:206138519919:ios:d8ae801daa65fe7f3bf89a',
    messagingSenderId: '206138519919',
    projectId: 'zingacc-learn-ai',
    storageBucket: 'zingacc-learn-ai.firebasestorage.app',
    iosBundleId: 'com.example.zingacclearnai',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDaip9KS-Z4Wjgzv8HP4RY82-rMttmf4JA',
    appId: '1:206138519919:android:0ca0dc4ba36c74393bf89a',
    messagingSenderId: '206138519919',
    projectId: 'zingacc-learn-ai',
    storageBucket: 'zingacc-learn-ai.firebasestorage.app',
  );
}
