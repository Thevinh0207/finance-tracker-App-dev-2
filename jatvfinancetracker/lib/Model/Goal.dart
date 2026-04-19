import 'package:cloud_firestore/cloud_firestore.dart';

import '../helper/GoalType.dart';

class Goal {
  final String goalID;
  final String userID;
  final String goalName;
  final double goalAmount;
  final double currentAmount;
  final GoalType goalType;
  final DateTime startDate;
  final DateTime targetDate;
  final String? note;

  Goal({
    required this.goalID,
    required this.userID,
    required this.goalName,
    required this.goalAmount,
    required this.currentAmount,
    required this.goalType,
    required this.startDate,
    required this.targetDate,
    this.note,
  });

  double get getProgress =>
      goalAmount == 0 ? 0 : (currentAmount / goalAmount).clamp(0, 1);

  bool get getIsCompleted => currentAmount >= goalAmount;

  Map<String, dynamic> toMap() {
    return {
      'goalID': goalID,
      'userID': userID,
      'goalName': goalName,
      'goalAmount': goalAmount,
      'currentAmount': currentAmount,
      'goalType': goalType.name,
      'startDate': Timestamp.fromDate(startDate),
      'targetDate': Timestamp.fromDate(targetDate),
      'note': note,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      goalID: map['goalID'] as String,
      userID: map['userID'] as String,
      goalName: map['goalName'] as String,
      goalAmount: (map['goalAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      goalType: GoalType.values.byName(map['goalType'] as String),
      startDate: (map['startDate'] as Timestamp).toDate(),
      targetDate: (map['targetDate'] as Timestamp).toDate(),
      note: map['note'] as String?,
    );
  }

  Goal copyWith({
    String? goalName,
    double? goalAmount,
    double? currentAmount,
    GoalType? goalType,
    DateTime? targetDate,
    String? note,
  }) {
    return Goal(
      goalID: goalID,
      userID: userID,
      goalName: goalName ?? this.goalName,
      goalAmount: goalAmount ?? this.goalAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      goalType: goalType ?? this.goalType,
      startDate: startDate,
      targetDate: targetDate ?? this.targetDate,
      note: note ?? this.note,
    );
  }
}
