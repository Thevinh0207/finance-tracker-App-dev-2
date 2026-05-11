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

  // All groups the user belongs to.
  List<FamilyGroup> _allGroups = [];
  int _selectedIndex = 0;

  // Per-group data keyed by groupID.
  final Map<String, List<FamilyMember>> _membersMap = {};
  final Map<String, List<SharedExpense>> _expensesMap = {};

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

  // ── Public getters ────────────────────────────────────────────────────────

  /// All groups the user belongs to.
  List<FamilyGroup> get groups => List.unmodifiable(_allGroups);

  /// The currently displayed group, or null if the user has none.
  FamilyGroup? get group =>
      _allGroups.isNotEmpty ? _allGroups[_selectedIndex] : null;

  /// Members of the currently displayed group.
  List<FamilyMember> get members {
    final g = group;
    return g != null ? (_membersMap[g.groupID] ?? []) : [];
  }

  /// Shared expenses of the currently displayed group.
  List<SharedExpense> get sharedExpenses {
    final g = group;
    return g != null ? (_expensesMap[g.groupID] ?? []) : [];
  }

  int get selectedIndex => _selectedIndex;
  String get currentUserName => _currentUserName;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasGroup => _allGroups.isNotEmpty;
  bool get hasMultipleGroups => _allGroups.length > 1;

  double get totalSpent =>
      members.fold(0.0, (sum, m) => sum + m.spent);
  double get totalBudget => group?.totalBudget ?? 0.0;
  double get budgetProgress =>
      totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

  String get insightMessage {
    if (members.isEmpty) {
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

  // ── Switch group ──────────────────────────────────────────────────────────

  void switchToGroup(int index) {
    if (index < 0 || index >= _allGroups.length) return;
    _selectedIndex = index;
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Recomputes each member's `spent` field from the group's shared expenses.
  void _recalculateMemberSpending(String groupID) {
    final ms = _membersMap[groupID] ?? [];
    final es = _expensesMap[groupID] ?? [];
    _membersMap[groupID] = ms.map((m) {
      final spent = es
          .where((e) => e.paidByUserID == m.userID)
          .fold(0.0, (sum, e) => sum + e.amount);
      return m.copyWith(spent: spent);
    }).toList();
  }

  Future<String> _sharedExpenseCategoryID(String userID) async {
    final cats =
        await _cRepo.getByUserAndType(userID, TransactionType.expense);
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

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> load(String userID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _userRepo.getById(userID);
      if (user != null) {
        _currentUserName = '${user.firstName} ${user.lastName}'.trim();
      }

      _allGroups = await _repo.getGroupsByUser(userID);

      // Keep the selected index in bounds after a reload.
      if (_selectedIndex >= _allGroups.length) _selectedIndex = 0;

      // Load members + expenses for every group in parallel.
      await Future.wait(_allGroups.map((g) async {
        _membersMap[g.groupID] = await _repo.getMembers(g.groupID);
        _expensesMap[g.groupID] =
            await _repo.getSharedExpenses(g.groupID);
        _recalculateMemberSpending(g.groupID);
      }));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Create group ──────────────────────────────────────────────────────────

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
      // Switch to the newly created group (it's the last one after reload).
      _selectedIndex = _allGroups.length - 1;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ── User lookups ──────────────────────────────────────────────────────────

  Future<User?> lookupUserByEmail(String email) async {
    return await _userRepo.getByEmail(email.trim().toLowerCase());
  }

  bool isMember(String userID) {
    return group?.memberUserIDs.contains(userID) ?? false;
  }

  bool isUserAdmin(String userID) {
    return group?.adminUserID == userID;
  }

  FamilyMember? memberForUser(String userID) {
    try {
      return members.firstWhere((m) => m.userID == userID);
    } catch (_) {
      return null;
    }
  }

  // ── Member actions ────────────────────────────────────────────────────────

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
    final g = group;
    if (g == null) return;
    try {
      await _repo.addMember(
        groupID: g.groupID,
        userID: userID,
        displayName: displayName,
        role: 'member',
        budgetAllocation: budgetAllocation,
      );
      _membersMap[g.groupID] = await _repo.getMembers(g.groupID);
      _recalculateMemberSpending(g.groupID);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeMember(FamilyMember member) async {
    final g = group;
    if (g == null) return;
    try {
      await _repo.removeMember(g.groupID, member.memberID, member.userID);
      _membersMap[g.groupID] = await _repo.getMembers(g.groupID);
      _recalculateMemberSpending(g.groupID);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ── Shared expenses ───────────────────────────────────────────────────────

  Future<void> addSharedExpense({
    required String name,
    required double amount,
    required String paidByUserID,
    required String paidByName,
    required String categoryIcon,
    DateTime? date,
  }) async {
    final g = group;
    if (g == null) return;
    try {
      final expenseDate = date ?? DateTime.now();

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
          note: 'Shared expense — ${g.groupName}',
        );
        linkedTransactionID = await _tRepo.create(t);
      } catch (_) {}

      await _repo.addSharedExpense(
        groupID: g.groupID,
        name: name,
        amount: amount,
        paidByUserID: paidByUserID,
        paidByName: paidByName,
        date: expenseDate,
        categoryIcon: categoryIcon,
        linkedTransactionID: linkedTransactionID,
      );
      _expensesMap[g.groupID] = await _repo.getSharedExpenses(g.groupID);
      _recalculateMemberSpending(g.groupID);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSharedExpense(SharedExpense expense) async {
    final g = group;
    if (g == null) return;
    try {
      if (expense.linkedTransactionID != null) {
        try {
          await _tRepo.delete(expense.linkedTransactionID!);
        } catch (_) {}
      }
      await _repo.deleteSharedExpense(g.groupID, expense.expenseID);
      _expensesMap[g.groupID] = await _repo.getSharedExpenses(g.groupID);
      _recalculateMemberSpending(g.groupID);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateGroupBudget(String userID, double newBudget) async {
    final g = group;
    if (g == null) return;
    try {
      final updated = g.copyWith(totalBudget: newBudget);
      await _repo.updateGroup(updated);
      _allGroups[_selectedIndex] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
