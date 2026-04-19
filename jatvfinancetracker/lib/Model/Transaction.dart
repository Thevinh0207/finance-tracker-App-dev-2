import 'package:cloud_firestore/cloud_firestore.dart';
import '../helper/TransactionType.dart';

class Transaction {
  final String transactionID;
  final String userID;
  final String transactionName;
  final TransactionType type;
  final String categoryID;
  final String? budgetID;
  final double amount;
  final DateTime date;
  final String? note;

  Transaction({
    required this.transactionID,
    required this.userID,
    required this.transactionName,
    required this.type,
    required this.categoryID,
    this.budgetID,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionID': transactionID,
      'userID': userID,
      'transactionName': transactionName,
      'type': type.name,
      'categoryID': categoryID,
      'budgetID': budgetID,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      transactionID: map['transactionID'] as String,
      userID: map['userID'] as String,
      transactionName: map['transactionName'] as String,
      type: TransactionType.values.byName(map['type'] as String),
      categoryID: map['categoryID'] as String,
      budgetID: map['budgetID'] as String?,
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      note: map['note'] as String?,
    );
  }

  Transaction copyWith({
    String? transactionName,
    TransactionType? type,
    String? categoryID,
    String? budgetID,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      transactionID: transactionID,
      userID: userID,
      transactionName: transactionName ?? this.transactionName,
      type: type ?? this.type,
      categoryID: categoryID ?? this.categoryID,
      budgetID: budgetID ?? this.budgetID,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
