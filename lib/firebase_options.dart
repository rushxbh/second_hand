import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDxS7MDargV6j585bOCtbFaYhNA-NIQRFM",
    appId: "1:823641818855:android:6ef001a26846ffa59d0442",
    messagingSenderId: "823641818855",
    projectId: "traderhub-2a23e",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDxS7MDargV6j585bOCtbFaYhNA-NIQRFM",
    appId: "1:823641818855:android:6ef001a26846ffa59d0442",
    messagingSenderId: "823641818855",
    projectId: "traderhub-2a23e",
  );
}
