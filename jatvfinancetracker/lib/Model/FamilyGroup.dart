import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyGroup {
  final String groupID;
  final String groupName;
  final String adminUserID;
  final double totalBudget;
  final List<String> memberUserIDs;
  final DateTime createdAt;

  FamilyGroup({
    required this.groupID,
    required this.groupName,
    required this.adminUserID,
    required this.totalBudget,
    required this.memberUserIDs,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'groupID': groupID,
        'groupName': groupName,
        'adminUserID': adminUserID,
        'totalBudget': totalBudget,
        'memberUserIDs': memberUserIDs,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory FamilyGroup.fromMap(Map<String, dynamic> map) => FamilyGroup(
        groupID: map['groupID'] as String,
        groupName: map['groupName'] as String,
        adminUserID: map['adminUserID'] as String,
        totalBudget: (map['totalBudget'] as num).toDouble(),
        memberUserIDs: List<String>.from(map['memberUserIDs'] as List? ?? []),
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );

  FamilyGroup copyWith({String? groupName, double? totalBudget}) => FamilyGroup(
        groupID: groupID,
        groupName: groupName ?? this.groupName,
        adminUserID: adminUserID,
        totalBudget: totalBudget ?? this.totalBudget,
        memberUserIDs: memberUserIDs,
        createdAt: createdAt,
      );
}
