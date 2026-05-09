import 'package:flutter/material.dart';

import '../Model/Goal.dart';
import '../helper/GoalType.dart';
import '../viewModel/GoalsViewModel.dart';
import 'widgets/AppBottomNavBar.dart';

class GoalsPage extends StatefulWidget {
  final String userID;
  const GoalsPage({super.key, required this.userID});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  late final GoalsViewModel _vm;

  static const _gradStart = Color(0xFF7B2FBE);
  static const _gradEnd = Color(0xFFDA44BB);
  static const _darkText = Color(0xFF1A1A2E);
  static const _greyText = Color(0xFF888888);
  static const _green = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _vm = GoalsViewModel(userID: widget.userID);
    _vm.load();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  String _fmt(double v) {
    final n = v.abs().toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < n.length; i++) {
      if (i > 0 && (n.length - i) % 3 == 0) buf.write(',');
      buf.write(n[i]);
    }
    return buf.toString();
  }

  String _fmtDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[d.month - 1]} ${d.year}';
  }

  Color _goalColor(GoalType t) {
    switch (t) {
      case GoalType.emergency:
        return const Color(0xFF2196F3);
      case GoalType.saving:
        return const Color(0xFF00BCD4);
      case GoalType.purchase:
        return const Color(0xFF9C27B0);
      case GoalType.retirement:
        return const Color(0xFF673AB7);
      case GoalType.debt:
        return const Color(0xFFE53935);
      case GoalType.investment:
        return const Color(0xFF4CAF50);
      case GoalType.spending:
        return const Color(0xFFFF9800);
    }
  }

  IconData _goalIcon(GoalType t) {
    switch (t) {
      case GoalType.emergency:
        return Icons.shield_outlined;
      case GoalType.saving:
        return Icons.savings_outlined;
      case GoalType.purchase:
        return Icons.shopping_bag_outlined;
      case GoalType.retirement:
        return Icons.beach_access_outlined;
      case GoalType.debt:
        return Icons.credit_card_outlined;
      case GoalType.investment:
        return Icons.trending_up_rounded;
      case GoalType.spending:
        return Icons.account_balance_wallet_outlined;
    }
  }

  String _goalLabel(GoalType t) {
    switch (t) {
      case GoalType.emergency:
        return 'Emergency';
      case GoalType.saving:
        return 'Savings';
      case GoalType.purchase:
        return 'Purchase';
      case GoalType.retirement:
        return 'Retirement';
      case GoalType.debt:
        return 'Debt';
      case GoalType.investment:
        return 'Investment';
      case GoalType.spending:
        return 'Spending';
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_gradStart, _gradEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) => SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: _vm.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: _gradStart))
                        : _buildBody(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          AppBottomNavBar(currentIndex: 5, userID: widget.userID),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Finance Goals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Track your financial dreams',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showAddGoalSheet,
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
          _buildProgressCard(),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.track_changes_rounded,
                          color: Colors.white70, size: 15),
                      SizedBox(width: 5),
                      Text('Overall Progress',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_fmt(_vm.totalSaved)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Target',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_fmt(_vm.totalTarget)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _vm.overallProgress,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_vm.overallPercentage.toStringAsFixed(1)}% of your goals achieved',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return RefreshIndicator(
      color: _gradStart,
      onRefresh: _vm.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_vm.activeGoals.isEmpty && _vm.completedGoals.isEmpty)
              _buildEmptyState()
            else ...[
              if (_vm.activeGoals.isNotEmpty) ...[
                const Text(
                  'Active Goals',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _darkText),
                ),
                const SizedBox(height: 12),
                ..._vm.activeGoals.map((g) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildGoalCard(g),
                    )),
              ],
              if (_vm.completedGoals.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.check_circle_outline_rounded,
                        color: _green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Completed Goals',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _darkText),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._vm.completedGoals.map((g) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCompletedCard(g),
                    )),
              ],
              if (_vm.goals.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInsightsCard(),
              ],
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Goal Card ─────────────────────────────────────────────────────────────

  Widget _buildGoalCard(Goal goal) {
    final color = _goalColor(goal.goalType);
    final progress = goal.getProgress;
    final remaining = goal.goalAmount - goal.currentAmount;
    final monthly = _vm.monthlyContributionFor(goal);

    return GestureDetector(
      onTap: () => _showUpdateProgressSheet(goal),
      onLongPress: () => _confirmDelete(goal),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 5,
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
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_goalIcon(goal.goalType),
                            color: color, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.goalName,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _darkText),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 12, color: _greyText),
                                const SizedBox(width: 4),
                                Text(_fmtDate(goal.targetDate),
                                    style: const TextStyle(
                                        fontSize: 12, color: _greyText)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _goalLabel(goal.goalType),
                                    style: const TextStyle(
                                        fontSize: 11, color: Color(0xFF555555)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progress',
                          style:
                              TextStyle(fontSize: 13, color: _greyText)),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _darkText),
                          children: [
                            TextSpan(text: '\$${_fmt(goal.currentAmount)}'),
                            TextSpan(
                              text: ' / \$${_fmt(goal.goalAmount)}',
                              style: const TextStyle(
                                  color: _greyText,
                                  fontWeight: FontWeight.normal),
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
                      value: progress,
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
                        '${(progress * 100).toStringAsFixed(1)}% complete',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color),
                      ),
                      Text(
                        '\$${_fmt(remaining)} remaining',
                        style: const TextStyle(
                            fontSize: 12, color: _greyText),
                      ),
                    ],
                  ),
                  if (monthly > 0) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Monthly contribution',
                            style:
                                TextStyle(fontSize: 12, color: _greyText)),
                        Text(
                          '+\$${_fmt(monthly)}/month',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _green),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Completed Card ────────────────────────────────────────────────────────

  Widget _buildCompletedCard(Goal goal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Icon(_goalIcon(goal.goalType), color: _green, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.goalName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _darkText)),
                const SizedBox(height: 2),
                Text('Completed ${_fmtDate(goal.targetDate)}',
                    style:
                        const TextStyle(fontSize: 12, color: _greyText)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${_fmt(goal.goalAmount)}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _green),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.check_circle_rounded, color: _green, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  // ── Insights Card ─────────────────────────────────────────────────────────

  Widget _buildInsightsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_gradStart, _gradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up_rounded,
              color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Goal Insights',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_vm.insightMessage,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _gradStart.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.track_changes_rounded,
                color: _gradStart, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('No goals yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _darkText)),
          const SizedBox(height: 6),
          const Text(
            'Set financial goals to track your progress\nand stay motivated.',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 13, color: _greyText, height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddGoalSheet,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add First Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _gradStart,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sheets ────────────────────────────────────────────────────────────────

  void _showAddGoalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddGoalSheet(
        onAdd: (name, target, current, type, date, monthly, note) async {
          await _vm.createGoal(
            name: name,
            targetAmount: target,
            currentAmount: current,
            type: type,
            targetDate: date,
            monthlyContribution: monthly,
            note: note,
          );
        },
      ),
    );
  }

  void _showUpdateProgressSheet(Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UpdateProgressSheet(
        goal: goal,
        onUpdate: (amount) async {
          await _vm.updateProgress(goal.goalID, amount);
        },
      ),
    );
  }

  Future<void> _confirmDelete(Goal goal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal'),
        content:
            Text('Delete "${goal.goalName}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) await _vm.deleteGoal(goal.goalID);
  }
}

