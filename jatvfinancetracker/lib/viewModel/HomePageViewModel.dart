import 'package:flutter/foundation.dart';

import '../Model/User.dart';
import '../Model/Transaction.dart';
import '../helper/TransactionType.dart';
import '../Repository/UserRepository.dart';
import '../Repository/TransactionRepository.dart';

class HomePageViewModel extends ChangeNotifier {
  final UserRepository _userRepo;
  final TransactionRepository _tRepo;

  HomePageViewModel({
    UserRepository? userRepo,
    TransactionRepository? tRepo,
  })  : _userRepo = userRepo ?? UserRepository(),
        _tRepo = tRepo ?? TransactionRepository();

  User? _user;
  List<Transaction> _transactions = const [];
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get displayName =>
      _user == null ? '' : '${_user!.firstName} ${_user!.lastName}';

  double get income => _sumOf(TransactionType.income);
  double get expenses => _sumOf(TransactionType.expense);
  double get totalBalance => income - expenses;
  double get savings => totalBalance > 0 ? totalBalance : 0;

  double _sumOf(TransactionType type) => _transactions
      .where((t) => t.type == type)
      .fold(0, (sum, t) => sum + t.amount);

  Future<void> load(String userID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _userRepo.getById(userID),
        _tRepo.getByUser(userID),
      ]);
      _user = results[0] as User?;
      _transactions = results[1] as List<Transaction>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String userID) => load(userID);
}
