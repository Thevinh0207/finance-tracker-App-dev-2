import 'package:flutter/material.dart';

import '../Model/FamilyMember.dart';
import '../Model/SharedExpense.dart';
import '../Model/User.dart';
import '../util/AppLocalizations.dart';
import '../viewModel/FamilyViewModel.dart';
import 'widgets/AppBottomNavBar.dart';

class FamilyPage extends StatefulWidget {
  final String userID;
  const FamilyPage({super.key, required this.userID});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  late final FamilyViewModel _vm;

  static const _gradStart = Color(0xFF7B2FBE);
  static const _gradEnd = Color(0xFFDA44BB);
  static const _darkText = Color(0xFF1A1A2E);
  static const _greyText = Color(0xFF888888);
  static const _green = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _vm = FamilyViewModel();
    _vm.load(widget.userID);
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
    return '${m[d.month - 1]} ${d.day}';
  }

  static const _avatarColors = [
    Color(0xFF9C27B0),
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
  ];

  Color _avatarColor(String name) =>
      _avatarColors[name.codeUnitAt(0) % _avatarColors.length];

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  IconData _expenseIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'rent':
      case 'home':
        return Icons.home_rounded;
      case 'groceries':
      case 'food':
        return Icons.shopping_cart_rounded;
      case 'internet':
      case 'wifi':
      case 'bills':
      case 'utilities':
        return Icons.wifi_rounded;
      case 'dining':
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'transport':
      case 'gas':
        return Icons.directions_car_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'health':
        return Icons.local_hospital_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  Color _expenseColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'rent':
      case 'home':
        return const Color(0xFFFF7043);
      case 'groceries':
      case 'food':
        return const Color(0xFF66BB6A);
      case 'internet':
      case 'wifi':
      case 'bills':
      case 'utilities':
        return const Color(0xFF42A5F5);
      case 'dining':
      case 'restaurant':
        return const Color(0xFFFF8A65);
      case 'transport':
      case 'gas':
        return const Color(0xFF78909C);
      case 'entertainment':
        return const Color(0xFFAB47BC);
      case 'health':
        return const Color(0xFFEF5350);
      case 'education':
        return const Color(0xFF26A69A);
      default:
        return const Color(0xFF9C27B0);
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
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: _vm.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: _gradStart))
                        : _vm.hasGroup
                            ? _buildBody()
                            : _buildSetupState(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          AppBottomNavBar(currentIndex: 4, userID: widget.userID),
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
                children: [
                  Text(
                    AppLocalizations.tr('family_plan'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_vm.hasGroup && !_vm.hasMultipleGroups)
                    Text(
                      _vm.group!.groupName,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                ],
              ),
              if (_vm.hasGroup)
                GestureDetector(
                  onTap: _showGroupSettings,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.settings_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
            ],
          ),
          if (_vm.hasMultipleGroups) ...[
            const SizedBox(height: 14),
            _buildGroupSwitcher(),
          ],
          if (_vm.hasGroup) ...[
            const SizedBox(height: 14),
            _buildBudgetCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupSwitcher() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _vm.groups.asMap().entries.map((entry) {
          final i = entry.key;
          final g = entry.value;
          final selected = i == _vm.selectedIndex;
          return GestureDetector(
            onTap: () => _vm.switchToGroup(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white
                    : Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                g.groupName,
                style: TextStyle(
                  color: selected ? _gradStart : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBudgetCard() {
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
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          color: Colors.white70, size: 15),
                      const SizedBox(width: 5),
                      Text(AppLocalizations.tr('family_budget'),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_fmt(_vm.totalBudget)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppLocalizations.tr('family_spent'),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_fmt(_vm.totalSpent)}',
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
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _vm.budgetProgress,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return RefreshIndicator(
      color: _gradStart,
      onRefresh: () => _vm.load(widget.userID),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMembersSection(),
            const SizedBox(height: 24),
            _buildExpensesSection(),
            const SizedBox(height: 16),
            _buildInsightsCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Members ───────────────────────────────────────────────────────────────

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.tr('family_members'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddMemberSheet,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(AppLocalizations.tr('add')),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gradStart,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_vm.members.isEmpty)
          _emptyCard(AppLocalizations.tr('family_no_members'))
        else
          ..._vm.members.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMemberCard(m),
              )),
      ],
    );
  }

  Widget _buildMemberCard(FamilyMember member) {
    final color = _avatarColor(member.displayName);
    final initials = _initials(member.displayName);
    final currentUserIsAdmin = _vm.isUserAdmin(widget.userID);
    final isCurrentUser = member.userID == widget.userID;

    // Show remove button if: admin looking at non-admin member
    final showRemove = currentUserIsAdmin && !member.isAdmin;
    // Show leave button if: non-admin looking at their own card
    final showLeave = !currentUserIsAdmin && isCurrentUser;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(24)),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          member.displayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (member.isAdmin) ...[
                          const SizedBox(width: 5),
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFFB300), size: 16),
                        ],
                      ],
                    ),
                    Text(
                      member.isAdmin
                          ? AppLocalizations.tr('family_admin')
                          : AppLocalizations.tr('family_member'),
                      style: const TextStyle(
                          fontSize: 12, color: _greyText),
                    ),
                  ],
                ),
              ),
              if (showRemove)
                IconButton(
                  icon: const Icon(Icons.person_remove_rounded,
                      color: Colors.red, size: 20),
                  tooltip: AppLocalizations.tr('family_remove_title'),
                  onPressed: () => _confirmRemoveMember(member),
                )
              else if (showLeave)
                TextButton(
                  onPressed: () => _confirmLeaveGroup(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                  ),
                  child: Text(AppLocalizations.tr('family_leave_btn'),
                      style: const TextStyle(fontSize: 13)),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${_fmt(member.spent)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${AppLocalizations.tr('family_of')} \$${_fmt(member.budgetAllocation)}',
                      style: const TextStyle(
                          fontSize: 12, color: _greyText),
                    ),
                  ],
                ),
            ],
          ),
          if (showRemove || showLeave) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '\$${_fmt(member.spent)} ${AppLocalizations.tr('family_of')} \$${_fmt(member.budgetAllocation)}',
                  style: const TextStyle(fontSize: 12, color: _greyText),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: member.progress,
              backgroundColor: Colors.grey.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation(_green),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared Expenses ───────────────────────────────────────────────────────

  Widget _buildExpensesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.tr('family_shared_expenses'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            GestureDetector(
              onTap: _showAddExpenseSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _gradStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('+ ${AppLocalizations.tr('add')}',
                    style: const TextStyle(
                        color: _gradStart,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_vm.sharedExpenses.isEmpty)
          _emptyCard(AppLocalizations.tr('family_no_expenses'))
        else
          ..._vm.sharedExpenses.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildExpenseCard(e),
              )),
      ],
    );
  }

  Widget _buildExpenseCard(SharedExpense expense) {
    final memberCount =
        _vm.members.isNotEmpty ? _vm.members.length : 1;
    final perPerson = expense.amount / memberCount;
    final iconColor = _expenseColor(expense.categoryIcon);

    return GestureDetector(
      onLongPress: () => _confirmDeleteExpense(expense),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_expenseIcon(expense.categoryIcon),
                  color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
                  Text('${AppLocalizations.tr('family_paid_by_prefix')} ${expense.paidByName}',
                      style: const TextStyle(
                          fontSize: 12, color: _greyText)),
                  Text(_fmtDate(expense.date),
                      style: const TextStyle(
                          fontSize: 11, color: _greyText)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${_fmt(expense.amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '\$${perPerson.toStringAsFixed(2)}${AppLocalizations.tr('family_per_person')}',
                  style:
                      const TextStyle(fontSize: 11, color: _greyText),
                ),
              ],
            ),
          ],
        ),
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
                Text(AppLocalizations.tr('family_insights'),
                    style: const TextStyle(
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

  // ── Setup State ───────────────────────────────────────────────────────────

  Widget _buildSetupState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _gradStart.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline_rounded,
                  color: _gradStart, size: 48),
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.tr('family_setup_title'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                )),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.tr('family_setup_body'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: _greyText, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _showCreateGroupSheet,
              icon: const Icon(Icons.add_rounded),
              label: Text(AppLocalizations.tr('family_create_btn')),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gradStart,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16)),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _greyText)),
    );
  }

  // ── Sheets ────────────────────────────────────────────────────────────────

  void _showCreateGroupSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateGroupSheet(
        onCreate: (groupName, totalBudget, adminBudget) async {
          await _vm.createGroup(
            groupName: groupName,
            adminUserID: widget.userID,
            adminDisplayName: _vm.currentUserName.isNotEmpty
                ? _vm.currentUserName
                : 'Me',
            totalBudget: totalBudget,
            adminBudget: adminBudget,
          );
        },
      ),
    );
  }

  void _showAddMemberSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMemberSheet(
        onLookup: (email) => _vm.lookupUserByEmail(email),
        isMember: (userID) => _vm.isMember(userID),
        onAdd: (user, budget) async {
          await _vm.addMember(
            userID: user.userID,
            displayName: '${user.firstName} ${user.lastName}'.trim(),
            budgetAllocation: budget,
          );
        },
      ),
    );
  }

  void _showAddExpenseSheet() {
    if (_vm.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.tr('family_add_members_first'))),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExpenseSheet(
        members: _vm.members,
        onAdd: (name, amount, paidByMember, category) async {
          await _vm.addSharedExpense(
            name: name,
            amount: amount,
            paidByUserID: paidByMember.userID,
            paidByName: paidByMember.displayName,
            categoryIcon: category,
          );
        },
      ),
    );
  }

  void _showGroupSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GroupSettingsSheet(
        group: _vm.group!,
        onUpdateBudget: (newBudget) async {
          await _vm.updateGroupBudget(widget.userID, newBudget);
        },
      ),
    );
  }

  Future<void> _confirmRemoveMember(FamilyMember member) async {
    if (member.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.tr('family_cannot_remove_admin'))),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.tr('family_remove_title')),
        content: Text('${AppLocalizations.tr('family_remove')} ${member.displayName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.tr('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.tr('family_remove')),
          ),
        ],
      ),
    );
    if (ok == true) await _vm.removeMember(member);
  }

  Future<void> _confirmLeaveGroup() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.tr('family_leave_title')),
        content: Text(AppLocalizations.tr('family_leave_confirm')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.tr('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.tr('family_leave_btn')),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _vm.leaveGroup(widget.userID);
      // Reload — user may still be in other groups.
      if (mounted) await _vm.load(widget.userID);
    }
  }

  Future<void> _confirmDeleteExpense(SharedExpense expense) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.tr('family_delete_expense_title')),
        content: Text('${AppLocalizations.tr('delete')} "${expense.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.tr('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.tr('delete')),
          ),
        ],
      ),
    );
    if (ok == true) await _vm.deleteSharedExpense(expense);
  }
}

