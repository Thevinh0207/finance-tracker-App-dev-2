import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'ProfileSettingsPage.dart';
import 'widgets/AppBottomNavBar.dart';
import '../Model/Transaction.dart';
import '../helper/TransactionType.dart';
import '../util/AppRouteObserver.dart';
import '../viewModel/HomePageViewModel.dart';

class homePage extends StatelessWidget {
  final String userID;
  const homePage({super.key, required this.userID});

  @override
  Widget build(BuildContext context) {
    return mainDashboard(userID: userID);
  }
}

class mainDashboard extends StatefulWidget {
  final String userID;
  const mainDashboard({super.key, required this.userID});

  @override
  State<mainDashboard> createState() => _mainDashboardState();
}

class _mainDashboardState extends State<mainDashboard> with RouteAware {
  bool _balanceVisible = true;
  final HomePageViewModel _vm = HomePageViewModel();
  PageRoute? _subscribedRoute;

  @override
  void initState() {
    super.initState();
    _vm.load(widget.userID);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _subscribedRoute) {
      if (_subscribedRoute != null) {
        appRouteObserver.unsubscribe(this);
      }
      appRouteObserver.subscribe(this, route);
      _subscribedRoute = route;
    }
  }

  @override
  void didPopNext() {
    // Returned to HomePage from a pushed route — refresh data.
    _vm.refresh(widget.userID);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFF4A90D9),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            if (_vm.isLoading && _vm.user == null) {
              return  Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (_vm.error != null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Error: ${_vm.error}',
                    style:  TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _vm.refresh(widget.userID),
                    child: SingleChildScrollView(
                      physics:  AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildHeader(),
                          _buildBalanceCard(),
                           SizedBox(height: 12),
                          _buildWhiteSheet(),
                        ],
                      ),
                    ),
                  ),
                ),
                AppBottomNavBar(currentIndex: 0, userID: widget.userID),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Welcome back,',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                _vm.displayName.isEmpty ? 'User' : _vm.displayName,
                style:  TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _headerIconButton(Icons.notifications_outlined),
               SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  final user = _vm.user;
                  if (user == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileSettingsPage(user: user),
                    ),
                  );
                },
                child: _headerIconButton(Icons.person_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding:  EdgeInsets.all(20),
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
                 Text(
                  'Total Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                  child: Icon(
                    _balanceVisible ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ],
            ),
             SizedBox(height: 10),
            Text(
              _balanceVisible ? '\$${_formatAmount(_vm.totalBalance)}' : '••••••',
              style:  TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
             SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatBox('Income', _vm.income, isIncome: true)),
                 SizedBox(width: 12),
                Expanded(child: _buildStatBox('Expenses', _vm.expenses, isIncome: false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, double amount, {required bool isIncome}) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.greenAccent : Colors.orangeAccent,
                size: 14,
              ),
               SizedBox(width: 4),
              Text(
                label,
                style:  TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
           SizedBox(height: 4),
          Text(
            '\$${_formatAmount(amount)}',
            style:  TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteSheet() {
    return Container(
      decoration:  BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding:  EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Spending Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
           SizedBox(height: 20),
          Center(child: _buildDonutChart()),
           SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Income', '\$${_formatAmount(_vm.income)}',  Color(0xFF4CAF50)),
              _buildLegendItem('Expenses', '\$${_formatAmount(_vm.expenses)}',  Color(0xFFE53935)),
              _buildLegendItem('Savings', '\$${_formatAmount(_vm.savings)}',  Color(0xFF5C9BD6)),
            ],
          ),
           SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildActionButton('This Month', Icons.show_chart,  Color(0xFF4CAF50)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton('Savings Rate', Icons.trending_down,  Color(0xFFE65100)),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildRecentTransactions(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final sorted = [..._vm.transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    final recent = sorted.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A90D9),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (recent.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No transactions yet',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < recent.length; i++) ...[
                if (i > 0) SizedBox(height: 14),
                _buildTransactionTile(recent[i]),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildTransactionTile(Transaction t) {
    final isIncome = t.type == TransactionType.income;
    final amountText =
        '${isIncome ? '+' : '-'}\$${_formatAmount(t.amount)}';
    final amountColor =
        isIncome ? Color(0xFF4CAF50) : Color(0xFF1A1A2E);
    final typeLabel = isIncome
        ? 'Income'
        : t.type == TransactionType.expense
            ? 'Expense'
            : 'Transfer';

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
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
                _relativeDate(t.date),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amountText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            SizedBox(height: 2),
            Text(
              typeLabel,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  IconData _iconForTransaction(Transaction t) {
    if (t.type == TransactionType.income) return Icons.attach_money;
    if (t.type == TransactionType.transfer) return Icons.swap_horiz;
    final name = t.transactionName.toLowerCase();
    if (name.contains('grocery') || name.contains('food') || name.contains('restaurant')) {
      return Icons.shopping_cart_outlined;
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

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(date.year, date.month, date.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff > 1 && diff < 7) return '$diff days ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildDonutChart() {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: DonutChartPainter(
          income: _vm.income,
          expenses: _vm.expenses,
          savings: _vm.savings,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
             SizedBox(width: 6),
            Text(label, style:  TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
         SizedBox(height: 4),
        Text(
          amount,
          style:  TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Container(
      padding:  EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
           SizedBox(width: 8),
          Text(
            label,
            style:  TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
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

class DonutChartPainter extends CustomPainter {
  final double income;
  final double expenses;
  final double savings;

  DonutChartPainter({
    required this.income,
    required this.expenses,
    required this.savings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = income + expenses + savings;
    if (total <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 36.0;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final segments = [
      {'value': income, 'color':  Color(0xFF4CAF50)},
      {'value': expenses, 'color':  Color(0xFFE53935)},
      {'value': savings, 'color':  Color(0xFF5C9BD6)},
    ];

    double startAngle = -math.pi / 2;
    const gapAngle = 0.04;

    for (final seg in segments) {
      final value = seg['value'] as double;
      final color = seg['color'] as Color;
      if (value <= 0) continue;
      final sweepAngle = (value / total) * 2 * math.pi - gapAngle;

      final paint = Paint();
        paint.color = color;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = strokeWidth;
        paint.strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter old) =>
      old.income != income || old.expenses != expenses || old.savings != savings;
}
