import 'package:flutter/foundation.dart';

import '../Model/Categorie.dart';
import '../Model/Transaction.dart';
import '../helper/TransactionType.dart';
import '../Repository/CategorieRepository.dart';
import '../Repository/TransactionRepository.dart';

class MonthlyData {
  final String label;
  final double income;
  final double expense;

  const MonthlyData({
    required this.label,
    required this.income,
    required this.expense,
  });
}

class MoneyFlowViewModel extends ChangeNotifier {
  final TransactionRepository _tRepo;
  final CategorieRepository _cRepo;

  MoneyFlowViewModel({
    TransactionRepository? tRepo,
    CategorieRepository? cRepo,
  })  : _tRepo = tRepo ?? TransactionRepository(),
        _cRepo = cRepo ?? CategorieRepository();

  List<Transaction> _transactions = const [];
  List<Categorie> _categories = const [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, String> get _categoryNames =>
      {for (final c in _categories) c.categoryID: c.categoryName};

  List<Transaction> get _currentMonthTxns {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();
  }

  double get currentIncome =>
      _sumOf(TransactionType.income, _currentMonthTxns);
  double get currentExpenses =>
      _sumOf(TransactionType.expense, _currentMonthTxns);
  double get netCashFlow => currentIncome - currentExpenses;

  List<MonthlyData> get monthlyData {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final monthOffset = 5 - i;
      final target = DateTime(now.year, now.month - monthOffset, 1);
      final txns = _transactions
          .where((t) => t.date.year == target.year && t.date.month == target.month)
          .toList();
      return MonthlyData(
        label: _monthLabel(target.month),
        income: _sumOf(TransactionType.income, txns),
        expense: _sumOf(TransactionType.expense, txns),
      );
    });
  }

  Map<String, double> get incomeByCategory =>
      _groupByCategory(TransactionType.income, _currentMonthTxns);
  Map<String, double> get expensesByCategory =>
      _groupByCategory(TransactionType.expense, _currentMonthTxns);

  double _sumOf(TransactionType type, List<Transaction> txns) => txns
      .where((t) => t.type == type)
      .fold(0, (sum, t) => sum + t.amount);

  Map<String, double> _groupByCategory(
      TransactionType type, List<Transaction> txns) {
    final names = _categoryNames;
    final result = <String, double>{};
    for (final t in txns.where((t) => t.type == type)) {
      final name = names[t.categoryID] ?? t.categoryID;
      result[name] = (result[name] ?? 0) + t.amount;
    }
    return result;
  }

  String _monthLabel(int month) {
    const labels = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final normalized = ((month - 1) % 12 + 12) % 12;
    return labels[normalized];
  }

  Future<void> load(String userID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
      final results = await Future.wait([
        _tRepo.getByDateRange(userID, sixMonthsAgo, now),
        _cRepo.getByUser(userID),
      ]);
      _transactions = results[0] as List<Transaction>;
      _categories = results[1] as List<Categorie>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String userID) => load(userID);
}
