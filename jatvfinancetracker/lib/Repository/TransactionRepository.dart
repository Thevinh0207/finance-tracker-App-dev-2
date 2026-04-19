import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../Model/Transaction.dart';
import '../helper/TransactionType.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('transactions');

  Future<String> create(Transaction t) async {
    final doc = t.transactionID.isEmpty ? _col.doc() : _col.doc(t.transactionID);
    final withId = t.transactionID.isEmpty
        ? Transaction(
            transactionID: doc.id,
            userID: t.userID,
            transactionName: t.transactionName,
            type: t.type,
            categoryID: t.categoryID,
            budgetID: t.budgetID,
            amount: t.amount,
            date: t.date,
            note: t.note,
          )
        : t;
    await doc.set(withId.toMap());
    return doc.id;
  }

  Future<Transaction?> getById(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) return null;
    return Transaction.fromMap(snap.data()!);
  }

  Future<List<Transaction>> getByUser(String userID) async {
    final q = await _col
        .where('userID', isEqualTo: userID)
        .orderBy('date', descending: true)
        .get();
    return q.docs.map((d) => Transaction.fromMap(d.data())).toList();
  }

  Future<List<Transaction>> getByDateRange(
      String userID, DateTime start, DateTime end) async {
    final q = await _col
        .where('userID', isEqualTo: userID)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();
    return q.docs.map((d) => Transaction.fromMap(d.data())).toList();
  }

  Future<List<Transaction>> getByCategory(String userID, String categoryID) async {
    final q = await _col
        .where('userID', isEqualTo: userID)
        .where('categoryID', isEqualTo: categoryID)
        .get();
    return q.docs.map((d) => Transaction.fromMap(d.data())).toList();
  }

  Future<List<Transaction>> getByType(String userID, TransactionType type) async {
    final q = await _col
        .where('userID', isEqualTo: userID)
        .where('type', isEqualTo: type.name)
        .get();
    return q.docs.map((d) => Transaction.fromMap(d.data())).toList();
  }

  Future<void> update(Transaction t) async {
    await _col.doc(t.transactionID).update(t.toMap());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<Transaction>> watchByUser(String userID) {
    return _col
        .where('userID', isEqualTo: userID)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Transaction.fromMap(d.data())).toList());
  }
}
