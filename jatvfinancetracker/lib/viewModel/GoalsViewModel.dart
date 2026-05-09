import 'package:flutter/material.dart';

import '../Model/Goal.dart';
import '../Repository/GoalRepository.dart';
import '../helper/GoalType.dart';

class GoalsViewModel extends ChangeNotifier {
  final GoalRepository _goalRepo;
  final String userID;

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  GoalsViewModel({required this.userID, GoalRepository? goalRepository})
      : _goalRepo = goalRepository ?? GoalRepository();

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

  Future<void> updateProgress(String goalID, double newAmount) async {
    try {
      await _goalRepo.updateProgress(goalID, newAmount);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
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