// ── Add Goal Sheet ────────────────────────────────────────────────────────────

class _AddGoalSheet extends StatefulWidget {
  final Future<void> Function(String name, double target, double current,
      GoalType type, DateTime date, double? monthly, String? note) onAdd;

  const _AddGoalSheet({required this.onAdd});

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _currentCtrl = TextEditingController();
  final _monthlyCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  GoalType _type = GoalType.saving;
  DateTime _date = DateTime.now().add(const Duration(days: 365));
  bool _saving = false;

  static const _gradStart = Color(0xFF7B2FBE);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _currentCtrl.dispose();
    _monthlyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _typeLabel(GoalType t) {
    switch (t) {
      case GoalType.emergency:
        return 'Emergency Fund';
      case GoalType.saving:
        return 'Savings';
      case GoalType.purchase:
        return 'Purchase';
      case GoalType.retirement:
        return 'Retirement';
      case GoalType.debt:
        return 'Debt Payoff';
      case GoalType.investment:
        return 'Investment';
      case GoalType.spending:
        return 'Spending';
    }
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final target = double.tryParse(_targetCtrl.text.trim()) ?? 0;
    final current = double.tryParse(_currentCtrl.text.trim()) ?? 0;
    final monthly = double.tryParse(_monthlyCtrl.text.trim());
    if (name.isEmpty || target <= 0) return;
    setState(() => _saving = true);
    await widget.onAdd(
        name, target, current, _type, _date, monthly,
        _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim());
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Add New Goal',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _field('Goal Name', _nameCtrl, hint: 'e.g. Emergency Fund'),
            const SizedBox(height: 12),
            _field('Target Amount (\$)', _targetCtrl,
                hint: '10000', number: true),
            const SizedBox(height: 12),
            _field('Current Savings (\$)', _currentCtrl,
                hint: '0', number: true),
            const SizedBox(height: 12),
            _field('Monthly Contribution (\$, optional)', _monthlyCtrl,
                hint: '500', number: true),
            const SizedBox(height: 12),
            const Text('Goal Type',
                style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
            const SizedBox(height: 8),
            DropdownButtonFormField<GoalType>(
              value: _type,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300)),
              ),
              items: GoalType.values
                  .map((t) => DropdownMenuItem(
                      value: t, child: Text(_typeLabel(t))))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 12),
            const Text('Target Date',
                style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  builder: (ctx, child) => Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: const ColorScheme.light(
                          primary: _gradStart),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: Color(0xFF888888)),
                    const SizedBox(width: 8),
                    Text(
                      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _field('Note (optional)', _noteCtrl,
                hint: 'Any additional notes'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gradStart,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Create Goal',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String hint = '', bool number = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF888888))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType:
              number ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }
}

// ── Update Progress Sheet ─────────────────────────────────────────────────────

class _UpdateProgressSheet extends StatefulWidget {
  final Goal goal;
  final Future<void> Function(double amount) onUpdate;

  const _UpdateProgressSheet({required this.goal, required this.onUpdate});

  @override
  State<_UpdateProgressSheet> createState() => _UpdateProgressSheetState();
}

class _UpdateProgressSheetState extends State<_UpdateProgressSheet> {
  late final TextEditingController _ctrl;
  bool _saving = false;

  static const _gradStart = Color(0xFF7B2FBE);

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.goal.currentAmount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_ctrl.text.trim());
    if (amount == null || amount < 0) return;
    setState(() => _saving = true);
    await widget.onUpdate(amount);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text('Update: ${widget.goal.goalName}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
              'Target: \$${widget.goal.goalAmount.toStringAsFixed(0)}',
              style: const TextStyle(color: Color(0xFF888888))),
          const SizedBox(height: 20),
          const Text('Current Amount (\$)',
              style:
                  TextStyle(fontSize: 13, color: Color(0xFF888888))),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              prefixText: '\$  ',
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _gradStart,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save Progress',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
