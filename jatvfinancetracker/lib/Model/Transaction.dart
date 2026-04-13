import '../helper/TransactionType.dart';

class Transaction {
  int? transactionID;
  String transactionName;
  TransactionType type;
  int? categoryID;
  double amount;
  String dateOfTransaction;
  String time;

  Transaction({
    required this.transactionID,
    required this.transactionName,
    required this.type,
    required this.categoryID,
    required this.amount,
    required this.dateOfTransaction,
    required this.time,
  });

  Transaction.noIdConstructor({
    required String transactionName,
    required TransactionType type,
    required double amount,
    required String dateOfTransaction,
    required String time,
  }) :  transactionName = transactionName,
        type = type,
        amount = amount,
        dateOfTransaction = dateOfTransaction,
        time = time;

  Map<String, dynamic> toMap() {
    return {
      'transactionID': transactionID,
      'transactionName': transactionName,
      'categoryID': categoryID,
      'amount': amount,
      'dateOfTransaction': dateOfTransaction,
      'time': time,
    };
  }
}
