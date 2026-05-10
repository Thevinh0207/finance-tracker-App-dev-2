import 'package:flutter/material.dart';

import '../Model/Categorie.dart';
import '../Model/Goal.dart';
import '../Model/Transaction.dart';
import '../Repository/CategorieRepository.dart';
import '../Repository/GoalRepository.dart';
import '../Repository/TransactionRepository.dart';
import '../helper/GoalType.dart';
import '../helper/TransactionType.dart';

/// Intent for a *decrease* in goal amount.
///   - [withdrawal] → log a transaction reflecting the money coming back out.
///   - [correction] → silent update (typo fix, stale value, etc.).
enum ProgressDecreaseIntent { withdrawal, correction }

class GoalsViewModel extends ChangeNotifier {
  final GoalRepository _goalRepo;
  final TransactionRepository _txRepo;
  final CategorieRepository _catRepo;
  final String userID;

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  GoalsViewModel({
    required this.userID,
    GoalRepository? goalRepository,
    TransactionRepository? transactionRepository,
    CategorieRepository? categoryRepository,
  })  : _goalRepo = goalRepository ?? GoalRepository(),
        _txRepo = transactionRepository ?? TransactionRepository(),
        _catRepo = categoryRepository ?? CategorieRepository();

  List<Goal> get goals => List.unmodifiable(_goals);
  List<Goal> get activeGoals =>
      _goals.where((g) => !g.getIsCompleted).toList();
  List<Goal> get completedGoals =>
      _goals.where((g) => g.getIsCompleted).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalSaved =>
      _goals.fold(0.0, (sum, g) => sum + g.currentAmount);
  double get totalTarget =>
      _goals.fold(0.0, (sum, g) => sum + g.goalAmount);
  double get overallProgress =>
      totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;
  double get overallPercentage => overallProgress * 100;

  String get insightMessage {
    if (activeGoals.isEmpty) {
      if (completedGoals.isNotEmpty) {
        return 'Amazing! You\'ve completed all your goals. Set new ones to keep growing!';
      }
      return 'Add your first financial goal to start tracking your progress!';
    }
    final topGoal = activeGoals
        .reduce((a, b) => a.getProgress >= b.getProgress ? a : b);
    if (topGoal.getProgress >= 0.9) {
      return 'So close! Your "${topGoal.goalName}" goal is ${(topGoal.getProgress * 100).toStringAsFixed(0)}% complete!';
    }
    final daysLeft =
        topGoal.targetDate.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) {
      return 'Your "${topGoal.goalName}" deadline is here — keep pushing!';
    }
    final monthsLeft = (daysLeft / 30).ceil();
    return 'At your current rate, you\'ll reach your ${topGoal.goalName} goal in about $monthsLeft month${monthsLeft == 1 ? '' : 's'}!';
  }

  double monthlyContributionFor(Goal goal) {
    if (goal.monthlyContribution != null) return goal.monthlyContribution!;
    final monthsLeft =
        goal.targetDate.difference(DateTime.now()).inDays / 30;
    if (monthsLeft <= 0) return 0;
    final remaining = goal.goalAmount - goal.currentAmount;
    return remaining > 0 ? remaining / monthsLeft : 0;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _goals = await _goalRepo.getByUser(userID);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGoal({
    required String name,
    required double targetAmount,
    required double currentAmount,
    required GoalType type,
    required DateTime targetDate,
    double? monthlyContribution,
    String? note,
  }) async {
    try {
      final goal = Goal(
        goalID: '',
        userID: userID,
        goalName: name,
        goalAmount: targetAmount,
        currentAmount: currentAmount,
        goalType: type,
        startDate: DateTime.now(),
        targetDate: targetDate,
        note: note,
        monthlyContribution: monthlyContribution,
      );
      await _goalRepo.create(goal);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update a goal's progress to [newAmount].
  ///
  /// - **delta > 0** → automatically logs a "Contribution to X" transaction
  ///   (type: transfer, category: Savings).
  /// - **delta < 0** → caller must pass [decreaseIntent]:
  ///     - [ProgressDecreaseIntent.withdrawal] → logs a "Withdrawal from X"
  ///       transaction (type: transfer, category: Savings) with the absolute
  ///       value of the delta as a positive amount.
  ///     - [ProgressDecreaseIntent.correction] → silent update, no
  ///       transaction is written.
  /// - **delta == 0** → no-op.
  Future<void> updateProgress(
    String goalID,
    double newAmount, {
    ProgressDecreaseIntent? decreaseIntent,
  }) async {
    try {
      final goal = _goals.firstWhere(
        (g) => g.goalID == goalID,
        orElse: () => throw StateError('Goal not found: $goalID'),
      );
      final delta = newAmount - goal.currentAmount;

      if (delta > 0) {
        // Contribution — always logged.
        final savingsCategoryID = await _ensureSavingsCategory();
        final tx = Transaction(
          transactionID: '',
          userID: userID,
          transactionName: 'Contribution to ${goal.goalName}',
          type: TransactionType.transfer,
          categoryID: savingsCategoryID,
          goalID: goalID,
          amount: delta,
          date: DateTime.now(),
          note: null,
        );
        await _txRepo.create(tx);
      } else if (delta < 0) {
        if (decreaseIntent == null) {
          throw ArgumentError(
              'decreaseIntent is required when newAmount is less than the goal\'s current amount.');
        }
        if (decreaseIntent == ProgressDecreaseIntent.withdrawal) {
          // Log a positive-amount transfer in the Savings category.
          // Direction is conveyed by the transaction name, not by the sign.
          final savingsCategoryID = await _ensureSavingsCategory();
          final tx = Transaction(
            transactionID: '',
            userID: userID,
            transactionName: 'Withdrawal from ${goal.goalName}',
            type: TransactionType.transfer,
            categoryID: savingsCategoryID,
            goalID: goalID,
            amount: -delta, // delta is negative; flip to positive for storage.
            date: DateTime.now(),
            note: null,
          );
          await _txRepo.create(tx);
        }
        // ProgressDecreaseIntent.correction → no transaction written.
      }
      // delta == 0 → no transaction either way.

      await _goalRepo.updateProgress(goalID, newAmount);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Returns the categoryID of the user's "Savings" transfer category,
  /// creating it on the fly the first time it's needed.
  Future<String> _ensureSavingsCategory() async {
    final transferCats =
        await _catRepo.getByUserAndType(userID, TransactionType.transfer);
    final existing = transferCats.firstWhere(
      (c) => c.categoryName.toLowerCase() == 'savings',
      orElse: () => Categorie(
        categoryID: '',
        userID: userID,
        categoryName: '',
        type: TransactionType.transfer,
      ),
    );
    if (existing.categoryID.isNotEmpty) return existing.categoryID;

    final created = Categorie(
      categoryID: '',
      userID: userID,
      categoryName: 'Savings',
      type: TransactionType.transfer,
    );
    return _catRepo.create(created);
  }

  Future<void> deleteGoal(String goalID) async {
    try {
      await _goalRepo.delete(goalID);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
