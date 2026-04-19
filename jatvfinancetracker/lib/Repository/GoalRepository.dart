import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/Goal.dart';
import '../helper/GoalType.dart';

class GoalRepository {
  final FirebaseFirestore _firestore;

  GoalRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('goals');

  Future<String> create(Goal g) async {
    final doc = g.goalID.isEmpty ? _col.doc() : _col.doc(g.goalID);
    final withId = g.goalID.isEmpty
        ? Goal(
            goalID: doc.id,
            userID: g.userID,
            goalName: g.goalName,
            goalAmount: g.goalAmount,
            currentAmount: g.currentAmount,
            goalType: g.goalType,
            startDate: g.startDate,
            targetDate: g.targetDate,
            note: g.note,
          )
        : g;
    await doc.set(withId.toMap());
    return doc.id;
  }

  Future<Goal?> getById(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) return null;
    return Goal.fromMap(snap.data()!);
  }

  Future<List<Goal>> getByUser(String userID) async {
    final q = await _col
        .where('userID', isEqualTo: userID)
        .orderBy('targetDate')
        .get();
    return q.docs.map((d) => Goal.fromMap(d.data())).toList();
  }

  Future<List<Goal>> getByType(String userID, GoalType type) async {
    final q = await _col
        .where('userID', isEqualTo: userID)
        .where('goalType', isEqualTo: type.name)
        .get();
    return q.docs.map((d) => Goal.fromMap(d.data())).toList();
  }

  Future<List<Goal>> getActive(String userID) async {
    final goals = await getByUser(userID);
    return goals.where((g) => !g.getIsCompleted).toList();
  }

  Future<void> update(Goal g) async {
    await _col.doc(g.goalID).update(g.toMap());
  }

  Future<void> updateProgress(String goalID, double currentAmount) async {
    await _col.doc(goalID).update({'currentAmount': currentAmount});
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<Goal>> watchByUser(String userID) {
    return _col
        .where('userID', isEqualTo: userID)
        .orderBy('targetDate')
        .snapshots()
        .map((s) => s.docs.map((d) => Goal.fromMap(d.data())).toList());
  }
}
