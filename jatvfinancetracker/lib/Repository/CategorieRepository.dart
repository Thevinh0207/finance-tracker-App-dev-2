import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/Categorie.dart';
import '../helper/TransactionType.dart';

class CategorieRepository {
  final FirebaseFirestore _firestore;

  CategorieRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('categories');

  Future<String> create(Categorie c) async {
    final doc = c.categoryID.isEmpty ? _col.doc() : _col.doc(c.categoryID);
    final withId = c.categoryID.isEmpty
        ? Categorie(
            categoryID: doc.id,
            userID: c.userID,
            categoryName: c.categoryName,
            type: c.type,
          )
        : c;
    await doc.set(withId.toMap());
    return doc.id;
  }

  Future<Categorie?> getById(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) return null;
    return Categorie.fromMap(snap.data()!);
  }

  Future<List<Categorie>> getByUser(String userID) async {
    final q = await _col.where('userID', isEqualTo: userID).get();
    return q.docs.map((d) => Categorie.fromMap(d.data())).toList();
  }

  Future<List<Categorie>> getByUserAndType(
      String userID, TransactionType type) async {
    final q = await _col
        .where('userID', isEqualTo: userID)
        .where('type', isEqualTo: type.name)
        .get();
    return q.docs.map((d) => Categorie.fromMap(d.data())).toList();
  }

  Future<void> update(Categorie c) async {
    await _col.doc(c.categoryID).update(c.toMap());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<Categorie>> watchByUser(String userID) {
    return _col
        .where('userID', isEqualTo: userID)
        .snapshots()
        .map((s) => s.docs.map((d) => Categorie.fromMap(d.data())).toList());
  }
}
