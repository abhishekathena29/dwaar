import 'package:firebase_core/firebase_core.dart';
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
        return ios;
      default:
        throw UnsupportedError(
          'FirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBQRZrM8m3XlGaR3EnM8N1a43bvBNUyf3g',
    appId: '1:80022158261:web:07540bc393516ed1d3b7fc',
    messagingSenderId: '80022158261',
    projectId: 'dwaar-820e8',
    authDomain: 'dwaar-820e8.firebaseapp.com',
    storageBucket: 'dwaar-820e8.firebasestorage.app',
    measurementId: 'G-VG2K98JPEX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-3qPUXe8dUytgnbq6XDcxcxhYrqZ2lIc',
    appId: '1:80022158261:android:26c21abbc27296c7d3b7fc',
    messagingSenderId: '80022158261',
    projectId: 'dwaar-820e8',
    storageBucket: 'dwaar-820e8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBoLAOX5XQtOBjx3fZ5gYLGJXSi-3xdk9w',
    appId: '1:80022158261:ios:c3efccad84ec78b1d3b7fc',
    messagingSenderId: '80022158261',
    projectId: 'dwaar-820e8',
    storageBucket: 'dwaar-820e8.firebasestorage.app',
    iosBundleId: 'com.dwaar.app',
  );

}