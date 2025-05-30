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
    apiKey: 'AIzaSyCl3X9X7lLNG9Sh_A07MAonLCb1fLKQtVQ',
    appId: '1:131888086882:web:9663c2b79570b4c8cdb63b',
    messagingSenderId: '131888086882',
    projectId: 'miniprojet-90f5c',
    authDomain: 'miniprojet-90f5c.firebaseapp.com',
    storageBucket: 'miniprojet-90f5c.firebasestorage.app',
    measurementId: 'G-RHF2ZHK1EN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCI2wE4os6JZSx-rudYYSpGdw7acTL1DnY',
    appId: '1:131888086882:android:73750d67ca07b0afcdb63b',
    messagingSenderId: '131888086882',
    projectId: 'miniprojet-90f5c',
    storageBucket: 'miniprojet-90f5c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANsc5ccMBCgjYsF0WOjRgkEstv7d_P0vo',
    appId: '1:131888086882:ios:3aa75d60d525d2fbcdb63b',
    messagingSenderId: '131888086882',
    projectId: 'miniprojet-90f5c',
    storageBucket: 'miniprojet-90f5c.firebasestorage.app',
    iosBundleId: 'com.example.miniProjet3',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyANsc5ccMBCgjYsF0WOjRgkEstv7d_P0vo',
    appId: '1:131888086882:ios:3aa75d60d525d2fbcdb63b',
    messagingSenderId: '131888086882',
    projectId: 'miniprojet-90f5c',
    storageBucket: 'miniprojet-90f5c.firebasestorage.app',
    iosBundleId: 'com.example.miniProjet3',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCl3X9X7lLNG9Sh_A07MAonLCb1fLKQtVQ',
    appId: '1:131888086882:web:847eb19b95c01dbacdb63b',
    messagingSenderId: '131888086882',
    projectId: 'miniprojet-90f5c',
    authDomain: 'miniprojet-90f5c.firebaseapp.com',
    storageBucket: 'miniprojet-90f5c.firebasestorage.app',
    measurementId: 'G-S79CKSVNRQ',
  );
}
