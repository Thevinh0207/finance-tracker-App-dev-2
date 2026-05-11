import 'package:flutter/material.dart';

import '../Model/Budget.dart';
import '../util/AppLocalizations.dart';
import '../viewModel/BudgetTrackerViewModel.dart';
import 'AddBudgetPage.dart';
import 'widgets/AppBottomNavBar.dart';

class BudgetTrackerPage extends StatefulWidget {
  final String userID;
  const BudgetTrackerPage({super.key, required this.userID});

  @override
  State<BudgetTrackerPage> createState() => _BudgetTrackerPageState();
}

class _BudgetTrackerPageState extends State<BudgetTrackerPage> {
  late final BudgetTrackerViewModel _vm;

  static const _primaryBlue = Color(0xFF4A90D9);
  static const _healthyGreen = Color(0xFF4CAF50);
  static const _warningOrange = Color(0xFFFF9800);
  static const _dangerRed = Color(0xFFE53935);
  static const _darkText = Color(0xFF1A1A2E);
  static const _greyText = Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    _vm = BudgetTrackerViewModel();
    _vm.load(widget.userID);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  String _fmt(double amount) {
    final n = amount.abs().toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < n.length; i++) {
      if (i > 0 && (n.length - i) % 3 == 0) buf.write(',');
      buf.write(n[i]);
    }
    return buf.toString();
  }

  Color _statusColor(BudgetProgress p) {
    if (p.isOverBudget) return _dangerRed;
    if (p.isApproachingLimit) return _warningOrange;
    return _healthyGreen;
  }

  IconData _iconFor(String? categoryName) {
    final name = (categoryName ?? '').toLowerCase();
    if (name.contains('groc') || name.contains('food shop')) {
      return Icons.shopping_cart_rounded;
    }
    if (name.contains('din') || name.contains('restaurant') || name.contains('food')) {
      return Icons.restaurant_rounded;
    }
    if (name.contains('gas') || name.contains('fuel') || name.contains('transport')) {
      return Icons.local_gas_station_rounded;
    }
    if (name.contains('rent') || name.contains('mortgage') || name.contains('home')) {
      return Icons.home_rounded;
    }
    if (name.contains('util') || name.contains('elec') || name.contains('water')) {
      return Icons.bolt_rounded;
    }
    if (name.contains('entertain') || name.contains('movie') || name.contains('fun')) {
      return Icons.movie_rounded;
    }
    if (name.contains('health') || name.contains('medical') || name.contains('pharm')) {
      return Icons.local_hospital_rounded;
    }
    if (name.contains('shop') || name.contains('cloth')) {
      return Icons.shopping_bag_rounded;
    }
    if (name.contains('travel') || name.contains('vacation')) {
      return Icons.flight_rounded;
    }
    if (name.contains('subscrip') || name.contains('stream')) {
      return Icons.subscriptions_rounded;
    }
    return Icons.attach_money_rounded;
  }

  Future<void> _openAddBudget() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBudgetPage(
        userID: widget.userID,
        viewModel: _vm,
      ),
    );
    if (created == true && mounted) {
      _vm.refresh(widget.userID);
    }
  }

  Future<void> _confirmDelete(BudgetProgress p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.tr('budget_delete_title')),
        content: Text('"${p.budget.budgetName}" — ${AppLocalizations.tr('goals_delete_body')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: _dangerRed),
            child: Text(AppLocalizations.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _vm.deleteBudget(widget.userID, p.budget.budgetID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryBlue,
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) => SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: _vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: _primaryBlue),
                        )
                      : _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        userID: widget.userID,
      ),
    );
  }

  Widget _buildBody() {
    final progress = _vm.progressList;
    return RefreshIndicator(
      color: _primaryBlue,
      onRefresh: () => _vm.refresh(widget.userID),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_vm.hasAlerts) ...[
              _buildAlert(),
              const SizedBox(height: 20),
            ],
            _buildSectionHeader(),
            const SizedBox(height: 12),
            if (progress.isEmpty)
              _buildEmptyState()
            else
              ...progress.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildBudgetCard(p),
                  )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.tr('budget_title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              GestureDetector(
                onTap: _openAddBudget,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildTotalCard(),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    final total = _vm.totalBudget;
    final spent = _vm.totalSpent;
    final remaining = _vm.totalRemaining;
    final pct = _vm.totalPercentUsed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.tr('budget_total_this_month'),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${_fmt(total)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.tr('budget_spent'),
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text('\$${_fmt(spent)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.tr('budget_remaining'),
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text('\$${_fmt(remaining)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Alert Banner ──────────────────────────────────────────────────────────

  Widget _buildAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _warningOrange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: _warningOrange, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.tr('budget_alert'),
                    style: const TextStyle(
                        color: Color(0xFFD17B00),
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  '${AppLocalizations.tr('budget_alert_prefix')} ${_vm.alertCount} '
                  '${_vm.alertCount == 1 ? AppLocalizations.tr('budget_alert_cat_one') : AppLocalizations.tr('budget_alert_cat_many')}',
                  style: const TextStyle(
                      color: Color(0xFFB35900), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.tr('budget_categories'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (_vm.progressList.length > 3)
          GestureDetector(
            onTap: _showAllBudgets,
            child: Text(
              AppLocalizations.tr('budget_view_all'),
              style: const TextStyle(
                fontSize: 14,
                color: _primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  void _showAllBudgets() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.tr('budget_all_categories'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: _vm.progressList.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildBudgetCard(_vm.progressList[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pie_chart_outline_rounded,
                color: _primaryBlue, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.tr('budget_none_title'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.tr('budget_none_body'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _greyText, height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openAddBudget,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(AppLocalizations.tr('budget_create_btn')),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Budget Card ───────────────────────────────────────────────────────────

  Widget _buildBudgetCard(BudgetProgress p) {
    final color = _statusColor(p);
    final pct = p.percentUsed;
    final pctText = (p.rawPercentUsed * 100).toStringAsFixed(0);
    final categoryName =
        p.category?.categoryName ?? p.budget.budgetName;
    final periodLabel = _periodLabel(p.budget.period);

    return GestureDetector(
      onLongPress: () => _confirmDelete(p),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_iconFor(categoryName),
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.budget.budgetName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${p.transactionCount} '
                              '${p.transactionCount == 1 ? AppLocalizations.tr('budget_tx_one') : AppLocalizations.tr('budget_tx_many')} · $periodLabel',
                              style: const TextStyle(
                                  fontSize: 12, color: _greyText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.tr('budget_spent'),
                          style: const TextStyle(
                              fontSize: 13, color: _greyText)),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          children: [
                            TextSpan(text: '\$${_fmt(p.spent)} '),
                            TextSpan(
                              text: '/ \$${_fmt(p.budget.amount)}',
                              style: const TextStyle(
                                color: _greyText,
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.grey.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.isOverBudget
                            ? '${AppLocalizations.tr('budget_over_by')} \$${_fmt(p.spent - p.budget.amount)}'
                            : '$pctText% ${AppLocalizations.tr('budget_used')}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        p.isOverBudget
                            ? '\$0 ${AppLocalizations.tr('budget_left')}'
                            : '\$${_fmt(p.remaining)} ${AppLocalizations.tr('budget_left')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _greyText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _periodLabel(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return AppLocalizations.tr('budget_period_weekly');
      case BudgetPeriod.monthly:
        return AppLocalizations.tr('budget_period_monthly');
      case BudgetPeriod.yearly:
        return AppLocalizations.tr('budget_period_yearly');
    }
  }
}
