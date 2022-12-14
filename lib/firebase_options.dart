// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
    // ignore: missing_enum_constant_in_switch
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
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBK0n4KPT1B87a3ZI_WpNOdBRUwjJfwTPs',
    appId: '1:335373002903:web:497f1a8ec14442326d61d2',
    messagingSenderId: '335373002903',
    projectId: 'national-ag',
    authDomain: 'national-ag.firebaseapp.com',
    databaseURL: 'https://national-ag.firebaseio.com',
    storageBucket: 'national-ag.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHYQZ8dHggmIj7wr2sfrUYCcnaI_aV_Aw',
    appId: '1:335373002903:android:d6ae547bbadb5e876d61d2',
    messagingSenderId: '335373002903',
    projectId: 'national-ag',
    databaseURL: 'https://national-ag.firebaseio.com',
    storageBucket: 'national-ag.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCgjgvDKW4NXwEX9qkOyKJixi12w5Nb4d4',
    appId: '1:335373002903:ios:e0726009656489d16d61d2',
    messagingSenderId: '335373002903',
    projectId: 'national-ag',
    databaseURL: 'https://national-ag.firebaseio.com',
    storageBucket: 'national-ag.appspot.com',
    iosClientId: '335373002903-nibte6snuj44jur2eho5nspl0ctc356t.apps.googleusercontent.com',
    iosBundleId: 'com.nas.flutterCustomerApp',
  );
}
