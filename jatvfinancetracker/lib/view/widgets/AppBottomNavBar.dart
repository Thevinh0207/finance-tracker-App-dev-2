import 'package:flutter/material.dart';

import '../../util/AppLocalizations.dart';
import '../BudgetTrackerPage.dart';
import '../FamilyPage.dart';
import '../GoalsPage.dart';
import '../MoneyFlowPage.dart';
import '../TransactionHistoryPage.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final String userID;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.userID,
  });

  static List<_NavItem> get _items => [
    _NavItem(Icons.home_rounded, AppLocalizations.tr('nav_home')),
    _NavItem(Icons.history, AppLocalizations.tr('nav_history')),
    _NavItem(Icons.attach_money, AppLocalizations.tr('nav_money')),
    _NavItem(Icons.pie_chart_outline, AppLocalizations.tr('nav_budget')),
    _NavItem(Icons.people_outline, AppLocalizations.tr('nav_family')),
    _NavItem(Icons.track_changes_outlined, AppLocalizations.tr('nav_goals')),
  ];

  void _handleTap(BuildContext context, int target) {
    if (target == currentIndex) return;

    switch (target) {
      case 0:
        // HomePage is always at the bottom of the stack.
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
        if (currentIndex == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionHistoryPage(userID: userID),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionHistoryPage(userID: userID),
            ),
          );
        }
        break;
      case 2:
        if (currentIndex == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MoneyFlowPage(userID: userID),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MoneyFlowPage(userID: userID),
            ),
          );
        }
        break;
      case 3:
        if (currentIndex == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BudgetTrackerPage(userID: userID),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BudgetTrackerPage(userID: userID),
            ),
          );
        }
        break;
      case 4:
        if (currentIndex == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FamilyPage(userID: userID),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => FamilyPage(userID: userID),
            ),
          );
        }
        break;
      case 5:
        if (currentIndex == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GoalsPage(userID: userID),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GoalsPage(userID: userID),
            ),
          );
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final item = _items[i];
            final selected = i == currentIndex;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleTap(context, i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: selected ? Color(0xFF4A90D9) : Colors.grey,
                    size: 24,
                  ),
                  SizedBox(height: 3),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: selected ? Color(0xFF4A90D9) : Colors.grey,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
