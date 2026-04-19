import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../Model/User.dart';
import '../Repository/UserRepository.dart';

class LoginViewModel extends ChangeNotifier {
  final fb.FirebaseAuth _auth;
  final UserRepository _userRepo;

  LoginViewModel({
    fb.FirebaseAuth? auth,
    UserRepository? userRepo,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _userRepo = userRepo ?? UserRepository();

  String _email = '';
  String _password = '';
  bool _rememberMe = false;
  bool _hidePassword = true;

  bool _isLoading = false;
  String? _error;
  User? _user;
  fb.MultiFactorResolver? _mfaResolver;

  String get email => _email;
  String get password => _password;
  bool get rememberMe => _rememberMe;
  bool get hidePassword => _hidePassword;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  fb.MultiFactorResolver? get mfaResolver => _mfaResolver;
  bool get mfaRequired => _mfaResolver != null;

  void setEmail(String value) {
    _email = value.trim();
  }

  void setPassword(String value) {
    _password = value;
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _hidePassword = !_hidePassword;
    notifyListeners();
  }

  String? _validate() {
    if (_email.isEmpty) return 'Please enter your email.';
    if (!_email.contains('@')) return 'Please enter a valid email.';
    if (_password.isEmpty) return 'Please enter your password.';
    return null;
  }

  Future<bool> login() async {
    final validationError = _validate();
    if (validationError != null) {
      _error = validationError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _mfaResolver = null;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      final uid = cred.user?.uid;
      if (uid == null) {
        _error = 'Login failed.';
        return false;
      }
      _user = await _userRepo.getById(uid);
      if (_user == null) {
        _error = 'Profile not found.';
        return false;
      }
      return true;
    } on fb.FirebaseAuthMultiFactorException catch (e) {
      _mfaResolver = e.resolver;
      return false;
    } on fb.FirebaseAuthException catch (e) {
      _error = _mapAuthError(e);
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _email = '';
    _password = '';
    notifyListeners();
  }

  String _mapAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Login failed.';
    }
  }
}
