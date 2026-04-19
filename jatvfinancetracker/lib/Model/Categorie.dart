import '../helper/TransactionType.dart';

class Categorie {
  final String categoryID;
  final String userID;
  final String categoryName;
  final TransactionType type;

  Categorie({
    required this.categoryID,
    required this.userID,
    required this.categoryName,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryID': categoryID,
      'userID': userID,
      'categoryName': categoryName,
      'type': type.name,
    };
  }

  factory Categorie.fromMap(Map<String, dynamic> map) {
    return Categorie(
      categoryID: map['categoryID'] as String,
      userID: map['userID'] as String,
      categoryName: map['categoryName'] as String,
      type: TransactionType.values.byName(map['type'] as String),
    );
  }

  Categorie copyWith({
    String? categoryName,
    TransactionType? type,
    String? icon,
    String? color,
  }) {
    return Categorie(
      categoryID: categoryID,
      userID: userID,
      categoryName: categoryName ?? this.categoryName,
      type: type ?? this.type,
    );
  }
}
