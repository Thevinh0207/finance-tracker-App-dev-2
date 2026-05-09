import 'package:cloud_firestore/cloud_firestore.dart';

class SharedExpense {
  final String expenseID;
  final String groupID;
  final String name;
  final double amount;
  final String paidByUserID;
  final String paidByName;
  final DateTime date;
  final String categoryIcon;
  final String? linkedTransactionID;

  SharedExpense({
    required this.expenseID,
    required this.groupID,
    required this.name,
    required this.amount,
    required this.paidByUserID,
    required this.paidByName,
    required this.date,
    required this.categoryIcon,
    this.linkedTransactionID,
  });

  Map<String, dynamic> toMap() => {
        'expenseID': expenseID,
        'groupID': groupID,
        'name': name,
        'amount': amount,
        'paidByUserID': paidByUserID,
        'paidByName': paidByName,
        'date': Timestamp.fromDate(date),
        'categoryIcon': categoryIcon,
        'linkedTransactionID': linkedTransactionID,
      };

  factory SharedExpense.fromMap(Map<String, dynamic> map) => SharedExpense(
        expenseID: map['expenseID'] as String,
        groupID: map['groupID'] as String,
        name: map['name'] as String,
        amount: (map['amount'] as num).toDouble(),
        paidByUserID: map['paidByUserID'] as String,
        paidByName: map['paidByName'] as String,
        date: (map['date'] as Timestamp).toDate(),
        categoryIcon: map['categoryIcon'] as String? ?? 'other',
        linkedTransactionID: map['linkedTransactionID'] as String?,
      );
}
