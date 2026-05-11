import 'package:flutter/material.dart';

import '../Model/Categorie.dart';
import '../Model/FamilyGroup.dart';
import '../Model/FamilyMember.dart';
import '../Model/SharedExpense.dart';
import '../Model/Transaction.dart';
import '../Model/User.dart';
import '../Repository/CategorieRepository.dart';
import '../Repository/FamilyRepository.dart';
import '../Repository/TransactionRepository.dart';
import '../Repository/UserRepository.dart';
import '../helper/TransactionType.dart';

class FamilyViewModel extends ChangeNotifier {
  final FamilyRepository _repo;
  final UserRepository _userRepo;
  final TransactionRepository _tRepo;
  final CategorieRepository _cRepo;

  FamilyGroup? _group;
  List<FamilyMember> _members = [];
  List<SharedExpense> _sharedExpenses = [];
  String _currentUserName = '';
  bool _isLoading = false;
  String? _error;

  FamilyViewModel({
    FamilyRepository? repository,
    UserRepository? userRepository,
    TransactionRepository? transactionRepository,
    CategorieRepository? categorieRepository,
  })  : _repo = repository ?? FamilyRepository(),
        _userRepo = userRepository ?? UserRepository(),
        _tRepo = transactionRepository ?? TransactionRepository(),
        _cRepo = categorieRepository ?? CategorieRepository();

  FamilyGroup? get group => _group;
  List<FamilyMember> get members => List.unmodifiable(_members);
  List<SharedExpense> get sharedExpenses => List.unmodifiable(_sharedExpenses);
  String get currentUserName => _currentUserName;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasGroup => _group != null;

  double get totalSpent => _members.fold(0.0, (sum, m) => sum + m.spent);
  double get totalBudget => _group?.totalBudget ?? 0.0;
  double get budgetProgress =>
      totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

  String get insightMessage {
    if (_members.isEmpty) {
      return 'Add family members to start tracking your budget together!';
    }
    if (totalBudget <= 0) return 'Set a family budget to track your spending.';
    final remaining = totalBudget - totalSpent;
    if (remaining > 0) {
      final savedPct = ((remaining / totalBudget) * 100).toStringAsFixed(0);
      return 'Your family saved $savedPct% more this month compared to last month!';
    }
    return 'Your family has used the full budget this month. Review your shared expenses!';
  }

  // Derive each member's spent from the shared expenses they paid.
  void _recalculateMemberSpending() {
    _members = _members.map((m) {
      final spent = _sharedExpenses
          .where((e) => e.paidByUserID == m.userID)
          .fold(0.0, (sum, e) => sum + e.amount);
      return m.copyWith(spent: spent);
    }).toList();
  }

  // Find or create a "Shared Expenses" expense category for a user.
  Future<String> _sharedExpenseCategoryID(String userID) async {
    final cats = await _cRepo.getByUserAndType(userID, TransactionType.expense);
    final existing = cats.where(
      (c) => c.categoryName.toLowerCase() == 'shared expenses',
    );
    if (existing.isNotEmpty) return existing.first.categoryID;
    final newCat = Categorie(
      categoryID: '',
      userID: userID,
      categoryName: 'Shared Expenses',
      type: TransactionType.expense,
    );
    return await _cRepo.create(newCat);
  }

  Future<void> load(String userID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _userRepo.getById(userID);
      if (user != null) {
        _currentUserName = '${user.firstName} ${user.lastName}'.trim();
      }
      _group = await _repo.getGroupByUser(userID);
      if (_group != null) {
        _members = await _repo.getMembers(_group!.groupID);
        _sharedExpenses = await _repo.getSharedExpenses(_group!.groupID);
        _recalculateMemberSpending();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGroup({
    required String groupName,
    required String adminUserID,
    required String adminDisplayName,
    required double totalBudget,
    required double adminBudget,
  }) async {
    try {
      final groupID = await _repo.createGroup(
        groupName: groupName,
        adminUserID: adminUserID,
        totalBudget: totalBudget,
      );
      await _repo.addMember(
        groupID: groupID,
        userID: adminUserID,
        displayName: adminDisplayName,
        role: 'admin',
        budgetAllocation: adminBudget,
      );
      await load(adminUserID);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<User?> lookupUserByEmail(String email) async {
    return await _userRepo.getByEmail(email.trim().toLowerCase());
  }

  bool isMember(String userID) {
    return _group?.memberUserIDs.contains(userID) ?? false;
  }

  bool isUserAdmin(String userID) {
    return _group?.adminUserID == userID;
  }

  FamilyMember? memberForUser(String userID) {
    try {
      return _members.firstWhere((m) => m.userID == userID);
    } catch (_) {
      return null;
    }
  }

  Future<void> leaveGroup(String userID) async {
    final member = memberForUser(userID);
    if (member == null) return;
    await removeMember(member);
  }

  Future<void> addMember({
    required String userID,
    required String displayName,
    required double budgetAllocation,
  }) async {
    if (_group == null) return;
    try {
      await _repo.addMember(
        groupID: _group!.groupID,
        userID: userID,
        displayName: displayName,
        role: 'member',
        budgetAllocation: budgetAllocation,
      );
      _members = await _repo.getMembers(_group!.groupID);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeMember(FamilyMember member) async {
    if (_group == null) return;
    try {
      await _repo.removeMember(
          _group!.groupID, member.memberID, member.userID);
      _members = await _repo.getMembers(_group!.groupID);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addSharedExpense({
    required String name,
    required double amount,
    required String paidByUserID,
    required String paidByName,
    required String categoryIcon,
    DateTime? date,
  }) async {
    if (_group == null) return;
    try {
      final expenseDate = date ?? DateTime.now();

      // Auto-create a transaction in the payer's History.
      String? linkedTransactionID;
      try {
        final categoryID = await _sharedExpenseCategoryID(paidByUserID);
        final t = Transaction(
          transactionID: '',
          userID: paidByUserID,
          transactionName: name,
          type: TransactionType.expense,
          categoryID: categoryID,
          amount: amount,
          date: expenseDate,
          note: 'Shared expense — ${_group!.groupName}',
        );
        linkedTransactionID = await _tRepo.create(t);
      } catch (_) {
        // Transaction creation is best-effort; don't block the expense save.
      }

      await _repo.addSharedExpense(
        groupID: _group!.groupID,
        name: name,
        amount: amount,
        paidByUserID: paidByUserID,
        paidByName: paidByName,
        date: expenseDate,
        categoryIcon: categoryIcon,
        linkedTransactionID: linkedTransactionID,
      );
      _sharedExpenses = await _repo.getSharedExpenses(_group!.groupID);
      _recalculateMemberSpending();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSharedExpense(SharedExpense expense) async {
    if (_group == null) return;
    try {
      // Remove the linked transaction from History too.
      if (expense.linkedTransactionID != null) {
        try {
          await _tRepo.delete(expense.linkedTransactionID!);
        } catch (_) {}
      }
      await _repo.deleteSharedExpense(_group!.groupID, expense.expenseID);
      _sharedExpenses = await _repo.getSharedExpenses(_group!.groupID);
      _recalculateMemberSpending();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateGroupBudget(String userID, double newBudget) async {
    if (_group == null) return;
    try {
      final updated = _group!.copyWith(totalBudget: newBudget);
      await _repo.updateGroup(updated);
      _group = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
