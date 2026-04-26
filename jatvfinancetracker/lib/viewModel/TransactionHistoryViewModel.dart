import 'package:flutter/foundation.dart';

import '../Model/Transaction.dart';
import '../Model/Categorie.dart';
import '../helper/TransactionType.dart';
import '../Repository/TransactionRepository.dart';
import '../Repository/CategorieRepository.dart';

enum TransactionFilter { all, income, expense, transfer }

enum TransactionSort { newest, oldest, highest, lowest }

enum DateRangePreset { allTime, thisMonth, lastMonth, last7Days, last30Days }

class TransactionHistoryViewModel extends ChangeNotifier {
  final TransactionRepository _tRepo;
  final CategorieRepository _cRepo;

  TransactionHistoryViewModel({
    TransactionRepository? tRepo,
    CategorieRepository? cRepo,
  })  : _tRepo = tRepo ?? TransactionRepository(),
        _cRepo = cRepo ?? CategorieRepository();

  List<Transaction> _all = <Transaction>[];
  List<Categorie> _categories = <Categorie>[];
  bool _isSaving = false;
  bool _isLoading = false;
  String? _error;

  List<Categorie> get categories => _categories;
  bool get isSaving => _isSaving;

  List<Categorie> categoriesForType(TransactionType type) {
    final cats = _categories;
    return cats.where((c) => c.type == type).toList();
  }

  String _query = '';
  TransactionFilter _filter = TransactionFilter.all;
  TransactionSort _sort = TransactionSort.newest;
  DateRangePreset _range = DateRangePreset.allTime;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  TransactionFilter get filter => _filter;
  TransactionSort get sort => _sort;
  DateRangePreset get range => _range;

  List<Transaction> get all => _all;

  List<Transaction> get visible {
    Iterable<Transaction> list = _all;

    if (_filter != TransactionFilter.all) {
      final type = switch (_filter) {
        TransactionFilter.income => TransactionType.income,
        TransactionFilter.expense => TransactionType.expense,
        TransactionFilter.transfer => TransactionType.transfer,
        TransactionFilter.all => TransactionType.income,
      };
      list = list.where((t) => t.type == type);
    }

    final now = DateTime.now();
    DateTime? start;
    DateTime? end;
    switch (_range) {
      case DateRangePreset.thisMonth:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1);
        break;
      case DateRangePreset.lastMonth:
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 1);
        break;
      case DateRangePreset.last7Days:
        start = now.subtract(Duration(days: 7));
        break;
      case DateRangePreset.last30Days:
        start = now.subtract(Duration(days: 30));
        break;
      case DateRangePreset.allTime:
        break;
    }
    final fromDate = start;
    final toDate = end;
    if (fromDate != null) {
      list = list.where((t) => !t.date.isBefore(fromDate));
    }
    if (toDate != null) {
      list = list.where((t) => t.date.isBefore(toDate));
    }

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((t) =>
          t.transactionName.toLowerCase().contains(q) ||
          (t.note?.toLowerCase().contains(q) ?? false));
    }

    final result = list.toList();
    switch (_sort) {
      case TransactionSort.newest:
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case TransactionSort.oldest:
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case TransactionSort.highest:
        result.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case TransactionSort.lowest:
        result.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return result;
  }

  double get totalIncomeThisMonth => _sumThisMonth(TransactionType.income);
  double get totalExpensesThisMonth => _sumThisMonth(TransactionType.expense);

  double _sumThisMonth(TransactionType type) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return _all
        .where((t) =>
            t.type == type &&
            !t.date.isBefore(start) &&
            t.date.isBefore(end))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void setQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  void setFilter(TransactionFilter f) {
    _filter = f;
    notifyListeners();
  }

  void setSort(TransactionSort s) {
    _sort = s;
    notifyListeners();
  }

  void setRange(DateRangePreset r) {
    _range = r;
    notifyListeners();
  }

  Future<void> load(String userID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _tRepo.getByUser(userID),
        _cRepo.getByUser(userID),
      ]);
      _all = results[0] as List<Transaction>;
      _categories = results[1] as List<Categorie>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String userID) => load(userID);

  Future<bool> addTransaction({
    required String userID,
    required String name,
    required TransactionType type,
    required double amount,
    required DateTime date,
    String? categoryID,
    String? newCategoryName,
    String? note,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      String resolvedCategoryID;
      if (categoryID != null && categoryID.isNotEmpty) {
        resolvedCategoryID = categoryID;
      } else if (newCategoryName != null && newCategoryName.trim().isNotEmpty) {
        final created = Categorie(
          categoryID: '',
          userID: userID,
          categoryName: newCategoryName.trim(),
          type: type,
        );
        resolvedCategoryID = await _cRepo.create(created);
      } else {
        _error = 'Pick a category or enter a new one.';
        return false;
      }

      final t = Transaction(
        transactionID: '',
        userID: userID,
        transactionName: name.trim(),
        type: type,
        categoryID: resolvedCategoryID,
        amount: amount,
        date: date,
        note: (note == null || note.trim().isEmpty) ? null : note.trim(),
      );
      await _tRepo.create(t);
      await load(userID);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
