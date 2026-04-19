import 'package:cloud_firestore/cloud_firestore.dart';

enum BudgetPeriod { weekly, monthly, yearly }

class Budget {
  final String budgetID;
  final String userID;
  final String categoryID;
  final String budgetName;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;

  Budget({
    required this.budgetID,
    required this.userID,
    required this.categoryID,
    required this.budgetName,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'budgetID': budgetID,
      'userID': userID,
      'categoryID': categoryID,
      'budgetName': budgetName,
      'amount': amount,
      'period': period.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      budgetID: map['budgetID'] as String,
      userID: map['userID'] as String,
      categoryID: map['categoryID'] as String,
      budgetName: map['budgetName'] as String,
      amount: (map['amount'] as num).toDouble(),
      period: BudgetPeriod.values.byName(map['period'] as String),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
    );
  }

  Budget copyWith({
    String? categoryID,
    String? budgetName,
    double? amount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Budget(
      budgetID: budgetID,
      userID: userID,
      categoryID: categoryID ?? this.categoryID,
      budgetName: budgetName ?? this.budgetName,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
