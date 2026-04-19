import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/Budget.dart';

class BudgetRepository {
  final FirebaseFirestore _firestore;

  BudgetRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('budgets');

  Future<String> create(Budget b) async {
    final doc = b.budgetID.isEmpty ? _col.doc() : _col.doc(b.budgetID);
    final withId = b.budgetID.isEmpty
        ? Budget(
            budgetID: doc.id,
            userID: b.userID,
            categoryID: b.categoryID,
            budgetName: b.budgetName,
            amount: b.amount,
            period: b.period,
            startDate: b.startDate,
            endDate: b.endDate,
          )
        : b;
    await doc.set(withId.toMap());
    return doc.id;
  }

  Future<Budget?> getById(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) return null;
    return Budget.fromMap(snap.data()!);
  }

  Future<List<Budget>> getByUser(String userID) async {
    final q = await _col.where('userID', isEqualTo: userID).get();
    return q.docs.map((d) => Budget.fromMap(d.data())).toList();
  }

  Future<List<Budget>> getActive(String userID, DateTime now) async {
    final ts = Timestamp.fromDate(now);
    final q = await _col
        .where('userID', isEqualTo: userID)
        .where('endDate', isGreaterThanOrEqualTo: ts)
        .get();
    return q.docs
        .map((d) => Budget.fromMap(d.data()))
        .where((b) => !b.startDate.isAfter(now))
        .toList();
  }

  Future<List<Budget>> getByCategory(String userID, String categoryID) async {
    final q = await _col
        .where('userID', isEqualTo: userID)
        .where('categoryID', isEqualTo: categoryID)
        .get();
    return q.docs.map((d) => Budget.fromMap(d.data())).toList();
  }

  Future<void> update(Budget b) async {
    await _col.doc(b.budgetID).update(b.toMap());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<Budget>> watchByUser(String userID) {
    return _col
        .where('userID', isEqualTo: userID)
        .snapshots()
        .map((s) => s.docs.map((d) => Budget.fromMap(d.data())).toList());
  }
}
