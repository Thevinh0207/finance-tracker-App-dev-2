import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class PasswordResetViewModel extends ChangeNotifier {
  final fb.FirebaseAuth _auth;

  PasswordResetViewModel({fb.FirebaseAuth? auth})
      : _auth = auth ?? fb.FirebaseAuth.instance;

  String _email = '';
  bool _isLoading = false;
  bool _emailSent = false;
  String? _error;

  String get email => _email;
  bool get isLoading => _isLoading;
  bool get emailSent => _emailSent;
  String? get error => _error;

  void setEmail(String value) => _email = value.trim();

  Future<bool> sendResetEmail([String? overrideEmail, bool force = false]) async {
    if (_emailSent && !force) return true;
    if (_isLoading) return false;

    final target = (overrideEmail ?? _email).trim();
    if (target.isEmpty || !target.contains('@')) {
      _error = 'Please enter a valid email.';
      notifyListeners();
      return false;
    }
    _email = target;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: target);
      _emailSent = true;
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
