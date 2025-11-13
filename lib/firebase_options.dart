// GENERATED minimal options from provided google-services.json (Android only)
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Plataforma no soportada para FirebaseOptions. Configura solo Android o genera opciones para otras plataformas.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyADUrkFAHqPNihnm7U25IRxRbakqSdqr4E',
    appId: '1:1041525816453:android:ee7fc5ab3babec49dffdec',
    messagingSenderId: '1041525816453',
    projectId: 'devapp-b6b7c',
    storageBucket: 'devapp-b6b7c.firebasestorage.app',
    databaseURL: 'https://devapp-b6b7c-default-rtdb.firebaseio.com',
  );
}


