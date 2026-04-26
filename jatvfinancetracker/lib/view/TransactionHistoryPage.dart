import 'package:flutter/material.dart';

import 'widgets/AppBottomNavBar.dart';
import '../Model/Transaction.dart';
import '../helper/TransactionType.dart';
import '../viewModel/TransactionHistoryViewModel.dart';

class TransactionHistoryPage extends StatefulWidget {
  final String userID;
  const TransactionHistoryPage({super.key, required this.userID});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final TransactionHistoryViewModel _vm = TransactionHistoryViewModel();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm.load(widget.userID);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6FA),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) => Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () => _vm.refresh(widget.userID),
                      child: CustomScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(child: _buildHeader()),
                          SliverToBoxAdapter(child: _buildToolbar()),
                          SliverToBoxAdapter(child: SizedBox(height: 16)),
                          SliverToBoxAdapter(child: _buildSummaryCards()),
                          SliverToBoxAdapter(child: SizedBox(height: 20)),
                          SliverToBoxAdapter(child: _buildSectionLabel()),
                          SliverToBoxAdapter(child: SizedBox(height: 12)),
                          _buildList(),
                          SliverToBoxAdapter(child: SizedBox(height: 90)),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: _buildAddButton(),
                    ),
                  ],
                ),
              ),
            ),
            AppBottomNavBar(currentIndex: 1, userID: widget.userID),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Material(
      color: Color(0xFF4A90D9),
      shape: CircleBorder(),
      elevation: 6,
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: _showAddTransactionSheet,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  void _showAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: _AddTransactionForm(
            vm: _vm,
            userID: widget.userID,
            onSaved: () => Navigator.pop(sheetContext),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A90D9), Color(0xFF1A56C4)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _vm.setQuery,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _toolbarButton(
                icon: Icons.filter_alt_outlined,
                label: 'Filter',
                active: _vm.filter != TransactionFilter.all,
                onTap: _showFilterSheet,
              ),
            ),
            Expanded(
              child: _toolbarButton(
                icon: Icons.calendar_today_outlined,
                label: _rangeLabel(_vm.range),
                active: _vm.range != DateRangePreset.allTime,
                onTap: _showDateSheet,
              ),
            ),
            Expanded(
              child: _toolbarButton(
                icon: Icons.swap_vert,
                label: 'Sort',
                active: _vm.sort != TransactionSort.newest,
                onTap: _showSortSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbarButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final fg = active ? Color(0xFF4A90D9) : Color(0xFF1A1A2E);
    final bg = active ? Color(0xFFE8F1FB) : Colors.transparent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              label: 'Total Income',
              amount: '+\$${_formatAmount(_vm.totalIncomeThisMonth)}',
              amountColor: Color(0xFF4CAF50),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _summaryCard(
              label: 'Total Expenses',
              amount: '-\$${_formatAmount(_vm.totalExpensesThisMonth)}',
              amountColor: Color(0xFFE53935),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required String amount,
    required Color amountColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'This month',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'ALL TRANSACTIONS',
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_vm.isLoading && _vm.all.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF4A90D9)),
          ),
        ),
      );
    }

    if (_vm.error != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Error: ${_vm.error}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final items = _vm.visible;
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: Text(
              'No transactions yet',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _buildTransactionCard(items[i]),
          ),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction t) {
    final isIncome = t.type == TransactionType.income;
    final amountText =
        '${isIncome ? '+' : '-'}\$${_formatAmount(t.amount)}';
    final amountColor =
        isIncome ? Color(0xFF4CAF50) : Color(0xFF1A1A2E);

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Color(0xFFF1F3F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconForTransaction(t),
              color: Color(0xFF4A90D9),
              size: 22,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.transactionName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  _categoryLabel(t),
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  _formatDateTime(t.date),
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            amountText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    _showOptionsSheet<TransactionFilter>(
      title: 'Filter by type',
      current: _vm.filter,
      options: {
        TransactionFilter.all: 'All',
        TransactionFilter.income: 'Income',
        TransactionFilter.expense: 'Expense',
        TransactionFilter.transfer: 'Transfer',
      },
      onSelect: _vm.setFilter,
    );
  }

  void _showSortSheet() {
    _showOptionsSheet<TransactionSort>(
      title: 'Sort by',
      current: _vm.sort,
      options: {
        TransactionSort.newest: 'Newest first',
        TransactionSort.oldest: 'Oldest first',
        TransactionSort.highest: 'Highest amount',
        TransactionSort.lowest: 'Lowest amount',
      },
      onSelect: _vm.setSort,
    );
  }

  void _showDateSheet() {
    _showOptionsSheet<DateRangePreset>(
      title: 'Date range',
      current: _vm.range,
      options: {
        DateRangePreset.allTime: 'All time',
        DateRangePreset.thisMonth: 'This month',
        DateRangePreset.lastMonth: 'Last month',
        DateRangePreset.last7Days: 'Last 7 days',
        DateRangePreset.last30Days: 'Last 30 days',
      },
      onSelect: _vm.setRange,
    );
  }

  void _showOptionsSheet<T>({
    required String title,
    required T current,
    required Map<T, String> options,
    required ValueChanged<T> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                for (final entry in options.entries)
                  ListTile(
                    title: Text(entry.value),
                    trailing: entry.key == current
                        ? Icon(Icons.check, color: Color(0xFF4A90D9))
                        : null,
                    onTap: () {
                      onSelect(entry.key);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _rangeLabel(DateRangePreset r) {
    switch (r) {
      case DateRangePreset.allTime:
        return 'Date';
      case DateRangePreset.thisMonth:
        return 'This month';
      case DateRangePreset.lastMonth:
        return 'Last month';
      case DateRangePreset.last7Days:
        return 'Last 7d';
      case DateRangePreset.last30Days:
        return 'Last 30d';
    }
  }

  String _categoryLabel(Transaction t) {
    if (t.type == TransactionType.income) return 'Income';
    if (t.type == TransactionType.transfer) return 'Transfer';
    final name = t.transactionName.toLowerCase();
    if (name.contains('grocery') || name.contains('market') || name.contains('food')) {
      return 'Groceries';
    }
    if (name.contains('netflix') || name.contains('spotify') || name.contains('subscription')) {
      return 'Entertainment';
    }
    if (name.contains('electric') || name.contains('utility') || name.contains('bill')) {
      return 'Utilities';
    }
    if (name.contains('rent') || name.contains('home')) return 'Housing';
    if (name.contains('gas') || name.contains('fuel') || name.contains('car')) {
      return 'Transport';
    }
    return 'Expense';
  }

  IconData _iconForTransaction(Transaction t) {
    if (t.type == TransactionType.income) return Icons.attach_money;
    if (t.type == TransactionType.transfer) return Icons.swap_horiz;
    final name = t.transactionName.toLowerCase();
    if (name.contains('grocery') || name.contains('market') || name.contains('food')) {
      return Icons.shopping_cart_outlined;
    }
    if (name.contains('netflix') || name.contains('spotify') || name.contains('subscription')) {
      return Icons.movie_outlined;
    }
    if (name.contains('electric') || name.contains('utility') || name.contains('bill')) {
      return Icons.bolt_outlined;
    }
    if (name.contains('rent') || name.contains('home')) return Icons.home_outlined;
    if (name.contains('gas') || name.contains('fuel') || name.contains('car')) {
      return Icons.local_gas_station_outlined;
    }
    return Icons.receipt_long_outlined;
  }

  String _formatDateTime(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour12 = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final minute = d.minute.toString().padLeft(2, '0');
    final hour = hour12.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year} • $hour:$minute $ampm';
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      final parts = amount.toStringAsFixed(2).split('.');
      final intPart = parts[0];
      final buffer = StringBuffer();
      for (int i = 0; i < intPart.length; i++) {
        if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
        buffer.write(intPart[i]);
      }
      return '${buffer.toString()}.${parts[1]}';
    }
    return amount.toStringAsFixed(2);
  }
}

class _AddTransactionForm extends StatefulWidget {
  final TransactionHistoryViewModel vm;
  final String userID;
  final VoidCallback onSaved;

  const _AddTransactionForm({
    required this.vm,
    required this.userID,
    required this.onSaved,
  });

  @override
  State<_AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<_AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _newCategoryController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _categoryID;
  DateTime _date = DateTime.now();
  String? _localError;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_date),
      );
      setState(() {
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time?.hour ?? _date.hour,
          time?.minute ?? _date.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    setState(() => _localError = null);
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _localError = 'Enter a valid amount.');
      return;
    }

    final ok = await widget.vm.addTransaction(
      userID: widget.userID,
      name: _nameController.text,
      type: _type,
      amount: amount,
      date: _date,
      categoryID: _categoryID,
      newCategoryName:
          _categoryID == null ? _newCategoryController.text : null,
      note: _noteController.text,
    );

    if (!mounted) return;
    if (ok) {
      widget.onSaved();
    } else {
      setState(() => _localError = widget.vm.error ?? 'Failed to save.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.vm.categoriesForType(_type);
    final hasCategories = cats.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Add Transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            SizedBox(height: 16),
            _typeSelector(),
            SizedBox(height: 16),
            _label('Name'),
            TextFormField(
              controller: _nameController,
              decoration: _decoration('e.g. Grocery Store'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: 14),
            _label('Amount'),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  TextInputType.numberWithOptions(decimal: true),
              decoration: _decoration('0.00', prefix: '\$ '),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: 14),
            _label('Category'),
            if (hasCategories)
              DropdownButtonFormField<String?>(
                value: _categoryID,
                decoration: _decoration('Select category'),
                items: [
                  ...cats.map(
                    (c) => DropdownMenuItem<String?>(
                      value: c.categoryID,
                      child: Text(c.categoryName),
                    ),
                  ),
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      '+ New category',
                      style: TextStyle(color: Color(0xFF4A90D9)),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _categoryID = v),
              )
            else
              SizedBox.shrink(),
            if (!hasCategories || _categoryID == null) ...[
              if (hasCategories) SizedBox(height: 10),
              TextFormField(
                controller: _newCategoryController,
                decoration: _decoration('New category name'),
                validator: (v) {
                  if (_categoryID != null) return null;
                  if (v == null || v.trim().isEmpty) return 'Required';
                  return null;
                },
              ),
            ],
            SizedBox(height: 14),
            _label('Date'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: Colors.grey),
                    SizedBox(width: 10),
                    Text(
                      _formatDate(_date),
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFF1A1A2E)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14),
            _label('Note (optional)'),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: _decoration('Add a note...'),
            ),
            if (_localError != null) ...[
              SizedBox(height: 12),
              Text(
                _localError!,
                style: TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: widget.vm.isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4A90D9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: widget.vm.isSaving
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        'Save Transaction',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeSelector() {
    final types = [
      (TransactionType.income, 'Income'),
      (TransactionType.expense, 'Expense'),
      (TransactionType.transfer, 'Transfer'),
    ];
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: types.map((entry) {
          final selected = _type == entry.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _type = entry.$1;
                _categoryID = null;
              }),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? Color(0xFF4A90D9) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    entry.$2,
                    style: TextStyle(
                      color: selected ? Colors.white : Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
      );

  InputDecoration _decoration(String hint, {String? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      filled: true,
      fillColor: Color(0xFFF4F6FA),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour12 = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year} • $hour12:$minute $ampm';
  }
}