import 'package:cloud_firestore/cloud_firestore.dart';

import '../Model/FamilyGroup.dart';
import '../Model/FamilyMember.dart';
import '../Model/SharedExpense.dart';

class FamilyRepository {
  final FirebaseFirestore _db;

  FamilyRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('familyGroups');

  CollectionReference<Map<String, dynamic>> _members(String groupID) =>
      _groups.doc(groupID).collection('members');

  CollectionReference<Map<String, dynamic>> _expenses(String groupID) =>
      _groups.doc(groupID).collection('sharedExpenses');

  // ── Group ─────────────────────────────────────────────────────────────────

  Future<FamilyGroup?> getGroupByUser(String userID) async {
    final adminSnap = await _groups
        .where('adminUserID', isEqualTo: userID)
        .limit(1)
        .get();
    if (adminSnap.docs.isNotEmpty) {
      return FamilyGroup.fromMap(adminSnap.docs.first.data());
    }
    final memberSnap = await _groups
        .where('memberUserIDs', arrayContains: userID)
        .limit(1)
        .get();
    if (memberSnap.docs.isNotEmpty) {
      return FamilyGroup.fromMap(memberSnap.docs.first.data());
    }
    return null;
  }

  Future<String> createGroup({
    required String groupName,
    required String adminUserID,
    required double totalBudget,
  }) async {
    final doc = _groups.doc();
    final group = FamilyGroup(
      groupID: doc.id,
      groupName: groupName,
      adminUserID: adminUserID,
      totalBudget: totalBudget,
      memberUserIDs: [adminUserID],
      createdAt: DateTime.now(),
    );
    await doc.set(group.toMap());
    return doc.id;
  }

  Future<void> updateGroup(FamilyGroup group) async {
    await _groups.doc(group.groupID).update(group.toMap());
  }

  Future<void> deleteGroup(String groupID) async {
    await _groups.doc(groupID).delete();
  }

  // ── Members ───────────────────────────────────────────────────────────────

  Future<List<FamilyMember>> getMembers(String groupID) async {
    final snap = await _members(groupID).get();
    final list = snap.docs.map((d) => FamilyMember.fromMap(d.data())).toList();
    list.sort((a, b) {
      if (a.isAdmin && !b.isAdmin) return -1;
      if (!a.isAdmin && b.isAdmin) return 1;
      return a.displayName.compareTo(b.displayName);
    });
    return list;
  }

  Future<String> addMember({
    required String groupID,
    required String userID,
    required String displayName,
    required String role,
    required double budgetAllocation,
  }) async {
    final doc = _members(groupID).doc();
    final member = FamilyMember(
      memberID: doc.id,
      groupID: groupID,
      userID: userID,
      displayName: displayName,
      role: role,
      budgetAllocation: budgetAllocation,
      spent: 0.0,
      joinedAt: DateTime.now(),
    );
    await doc.set(member.toMap());
    await _groups.doc(groupID).update({
      'memberUserIDs': FieldValue.arrayUnion([userID]),
    });
    return doc.id;
  }

  Future<void> updateMember(FamilyMember member) async {
    await _members(member.groupID).doc(member.memberID).update(member.toMap());
  }

  Future<void> updateMemberSpent(
      String groupID, String memberID, double spent) async {
    await _members(groupID).doc(memberID).update({'spent': spent});
  }

  Future<void> removeMember(
      String groupID, String memberID, String userID) async {
    await _members(groupID).doc(memberID).delete();
    await _groups.doc(groupID).update({
      'memberUserIDs': FieldValue.arrayRemove([userID]),
    });
  }

  // ── Shared Expenses ───────────────────────────────────────────────────────

  Future<List<SharedExpense>> getSharedExpenses(String groupID) async {
    final snap =
        await _expenses(groupID).orderBy('date', descending: true).get();
    return snap.docs.map((d) => SharedExpense.fromMap(d.data())).toList();
  }

  Future<String> addSharedExpense({
    required String groupID,
    required String name,
    required double amount,
    required String paidByUserID,
    required String paidByName,
    required DateTime date,
    required String categoryIcon,
    String? linkedTransactionID,
  }) async {
    final doc = _expenses(groupID).doc();
    final expense = SharedExpense(
      expenseID: doc.id,
      groupID: groupID,
      name: name,
      amount: amount,
      paidByUserID: paidByUserID,
      paidByName: paidByName,
      date: date,
      categoryIcon: categoryIcon,
      linkedTransactionID: linkedTransactionID,
    );
    await doc.set(expense.toMap());
    return doc.id;
  }

  Future<void> deleteSharedExpense(String groupID, String expenseID) async {
    await _expenses(groupID).doc(expenseID).delete();
  }
}
