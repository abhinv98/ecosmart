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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCsw-eLuee_1EtEf3iaE99WB9KO8WOxyx4',
    appId: '1:6679062448:android:d5f066e46f4c9267501875',
    messagingSenderId: '6679062448',
    projectId: 'ecosmart-b3e0a',
    storageBucket: 'ecosmart-b3e0a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCsB6oJlhCq6ilp7iuUo_4Cmy39HGCkG34',
    appId: '1:6679062448:ios:ede8afdc8c6d295d501875',
    messagingSenderId: '6679062448',
    projectId: 'ecosmart-b3e0a',
    storageBucket: 'ecosmart-b3e0a.appspot.com',
    iosBundleId: 'com.example.ecosmart',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyByQlfT3nL7bwcaGv2meGIsn2qCuqjZM3U',
    appId: '1:6679062448:web:6aa6edd151289374501875',
    messagingSenderId: '6679062448',
    projectId: 'ecosmart-b3e0a',
    authDomain: 'ecosmart-b3e0a.firebaseapp.com',
    storageBucket: 'ecosmart-b3e0a.appspot.com',
    measurementId: 'G-4M8KQNQ02V',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCsB6oJlhCq6ilp7iuUo_4Cmy39HGCkG34',
    appId: '1:6679062448:ios:ede8afdc8c6d295d501875',
    messagingSenderId: '6679062448',
    projectId: 'ecosmart-b3e0a',
    storageBucket: 'ecosmart-b3e0a.appspot.com',
    iosBundleId: 'com.example.ecosmart',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyByQlfT3nL7bwcaGv2meGIsn2qCuqjZM3U',
    appId: '1:6679062448:web:d285b36b167d8aaa501875',
    messagingSenderId: '6679062448',
    projectId: 'ecosmart-b3e0a',
    authDomain: 'ecosmart-b3e0a.firebaseapp.com',
    storageBucket: 'ecosmart-b3e0a.appspot.com',
    measurementId: 'G-HZ8VQRY40B',
  );

}