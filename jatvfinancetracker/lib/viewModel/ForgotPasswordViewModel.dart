import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class ForgotPasswordViewModel extends ChangeNotifier {
  final fb.FirebaseAuth _auth;

  ForgotPasswordViewModel({fb.FirebaseAuth? auth})
      : _auth = auth ?? fb.FirebaseAuth.instance;

  String _email = '';
  bool _isLoading = false;
  String? _error;
  bool _sent = false;

  String get email => _email;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get sent => _sent;

  void setEmail(String v) => _email = v.trim();

  Future<bool> sendResetEmail() async {
    if (_email.isEmpty || !_email.contains('@')) {
      _error = 'Please enter a valid email.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: _email);
      _sent = true;
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _error = _mapError(e);
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Failed to send reset email.';
    }
  }
}
