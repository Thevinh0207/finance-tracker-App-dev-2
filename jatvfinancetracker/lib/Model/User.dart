import 'package:uuid/uuid.dart';

class User {
  final String userID;
  final String firstName;
  final String lastName;
  final String email;

  User({
    required this.userID,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  User._({
    required this.userID,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory User.create({
    required String firstName,
    required String lastName,
    required String email,
  }) {
    return User._(
      userID: const Uuid().v4(),
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userID: map['userID'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
    );
  }

  User copyWith({
    String? firstName,
    String? lastName,
    String? email,
  }) {
    return User(
      userID: userID,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
    );
  }
}
