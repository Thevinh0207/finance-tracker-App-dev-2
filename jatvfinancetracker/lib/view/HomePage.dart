import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'loginPage.dart';

void main() => runApp(homePage());

class homePage extends StatelessWidget {
  const homePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: mainDashboard(),
    );
  }
}

class mainDashboard extends StatefulWidget {
  const mainDashboard({super.key});

  @override
  State<mainDashboard> createState() => _mainDashboardState();
}

class _mainDashboardState extends State<mainDashboard> {
  int _selectedIndex = 0;
  bool _balanceVisible = true;

  final double totalBalance = 25430.50;
  final double income = 12500;
  final double expenses = 8200;
  final double savings = 4300;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A90D9),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildBalanceCard(),
                        SizedBox(height: 12),
                        _buildWhiteSheet(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                'John Doe',
                style: TextStyle(
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => loginPage()),
                  );
                },
                child: _headerIconButton(Icons.logout),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
                const Text(
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
            const SizedBox(height: 10),
            Text(
              _balanceVisible ? '\$${_formatAmount(totalBalance)}' : '••••••',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatBox('Income', income, isIncome: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatBox('Expenses', expenses, isIncome: false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, double amount, {required bool isIncome}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            '\$${_formatAmount(amount)}',
            style: TextStyle(
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.all(20),
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
              _buildLegendItem('Income', '\$${_formatAmount(income)}', const Color(0xFF4CAF50)),
              _buildLegendItem('Expenses', '\$${_formatAmount(expenses)}', const Color(0xFFE53935)),
              _buildLegendItem('Savings', '\$${_formatAmount(savings)}', const Color(0xFF5C9BD6)),
            ],
          ),

          SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'This Month',
                  Icons.show_chart,
                  const Color(0xFF4CAF50),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Savings Rate',
                  Icons.trending_down,
                  Color(0xFFE65100),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDonutChart() {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: DonutChartPainter(
          income: income,
          expenses: expenses,
          savings: savings,
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
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
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
      padding: EdgeInsets.symmetric(vertical: 14),
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
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.history, 'label': 'History'},
      {'icon': Icons.attach_money, 'label': 'Money'},
      {'icon': Icons.pie_chart_outline, 'label': 'Budget'},
      {'icon': Icons.people_outline, 'label': 'Family'},
      {'icon': Icons.track_changes_outlined, 'label': 'Goals'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = _selectedIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  items[i]['icon'] as IconData,
                  color: selected ? Color(0xFF4A90D9) : Colors.grey,
                  size: 24,
                ),
                SizedBox(height: 3),
                Text(
                  items[i]['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: selected ? Color(0xFF4A90D9) : Colors.grey,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
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
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 36.0;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final segments = [
      {'value': income, 'color':  Color(0xFF4CAF50)},
      {'value': expenses, 'color': Color(0xFFE53935)},
      {'value': savings, 'color': Color(0xFF5C9BD6)},
    ];

    double startAngle = -math.pi / 2;
    const gapAngle = 0.04;

    for (final seg in segments) {
      final value = seg['value'] as double;
      final color = seg['color'] as Color;
      final sweepAngle = (value / total) * 2 * math.pi - gapAngle;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}