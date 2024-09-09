// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBAJL7AZBmcTi47VdOnTX-mMx__aJuvGr0',
    appId: '1:208455228653:web:3cd5dd4e4b52008a39c0e4',
    messagingSenderId: '208455228653',
    projectId: 'booklist-9e9d3',
    authDomain: 'booklist-9e9d3.firebaseapp.com',
    storageBucket: 'booklist-9e9d3.appspot.com',
    measurementId: 'G-Y6Z1F8J74T',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5muMX2_juKj7L19EfWx87ZW0l807wNCE',
    appId: '1:208455228653:android:c7c6ff9c9120655b39c0e4',
    messagingSenderId: '208455228653',
    projectId: 'booklist-9e9d3',
    storageBucket: 'booklist-9e9d3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBRwul_GvRTXB9aNXXScLkTM56UhdQJzp0',
    appId: '1:208455228653:ios:48b85752150fd16539c0e4',
    messagingSenderId: '208455228653',
    projectId: 'booklist-9e9d3',
    storageBucket: 'booklist-9e9d3.appspot.com',
    iosBundleId: 'com.example.bookList',
  );
}