// ── Create Group Sheet ────────────────────────────────────────────────────────

class _CreateGroupSheet extends StatefulWidget {
  final Future<void> Function(
      String groupName, double totalBudget, double adminBudget) onCreate;

  const _CreateGroupSheet({required this.onCreate});

  @override
  State<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<_CreateGroupSheet> {
  final _nameCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _myBudgetCtrl = TextEditingController();
  bool _saving = false;

  static const _gradStart = Color(0xFF7B2FBE);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    _myBudgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 0;
    final myBudget = double.tryParse(_myBudgetCtrl.text.trim()) ?? 0;
    if (name.isEmpty || budget <= 0 || myBudget <= 0) return;
    setState(() => _saving = true);
    await widget.onCreate(name, budget, myBudget);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            Text(AppLocalizations.tr('family_create_btn'),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _field(AppLocalizations.tr('family_group_name'), _nameCtrl,
                hint: 'e.g. Doe Family'),
            const SizedBox(height: 12),
            _field(AppLocalizations.tr('family_total_budget'), _budgetCtrl,
                hint: '5000'),
            const SizedBox(height: 12),
            _field(AppLocalizations.tr('family_personal_budget'), _myBudgetCtrl,
                hint: '2000'),
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
                    : Text(AppLocalizations.tr('family_create_plan_btn'),
                        style: const TextStyle(
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
      {String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF888888))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: label.contains('\$')
              ? TextInputType.number
              : TextInputType.text,
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

// ── Add Member Sheet ──────────────────────────────────────────────────────────

class _AddMemberSheet extends StatefulWidget {
  final Future<User?> Function(String email) onLookup;
  final bool Function(String userID) isMember;
  final Future<void> Function(User user, double budget) onAdd;

  const _AddMemberSheet({
    required this.onLookup,
    required this.isMember,
    required this.onAdd,
  });

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _emailCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

  User? _foundUser;
  String? _lookupError;
  bool _looking = false;
  bool _saving = false;

  static const _gradStart = Color(0xFF7B2FBE);
  static const _green = Color(0xFF4CAF50);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _looking = true;
      _foundUser = null;
      _lookupError = null;
    });
    final user = await widget.onLookup(email);
    if (!mounted) return;
    if (user == null) {
      setState(() {
        _lookupError = AppLocalizations.tr('family_not_found');
        _looking = false;
      });
    } else if (widget.isMember(user.userID)) {
      setState(() {
        _lookupError = '${user.firstName} ${AppLocalizations.tr('family_already_member')}';
        _looking = false;
      });
    } else {
      setState(() {
        _foundUser = user;
        _looking = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_foundUser == null) return;
    final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 0;
    if (budget <= 0) return;
    setState(() => _saving = true);
    await widget.onAdd(_foundUser!, budget);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            Text(AppLocalizations.tr('family_add_member_title'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.tr('family_add_member_hint'),
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.tr('family_email'),
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _lookup(),
                    decoration: InputDecoration(
                      hintText: 'jane@example.com',
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
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _looking ? null : _lookup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gradStart,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: _looking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(AppLocalizations.tr('family_look_up'),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            if (_lookupError != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_lookupError!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
            if (_foundUser != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF4),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: _green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: _green, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_foundUser!.firstName} ${_foundUser!.lastName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            _foundUser!.email,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF555555)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.tr('family_budget_alloc'),
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF888888))),
              const SizedBox(height: 8),
              TextField(
                controller: _budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '1500',
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
                      : Text(AppLocalizations.tr('family_add_to_plan'),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Add Expense Sheet ─────────────────────────────────────────────────────────

class _AddExpenseSheet extends StatefulWidget {
  final List<FamilyMember> members;
  final Future<void> Function(
      String name, double amount, FamilyMember paidBy, String category) onAdd;

  const _AddExpenseSheet(
      {required this.members, required this.onAdd});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  late FamilyMember _paidBy;
  String _category = 'other';
  bool _saving = false;

  static const _gradStart = Color(0xFF7B2FBE);

  static const _categories = [
    'rent',
    'groceries',
    'utilities',
    'dining',
    'internet',
    'transport',
    'entertainment',
    'health',
    'education',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _paidBy = widget.members.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  String _catLabel(String c) =>
      c[0].toUpperCase() + c.substring(1);

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (name.isEmpty || amount <= 0) return;
    setState(() => _saving = true);
    await widget.onAdd(name, amount, _paidBy, _category);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            Text(AppLocalizations.tr('family_add_expense_title'),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text(AppLocalizations.tr('family_expense_name'),
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF888888))),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. Monthly Rent',
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
            const SizedBox(height: 12),
            Text(AppLocalizations.tr('family_amount'),
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF888888))),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '500',
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
            const SizedBox(height: 12),
            Text(AppLocalizations.tr('family_paid_by'),
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF888888))),
            const SizedBox(height: 8),
            DropdownButtonFormField<FamilyMember>(
              value: _paidBy,
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
              items: widget.members
                  .map((m) => DropdownMenuItem(
                      value: m, child: Text(m.displayName)))
                  .toList(),
              onChanged: (v) => setState(() => _paidBy = v!),
            ),
            const SizedBox(height: 12),
            Text(AppLocalizations.tr('family_category'),
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF888888))),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
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
              items: _categories
                  .map((c) => DropdownMenuItem(
                      value: c, child: Text(_catLabel(c))))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gradStart,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(AppLocalizations.tr('family_add_expense_btn'),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Group Settings Sheet ──────────────────────────────────────────────────────

class _GroupSettingsSheet extends StatefulWidget {
  final dynamic group;
  final Future<void> Function(double newBudget) onUpdateBudget;

  const _GroupSettingsSheet(
      {required this.group, required this.onUpdateBudget});

  @override
  State<_GroupSettingsSheet> createState() => _GroupSettingsSheetState();
}

class _GroupSettingsSheetState extends State<_GroupSettingsSheet> {
  late final TextEditingController _budgetCtrl;
  bool _saving = false;

  static const _gradStart = Color(0xFF7B2FBE);

  @override
  void initState() {
    super.initState();
    _budgetCtrl = TextEditingController(
        text: widget.group.totalBudget.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 0;
    if (budget <= 0) return;
    setState(() => _saving = true);
    await widget.onUpdateBudget(budget);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
          Text(AppLocalizations.tr('family_settings_title'),
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${widget.group.groupName}',
              style: const TextStyle(color: Color(0xFF888888))),
          const SizedBox(height: 20),
          Text(AppLocalizations.tr('family_total_budget'),
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
          const SizedBox(height: 8),
          TextField(
            controller: _budgetCtrl,
            keyboardType: TextInputType.number,
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
                  : Text(AppLocalizations.tr('family_save_changes'),
                      style: const TextStyle(
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
