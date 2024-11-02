// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBh0tlPcoq1ZEXZKVWxFeY-mw4WTGOY5eY',
    appId: '1:233944847319:web:0d3a3b961ec0dc1d3bb192',
    messagingSenderId: '233944847319',
    projectId: 'torent-4f9bc',
    authDomain: 'torent-4f9bc.firebaseapp.com',
    storageBucket: 'torent-4f9bc.firebasestorage.app',
    measurementId: 'G-88D9W8W2WJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBaBbt7TrpccGDVBZfDLbp2Ps5M_vX6KwQ',
    appId: '1:233944847319:android:ac6802f41d1937213bb192',
    messagingSenderId: '233944847319',
    projectId: 'torent-4f9bc',
    storageBucket: 'torent-4f9bc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAov7fR2eqyfJwAKZIi_6LRFcJ55RDST4k',
    appId: '1:233944847319:ios:90e583d3d544b66d3bb192',
    messagingSenderId: '233944847319',
    projectId: 'torent-4f9bc',
    storageBucket: 'torent-4f9bc.firebasestorage.app',
    iosBundleId: 'com.example.toRent',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAov7fR2eqyfJwAKZIi_6LRFcJ55RDST4k',
    appId: '1:233944847319:ios:90e583d3d544b66d3bb192',
    messagingSenderId: '233944847319',
    projectId: 'torent-4f9bc',
    storageBucket: 'torent-4f9bc.firebasestorage.app',
    iosBundleId: 'com.example.toRent',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBh0tlPcoq1ZEXZKVWxFeY-mw4WTGOY5eY',
    appId: '1:233944847319:web:913ac2548612cad13bb192',
    messagingSenderId: '233944847319',
    projectId: 'torent-4f9bc',
    authDomain: 'torent-4f9bc.firebaseapp.com',
    storageBucket: 'torent-4f9bc.firebasestorage.app',
    measurementId: 'G-S1KCVG85FT',
  );
}