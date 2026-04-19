import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/UserSettings.dart';

class UserSettingsRepository {
  final FirebaseFirestore _firestore;

  UserSettingsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('userSettings');

  Future<UserSettings> getOrCreate(String userID) async {
    final snap = await _col.doc(userID).get();
    if (snap.exists) {
      return UserSettings.fromMap(snap.data()!);
    }
    final defaults = UserSettings(userID: userID);
    await _col.doc(userID).set(defaults.toMap());
    return defaults;
  }

  Future<void> save(UserSettings settings) async {
    await _col.doc(settings.userID).set(settings.toMap());
  }
}
