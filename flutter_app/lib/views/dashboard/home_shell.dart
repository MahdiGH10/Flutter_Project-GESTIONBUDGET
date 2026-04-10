import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../theme/app_theme.dart';
import '../dashboard/dashboard_page.dart';
import '../transaction/transaction_list_page.dart';
import '../transaction/add_transaction_page.dart';
import '../category/category_page.dart';
import '../report/report_page.dart';
import '../settings/budget_goal_page.dart';
import '../settings/profile_page.dart';
import '../../widgets/speed_dial_fab.dart';

class HomeShell extends StatefulWidget {
  final String? successMessage;
  final bool? successIsIncome;

  const HomeShell({
    super.key,
    this.successMessage,
    this.successIsIncome,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      DashboardPage(),
      TransactionListPage(),
      CategoryPage(),
      ReportPage(),
      ProfilePage(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.successMessage == null) return;

      final isIncome = widget.successIsIncome ?? false;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(widget.successMessage!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isIncome
                ? AppTheme.success500
                : AppTheme.danger500,
            duration: const Duration(seconds: 3),
          ),
        );
    });
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> _openAddTransaction({required bool isIncome}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddTransactionPage(
          initialType: isIncome ? CategoryType.income : CategoryType.expense,
        ),
      ),
    );

    if (!mounted || saved != true) return;

    setState(() => _currentIndex = 0);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isIncome ? 'Income added successfully.' : 'Expense added successfully.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isIncome ? AppTheme.success500 : AppTheme.danger500,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _openBudgetGoals() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BudgetGoalPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral100,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _pages[_currentIndex],
        ),
      ),
      floatingActionButton: SpeedDialFab(
        onAddIncome: () => _openAddTransaction(isIncome: true),
        onAddExpense: () => _openAddTransaction(isIncome: false),
        onOpenGoals: _openBudgetGoals,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary900.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => _onTabTapped(0),
                ),
                _NavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  label: 'Transactions',
                  isActive: _currentIndex == 1,
                  onTap: () => _onTabTapped(1),
                ),
                _NavItem(
                  icon: Icons.category_outlined,
                  activeIcon: Icons.category,
                  label: 'Categories',
                  isActive: _currentIndex == 2,
                  onTap: () => _onTabTapped(2),
                ),
                _NavItem(
                  icon: Icons.pie_chart_outline,
                  activeIcon: Icons.pie_chart,
                  label: 'Stats',
                  isActive: _currentIndex == 3,
                  onTap: () => _onTabTapped(3),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isActive: _currentIndex == 4,
                  onTap: () => _onTabTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive ? AppTheme.primary900 : AppTheme.neutral400,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppTheme.primary900 : AppTheme.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
