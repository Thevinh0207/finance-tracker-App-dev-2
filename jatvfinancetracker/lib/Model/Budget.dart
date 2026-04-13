import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
    int? budgetID;
    String budgetName;
    List<Transaction> transaction;
    String categoryID;
    String userID;

    Budget({
        required this.budgetID,
        required this.budgetName,
        required this.transaction,
        required this.categoryID,
        required this.userID
    });

    Budget.noBudgetIdConstructor({
        required this.budgetName,
        required this.transaction,
        required this.categoryID,
        required this.userID
    });

    Map<String, dynamic> toMap(){
        return {
          'budgetID'    : budgetID,
          'budgetName'  : budgetName,
          'transaction' : transaction,
          'categoryID'  : categoryID,
          'userID'      : userID
        };
    }

    factory Budget.fromMap(Map<String, dynamic> map){
        return Budget(
            budgetID:       map['budgetID'],
            budgetName:     map['budgerName'],
            transaction:    map['transaction'],
            categoryID:     map['categoryID'],
            userID:         map['userID']
        );
    }

}