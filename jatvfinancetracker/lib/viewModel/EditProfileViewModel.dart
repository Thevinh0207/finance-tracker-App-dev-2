import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../Model/User.dart';
import '../Repository/UserRepository.dart';

class EditProfileViewModel extends ChangeNotifier {
  final fb.FirebaseAuth _auth;
  final UserRepository _userRepo;

  EditProfileViewModel({
    fb.FirebaseAuth? auth,
    UserRepository? userRepo,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _userRepo = userRepo ?? UserRepository();

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _originalEmail = '';
  bool _isSaving = false;
  String? _error;
  String? _successMessage;

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get emailChanged =>
      _email.trim().toLowerCase() != _originalEmail.trim().toLowerCase();

  void seed(User user) {
    _firstName = user.firstName;
    _lastName = user.lastName;
    _email = user.email;
    _originalEmail = user.email;
  }

  void setFirstName(String v) {
    _firstName = v;
  }

  void setLastName(String v) {
    _lastName = v;
  }

  void setEmail(String v) {
    _email = v.trim();
  }

  String? _validate() {
    if (_firstName.trim().isEmpty || _lastName.trim().isEmpty) {
      return 'First and last name are required.';
    }
    if (_email.trim().isEmpty || !_email.contains('@')) {
      return 'Please enter a valid email.';
    }
    return null;
  }

  Future<bool> save(String userID) async {
    final v = _validate();
    if (v != null) {
      _error = v;
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // 1) If email changed, ask Firebase Auth to send a verify-before-update
      //    link to the new address. The actual change happens once the user
      //    clicks that link.
      if (emailChanged) {
        final user = _auth.currentUser;
        if (user == null) {
          _error = 'You must be signed in.';
          return false;
        }
        try {
          await user.verifyBeforeUpdateEmail(_email.trim());
        } on fb.FirebaseAuthException catch (e) {
          _error = _mapAuthError(e);
          return false;
        }
      }

      // 2) Persist name/email in Firestore. Firestore is the app's source
      //    of truth for the displayed user info — Firebase Auth only flips
      //    the email after the user verifies the link.
      final next = User(
        userID: userID,
        firstName: _firstName.trim(),
        lastName: _lastName.trim(),
        email: _email.trim(),
      );
      await _userRepo.update(next);

      _originalEmail = _email.trim();
      _successMessage = emailChanged
          ? 'Profile saved. Check your new email to confirm the change.'
          : 'Profile saved.';
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String _mapAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'email-already-in-use':
        return 'That email is already in use.';
      case 'requires-recent-login':
        return 'For security, please log out and log in again before changing your email.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Failed to update email.';
    }
  }
}
