import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../Repository/UserRepository.dart';

class TwoFactorViewModel extends ChangeNotifier {
  final fb.MultiFactorResolver? _resolver;
  final UserRepository _userRepo;

  TwoFactorViewModel({
    fb.MultiFactorResolver? resolver,
    UserRepository? userRepo,
  })  : _resolver = resolver,
        _userRepo = userRepo ?? UserRepository();

  fb.MultiFactorResolver? get resolver => _resolver;
  UserRepository get userRepo => _userRepo;
}
