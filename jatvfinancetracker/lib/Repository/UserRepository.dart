import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/User.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> create(User user) async {
    await _users.doc(user.userID).set(user.toMap());
  }

  Future<User?> getById(String userID) async {
    final snap = await _users.doc(userID).get();
    if (!snap.exists) return null;
    return User.fromMap(snap.data()!);
  }

  Future<User?> getByEmail(String email) async {
    final query = await _users
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return User.fromMap(query.docs.first.data());
  }

  Future<bool> emailExists(String email) async {
    final query = await _users
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> update(User user) async {
    await _users.doc(user.userID).update(user.toMap());
  }

  Future<void> delete(String userID) async {
    await _users.doc(userID).delete();
  }

  Stream<User?> watch(String userID) {
    return _users.doc(userID).snapshots().map(
          (snap) => snap.exists ? User.fromMap(snap.data()!) : null,
        );
  }
}
