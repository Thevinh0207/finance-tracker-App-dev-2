import 'package:cloud_firestore/cloud_firestore.dart';

class Categorie {
  int? categoryID;
  String categoryName;
  List<Transaction> transaction;
  String userID;

  Categorie({
  required this.categoryID,
  required this.categoryName,
  required this.transaction,
  required this.userID
  });



}