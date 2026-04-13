import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:bcrypt/bcrypt.dart';

class User {
  final String userID;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final List<Transaction> transaction;



  User
    ({required this.userID,
        required this.firstName,
        required this.lastName,
        required this.email,
        required this.password,
        required this.transaction
    });

  User._privateConstructor({
    required this.userID,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.transaction
  });



  Map<String, dynamic> toMap(){
    return {
      'userID'      : userID,
      'firstName'   : firstName,
      'lastName'    : lastName,
      'email'       : email,
      'password'    : password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map){
    return User(
      userID: map['userID'],
      firstName: map['firstName'],
      lastName: map['lastname'],
      email: map['email'],
      password: map['password'],
      transaction: map['transaction']
    );
  }

  //create the uuid + hash the password when creating a User object
  factory User.create({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    List<Transaction> transaction = const [],
  })  {
    final String userID = const Uuid().v4();
    final String hashedPassword = BCrypt.hashpw(
      password,
      BCrypt.gensalt(),
    );

    return User._privateConstructor(
      userID: userID,
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: hashedPassword,
      transaction: transaction,
    );
  }
  
  bool verifyPassword(String inputPassword) {
    return BCrypt.checkpw(inputPassword, password);
  }

}