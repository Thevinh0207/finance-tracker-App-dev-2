import 'package:uuid/uuid.dart';
import '';

class User {
  int? _userID;
  String _firstName;
  String _lastName;
  String _email;
  String _password;
  double _income;
  double _moneySpent;

  User({
    required int? userID,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required double income,
    required double moneySpent,
  })  : _userID = userID,
        _firstName = firstName,
        _lastName = lastName,
        _email = email,
        _password = password,
        _income = income,
        _moneySpent = moneySpent;


  User.UserNoIDConstructor({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required double income,
    required double moneySpent
  }): _firstName = firstName,
      _lastName = lastName,
      _email = email,
      _password = password,
      _income = income,
      _moneySpent = moneySpent;

  double get moneySpent => _moneySpent;

  set moneySpent(double value) {
    _moneySpent = value;
  }

  double get income => _income;

  set income(double value) {
    _income = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get lastName => _lastName;

  set lastName(String value) {
    _lastName = value;
  }

  String get firstName => _firstName;

  set firstName(String value) {
    _firstName = value;
  }

  int? get userID => _userID;

  set userID(int value) {
    _userID = value;
  }

}


