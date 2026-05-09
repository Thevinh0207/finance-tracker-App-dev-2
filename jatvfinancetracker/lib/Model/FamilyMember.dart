import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyMember {
  final String memberID;
  final String groupID;
  final String userID;
  final String displayName;
  final String role; // 'admin' | 'member'
  final double budgetAllocation;
  final double spent;
  final DateTime joinedAt;

  FamilyMember({
    required this.memberID,
    required this.groupID,
    required this.userID,
    required this.displayName,
    required this.role,
    required this.budgetAllocation,
    required this.spent,
    required this.joinedAt,
  });

  bool get isAdmin => role == 'admin';
  double get progress =>
      budgetAllocation > 0 ? (spent / budgetAllocation).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toMap() => {
        'memberID': memberID,
        'groupID': groupID,
        'userID': userID,
        'displayName': displayName,
        'role': role,
        'budgetAllocation': budgetAllocation,
        'spent': spent,
        'joinedAt': Timestamp.fromDate(joinedAt),
      };

  factory FamilyMember.fromMap(Map<String, dynamic> map) => FamilyMember(
        memberID: map['memberID'] as String,
        groupID: map['groupID'] as String,
        userID: map['userID'] as String,
        displayName: map['displayName'] as String,
        role: map['role'] as String,
        budgetAllocation: (map['budgetAllocation'] as num).toDouble(),
        spent: (map['spent'] as num).toDouble(),
        joinedAt: (map['joinedAt'] as Timestamp).toDate(),
      );

  FamilyMember copyWith({
    double? spent,
    double? budgetAllocation,
    String? role,
  }) =>
      FamilyMember(
        memberID: memberID,
        groupID: groupID,
        userID: userID,
        displayName: displayName,
        role: role ?? this.role,
        budgetAllocation: budgetAllocation ?? this.budgetAllocation,
        spent: spent ?? this.spent,
        joinedAt: joinedAt,
      );
}
