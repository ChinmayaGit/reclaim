import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Android — values from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPTTeKU3TP2JgNQF2fv-_Uu4rAnueC1CE',
    appId: '1:58387309805:android:92ab2bbe049c3e369458e4',
    messagingSenderId: '58387309805',
    projectId: 'reclaim-274ca',
    storageBucket: 'reclaim-274ca.firebasestorage.app',
  );

  // Web — add after registering web app in Firebase console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBPTTeKU3TP2JgNQF2fv-_Uu4rAnueC1CE',
    appId: '1:58387309805:web:REPLACE_AFTER_REGISTERING',
    messagingSenderId: '58387309805',
    projectId: 'reclaim-274ca',
    authDomain: 'reclaim-274ca.firebaseapp.com',
    storageBucket: 'reclaim-274ca.firebasestorage.app',
    measurementId: 'G-REPLACE_AFTER_REGISTERING',
  );

  // iOS — add after registering iOS app and downloading GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: '1:58387309805:ios:REPLACE_AFTER_REGISTERING',
    messagingSenderId: '58387309805',
    projectId: 'reclaim-274ca',
    storageBucket: 'reclaim-274ca.firebasestorage.app',
    iosBundleId: 'com.chinu.reclaim',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_MACOS_API_KEY',
    appId: '1:58387309805:macos:REPLACE_AFTER_REGISTERING',
    messagingSenderId: '58387309805',
    projectId: 'reclaim-274ca',
    storageBucket: 'reclaim-274ca.firebasestorage.app',
    iosBundleId: 'com.chinu.reclaim',
  );
}
