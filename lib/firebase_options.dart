import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not supported for web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBUShhpuHqC1wbkfuggTB2FtmDGuHDUPvc',
    appId: '1:256806377666:android:8b1006ebfcadf7c0c9435b',
    messagingSenderId: '256806377666',
    projectId: 'ceres-tag-8115b',
    databaseURL: 'https://ceres-tag-8115b-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'ceres-tag-8115b.firebasestorage.app',
  );
}
