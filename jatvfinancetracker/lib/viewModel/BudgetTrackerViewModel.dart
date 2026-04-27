import 'package:flutter/foundation.dart';

import '../Model/Budget.dart';
import '../Model/Categorie.dart';
import '../Model/Transaction.dart';
import '../helper/TransactionType.dart';
import '../Repository/BudgetRepository.dart';
import '../Repository/CategorieRepository.dart';
import '../Repository/TransactionRepository.dart';

class BudgetProgress {
  final Budget budget;
  final Categorie? category;
  final double spent;
  final int transactionCount;

  const BudgetProgress({
    required this.budget,
    required this.category,
    required this.spent,
    required this.transactionCount,
  });

  double get remaining => (budget.amount - spent).clamp(0, double.infinity);
  double get percentUsed =>
      budget.amount <= 0 ? 0 : (spent / budget.amount).clamp(0, 1);
  double get rawPercentUsed =>
      budget.amount <= 0 ? 0 : spent / budget.amount;
  bool get isOverBudget => spent > budget.amount;
  bool get isApproachingLimit => rawPercentUsed >= 0.8 && !isOverBudget;
  bool get isHealthy => rawPercentUsed < 0.8;
}

class CategoryOption {
  final String id;
  final String name;
  const CategoryOption({required this.id, required this.name});
}

class BudgetTrackerViewModel extends ChangeNotifier {
  final BudgetRepository _bRepo;
  final CategorieRepository _cRepo;
  final TransactionRepository _tRepo;

  BudgetTrackerViewModel({
    BudgetRepository? bRepo,
    CategorieRepository? cRepo,
    TransactionRepository? tRepo,
  })  : _bRepo = bRepo ?? BudgetRepository(),
        _cRepo = cRepo ?? CategorieRepository(),
        _tRepo = tRepo ?? TransactionRepository();

  List<Budget> _budgets = const [];
  List<Categorie> _categories = const [];
  List<Transaction> _transactions = const [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Categorie> get categories => _categories;

  /// Categories available for budgets — combines the categories collection
  /// (expense type) with any unique categoryIDs found in expense transactions.
  /// This way users see categories they created via the transaction flow even
  /// if they haven't been catalogued elsewhere.
  List<CategoryOption> get availableCategories {
    final byId = {for (final c in _categories) c.categoryID: c};
    final result = <String, String>{};

    for (final c in _categories.where((c) => c.type == TransactionType.expense)) {
      result[c.categoryID] = c.categoryName;
    }
    for (final t in _transactions.where((t) => t.type == TransactionType.expense)) {
      if (!result.containsKey(t.categoryID)) {
        result[t.categoryID] = byId[t.categoryID]?.categoryName ?? t.categoryID;
      }
    }

    final list = result.entries
        .map((e) => CategoryOption(id: e.key, name: e.value))
        .toList()
      ..sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  List<BudgetProgress> get progressList {
    final byCat = {for (final c in _categories) c.categoryID: c};
    final list = _budgets.map((b) {
      final txns = _transactions.where((t) =>
          t.type == TransactionType.expense &&
          t.categoryID == b.categoryID &&
          !t.date.isBefore(b.startDate) &&
          !t.date.isAfter(b.endDate));
      final spent = txns.fold<double>(0, (s, t) => s + t.amount);
      return BudgetProgress(
        budget: b,
        category: byCat[b.categoryID],
        spent: spent,
        transactionCount: txns.length,
      );
    }).toList()
      ..sort((a, b) => b.rawPercentUsed.compareTo(a.rawPercentUsed));
    return list;
  }

  double get totalBudget =>
      _budgets.fold<double>(0, (s, b) => s + b.amount);
  double get totalSpent =>
      progressList.fold<double>(0, (s, p) => s + p.spent);
  double get totalRemaining =>
      (totalBudget - totalSpent).clamp(0, double.infinity);
  double get totalPercentUsed =>
      totalBudget <= 0 ? 0 : (totalSpent / totalBudget).clamp(0, 1);

  int get alertCount =>
      progressList.where((p) => p.isApproachingLimit || p.isOverBudget).length;
  bool get hasAlerts => alertCount > 0;

  Future<void> load(String userID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final errors = <String>[];

    // Load each piece independently so a partial failure (e.g. missing
    // composite index) doesn't blank out the whole screen.
    try {
      final allBudgets = await _bRepo.getByUser(userID);
      final now = DateTime.now();
      _budgets = allBudgets
          .where((b) => !b.startDate.isAfter(now) && !b.endDate.isBefore(now))
          .toList();
    } catch (e) {
      _budgets = const [];
      errors.add('budgets: $e');
    }

    try {
      _categories = await _cRepo.getByUser(userID);
    } catch (e) {
      _categories = const [];
      errors.add('categories: $e');
    }

    try {
      _transactions = await _tRepo.getByUser(userID);
    } catch (e) {
      _transactions = const [];
      errors.add('transactions: $e');
    }

    _error = errors.isEmpty ? null : errors.join(' | ');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh(String userID) => load(userID);

  Future<void> createBudget({
    required String userID,
    required String budgetName,
    String? categoryID,
    String? newCategoryName,
    required double amount,
    required BudgetPeriod period,
  }) async {
    String resolvedCategoryID;
    if (categoryID != null && categoryID.isNotEmpty) {
      resolvedCategoryID = categoryID;
    } else if (newCategoryName != null && newCategoryName.trim().isNotEmpty) {
      final created = Categorie(
        categoryID: '',
        userID: userID,
        categoryName: newCategoryName.trim(),
        type: TransactionType.expense,
      );
      resolvedCategoryID = await _cRepo.create(created);
    } else {
      throw Exception('Pick a category or enter a new one.');
    }

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = _periodEnd(start, period);
    final budget = Budget(
      budgetID: '',
      userID: userID,
      categoryID: resolvedCategoryID,
      budgetName: budgetName,
      amount: amount,
      period: period,
      startDate: start,
      endDate: end,
    );
    await _bRepo.create(budget);
    await load(userID);
  }

  Future<void> deleteBudget(String userID, String budgetID) async {
    await _bRepo.delete(budgetID);
    await load(userID);
  }

  DateTime _periodEnd(DateTime start, BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return start.add(const Duration(days: 7));
      case BudgetPeriod.monthly:
        return DateTime(start.year, start.month + 1, start.day);
      case BudgetPeriod.yearly:
        return DateTime(start.year + 1, start.month, start.day);
    }
  }
}
