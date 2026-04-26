import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class EmailVerificationViewModel extends ChangeNotifier {
  final fb.FirebaseAuth _auth;
  Timer? _pollTimer;

  EmailVerificationViewModel({fb.FirebaseAuth? auth})
      : _auth = auth ?? fb.FirebaseAuth.instance;

  bool _isLoading = false;
  bool _emailSent = false;
  bool _isVerified = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get emailSent => _emailSent;
  bool get isVerified => _isVerified;
  String? get error => _error;
  String get email => _auth.currentUser?.email ?? '';

  Future<bool> sendVerificationEmail({bool force = false}) async {
    // Don't auto-send twice in the same session. `force: true` (Resend) skips this.
    if (_emailSent && !force) return true;
    if (_isLoading) return false;

    final user = _auth.currentUser;
    if (user == null) {
      _error = 'You must be signed in.';
      notifyListeners();
      return false;
    }
    if (user.emailVerified) {
      _isVerified = true;
      notifyListeners();
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await user.sendEmailVerification();
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

  Future<bool> checkVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await user.reload();
      final refreshed = _auth.currentUser;
      _isVerified = refreshed?.emailVerified ?? false;
      notifyListeners();
      return _isVerified;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void startAutoCheck({Duration interval = const Duration(seconds: 4)}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (timer) async {
      final verified = await checkVerified();
      if (verified) timer.cancel();
    });
  }

  void stopAutoCheck() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    stopAutoCheck();
    super.dispose();
  }

  String _mapError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Failed to send verification email.';
    }
  }
}
