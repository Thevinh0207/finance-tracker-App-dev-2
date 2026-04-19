import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../Model/User.dart';
import '../Repository/UserRepository.dart';

class SignUpViewModel extends ChangeNotifier {
  final fb.FirebaseAuth _auth;
  final UserRepository _userRepo;

  SignUpViewModel({
    fb.FirebaseAuth? auth,
    UserRepository? userRepo,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _userRepo = userRepo ?? UserRepository();

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  bool _isLoading = false;
  String? _error;
  User? _user;

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  bool get hidePassword => _hidePassword;
  bool get hideConfirmPassword => _hideConfirmPassword;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  void setFirstName(String v) => _firstName = v.trim();
  void setLastName(String v) => _lastName = v.trim();
  void setEmail(String v) => _email = v.trim();
  void setPassword(String v) => _password = v;
  void setConfirmPassword(String v) => _confirmPassword = v;

  void togglePasswordVisibility() {
    _hidePassword = !_hidePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _hideConfirmPassword = !_hideConfirmPassword;
    notifyListeners();
  }

  String? _validate() {
    if (_firstName.isEmpty ||
        _lastName.isEmpty ||
        _email.isEmpty ||
        _password.isEmpty) {
      return 'Please fill in all fields.';
    }
    if (!_email.contains('@')) return 'Please enter a valid email.';
    if (_password.length < 6) return 'Password must be at least 6 characters.';
    if (_password != _confirmPassword) return 'Passwords do not match.';
    return null;
  }

  Future<bool> signUp() async {
    final validationError = _validate();
    if (validationError != null) {
      _error = validationError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      final uid = cred.user?.uid;
      if (uid == null) {
        _error = 'Sign up failed.';
        return false;
      }

      final user = User(
        userID: uid,
        firstName: _firstName,
        lastName: _lastName,
        email: _email,
      );
      await _userRepo.create(user);
      _user = user;
      return true;
    } on fb.FirebaseAuthException catch (e) {
      dev.log('Auth error: ${e.code} — ${e.message}', name: 'SignUp');
      _error = _mapAuthError(e);
      return false;
    } on FirebaseException catch (e) {
      dev.log('Firestore error: ${e.code} — ${e.message}', name: 'SignUp');
      _error = 'Database error: ${e.code}. ${e.message ?? ''}';
      return false;
    } catch (e, st) {
      dev.log('Unknown error: $e', name: 'SignUp', stackTrace: st);
      _error = 'Unexpected error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is disabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Sign up failed.';
    }
  }
}
