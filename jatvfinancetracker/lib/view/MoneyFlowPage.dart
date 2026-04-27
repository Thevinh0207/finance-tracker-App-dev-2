import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../viewModel/MoneyFlowViewModel.dart';
import 'widgets/AppBottomNavBar.dart';

class MoneyFlowPage extends StatefulWidget {
  final String userID;
  const MoneyFlowPage({super.key, required this.userID});

  @override
  State<MoneyFlowPage> createState() => _MoneyFlowPageState();
}

class _MoneyFlowPageState extends State<MoneyFlowPage> {
  late final MoneyFlowViewModel _vm;
  int _selectedTab = 0;

  static const _primaryBlue = Color(0xFF4A90D9);
  static const _incomeGreen = Color(0xFF4CAF50);
  static const _expenseRed = Color(0xFFE53935);
  static const _darkText = Color(0xFF1A1A2E);
  static const _greyText = Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    _vm = MoneyFlowViewModel();
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

  String _fmtAxis(double val) {
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}k';
    return val.toStringAsFixed(0);
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: _vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: _primaryBlue),
                        )
                      : _vm.error != null
                          ? _buildError()
                          : _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        userID: widget.userID,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: _expenseRed, size: 48),
          const SizedBox(height: 12),
          Text(
            'Failed to load data',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _darkText),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _vm.refresh(widget.userID),
            child: const Text('Retry', style: TextStyle(color: _primaryBlue)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          const SizedBox(height: 16),
          _buildChart(),
          const SizedBox(height: 16),
          _buildNetCashFlow(),
          if (_selectedTab != 0) ...[
            const SizedBox(height: 16),
            _buildCategoryBreakdown(),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Money Flow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  label: 'Total Income',
                  amount: _vm.currentIncome,
                  icon: Icons.arrow_downward_rounded,
                  iconColor: _incomeGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  label: 'Total Expenses',
                  amount: _vm.currentExpenses,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: _expenseRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required double amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 13),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '\$${_fmt(amount)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'This month',
            style: TextStyle(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    const tabs = ['Overview', 'Income', 'Expenses'];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? _primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? Colors.white : _greyText,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Bar Chart ─────────────────────────────────────────────────────────────

  Widget _buildChart() {
    final data = _vm.monthlyData;

    double maxVal = 0;
    for (final d in data) {
      if (_selectedTab != 2 && d.income > maxVal) maxVal = d.income;
      if (_selectedTab != 1 && d.expense > maxVal) maxVal = d.expense;
    }
    if (maxVal == 0) maxVal = 1000;

    final interval = (maxVal / 4).ceilToDouble();
    final chartMax = interval * 4 * 1.05;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              '6-Month Trend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _darkText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: chartMax,
                minY: 0,
                groupsSpace: 12,
                barGroups: List.generate(
                  data.length,
                  (i) => _barGroup(i, data[i]),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.withOpacity(0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval,
                      getTitlesWidget: (val, meta) {
                        if (val == 0 || val >= chartMax) {
                          return const SizedBox();
                        }
                        return Text(
                          _fmtAxis(val),
                          style: const TextStyle(fontSize: 9, color: _greyText),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= data.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data[idx].label,
                            style: const TextStyle(fontSize: 10, color: _greyText),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF2C3E50),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isIncome =
                          (_selectedTab == 0 && rodIndex == 0) ||
                          _selectedTab == 1;
                      return BarTooltipItem(
                        '${isIncome ? 'Income' : 'Expense'}\n\$${_fmt(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedTab != 2) ...[
                _dot(_incomeGreen),
                const SizedBox(width: 4),
                const Text(
                  'Income',
                  style: TextStyle(fontSize: 11, color: _greyText),
                ),
                const SizedBox(width: 16),
              ],
              if (_selectedTab != 1) ...[
                _dot(_expenseRed),
                const SizedBox(width: 4),
                const Text(
                  'Expense',
                  style: TextStyle(fontSize: 11, color: _greyText),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, MonthlyData d) {
    final rods = <BarChartRodData>[];
    final barW = _selectedTab == 0 ? 10.0 : 16.0;
    const topRadius = BorderRadius.vertical(top: Radius.circular(5));

    if (_selectedTab != 2) {
      rods.add(BarChartRodData(
        toY: d.income,
        color: _incomeGreen,
        width: barW,
        borderRadius: topRadius,
      ));
    }
    if (_selectedTab != 1) {
      rods.add(BarChartRodData(
        toY: d.expense,
        color: _expenseRed,
        width: barW,
        borderRadius: topRadius,
      ));
    }
    return BarChartGroupData(x: x, barRods: rods, barsSpace: 6);
  }

  // ── Net Cash Flow ─────────────────────────────────────────────────────────

  Widget _buildNetCashFlow() {
    final net = _vm.netCashFlow;
    final positive = net >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: positive
              ? [const Color(0xFF2E7D32), const Color(0xFF66BB6A)]
              : [const Color(0xFFB71C1C), const Color(0xFFEF5350)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Net Cash Flow',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                '${positive ? '+' : '-'}\$${_fmt(net.abs())}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                positive
                    ? 'Great job! You\'re saving this month.'
                    : 'Expenses exceed income this month.',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              positive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Breakdown ────────────────────────────────────────────────────

  Widget _buildCategoryBreakdown() {
    final isIncome = _selectedTab == 1;
    final categories =
        isIncome ? _vm.incomeByCategory : _vm.expensesByCategory;

    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No ${isIncome ? 'income' : 'expense'} categories this month.',
            style: const TextStyle(color: _greyText, fontSize: 13),
          ),
        ),
      );
    }

    final total =
        categories.values.fold<double>(0, (s, v) => s + v);
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final barColor = isIncome ? _incomeGreen : _expenseRed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isIncome ? 'Income by Category' : 'Expenses by Category',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 14),
          ...sorted.take(5).map((e) {
            final pct = total > 0 ? e.value / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _darkText,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${_fmt(e.value)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _darkText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '${(pct * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _greyText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.grey.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation(barColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _dot(Color color) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
