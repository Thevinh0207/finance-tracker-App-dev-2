import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../Model/User.dart';
import '../Repository/UserRepository.dart';

class TwoFactorViewModel extends ChangeNotifier {
  final fb.MultiFactorResolver _resolver;
  final UserRepository _userRepo;

  TwoFactorViewModel({
    required fb.MultiFactorResolver resolver,
    UserRepository? userRepo,
  })  : _resolver = resolver,
        _userRepo = userRepo ?? UserRepository();

  String? _verificationId;
  bool _codeSent = false;
  bool _isLoading = false;
  String? _error;
  User? _user;

  bool get codeSent => _codeSent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  String get phoneHint {
    final hints = _resolver.hints;
    if (hints.isEmpty) return '';
    final hint = hints.first;
    if (hint is fb.PhoneMultiFactorInfo) {
      return hint.phoneNumber ?? '';
    }
    return hint.displayName ?? '';
  }

  Future<void> sendCode() async {
    final hints = _resolver.hints;
    if (hints.isEmpty) {
      _error = 'No second factor registered for this account.';
      notifyListeners();
      return;
    }
    final hint = hints.first;
    if (hint is! fb.PhoneMultiFactorInfo) {
      _error = 'Unsupported second factor.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await fb.FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: _resolver.session,
        multiFactorInfo: hint,
        verificationCompleted: (credential) async {
          await _resolve(credential);
        },
        verificationFailed: (e) {
          _error = e.message ?? 'Verification failed.';
          _isLoading = false;
          notifyListeners();
        },
        codeSent: (verificationId, _) {
          _verificationId = verificationId;
          _codeSent = true;
          _isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyCode(String smsCode) async {
    if (_verificationId == null) {
      _error = 'No verification in progress.';
      notifyListeners();
      return false;
    }
    if (smsCode.length != 6) {
      _error = 'Please enter all 6 digits.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final credential = fb.PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
    return _resolve(credential);
  }

  Future<bool> _resolve(fb.PhoneAuthCredential credential) async {
    try {
      final assertion = fb.PhoneMultiFactorGenerator.getAssertion(credential);
      final cred = await _resolver.resolveSignIn(assertion);
      final uid = cred.user?.uid;
      if (uid == null) {
        _error = 'Sign in failed.';
        return false;
      }
      _user = await _userRepo.getById(uid);
      if (_user == null) {
        _error = 'Profile not found.';
        return false;
      }
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
      case 'invalid-verification-code':
        return 'Incorrect code. Please try again.';
      case 'code-expired':
        return 'Code expired. Please request a new one.';
      case 'session-expired':
        return 'Session expired. Please sign in again.';
      default:
        return e.message ?? 'Verification failed.';
    }
  }
}
