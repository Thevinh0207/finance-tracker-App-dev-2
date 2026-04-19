import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  static FirebaseOptions get getOptions {
    return FirebaseOptions(
      apiKey: _require('FIREBASE_API_KEY'),
      appId: _require('FIREBASE_APP_ID'),
      messagingSenderId: _require('FIREBASE_MESSAGING_SENDER_ID'),
      projectId: _require('FIREBASE_PROJECT_ID'),
      storageBucket: dotenv.maybeGet('FIREBASE_STORAGE_BUCKET'),
    );
  }

  static String _require(String key) {
    final value = dotenv.maybeGet(key);
    if (value == null || value.isEmpty) {
      throw StateError('Missing $key in .env — copy .env.template and fill it in.');
    }
    return value;
  }
}
