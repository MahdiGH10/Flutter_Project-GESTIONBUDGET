import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, txnProvider, _) {
        final recentTxns = txnProvider.transactions.take(5).toList();

        return CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary900,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'AJ',
                          style: AppTheme.bodySemiBold.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: AppTheme.smallMedium.copyWith(
                            color: AppTheme.neutral500,
                          ),
                        ),
                        Text(
                          'Alex Johnson',
                          style: AppTheme.bodySemiBold.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.neutral100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none,
                            color: AppTheme.neutral900,
                            size: 22,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.danger500,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Balance Card
            SliverToBoxAdapter(
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animController,
                        curve: const Interval(
                          0.0,
                          0.5,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.0, 0.4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: BalanceCard(
                      balance: txnProvider.balance,
                      income: txnProvider.totalIncome,
                      expense: txnProvider.totalExpense,
                    ),
                  ),
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.3, 0.6),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _QuickAction(
                        icon: Icons.add,
                        label: 'Add Income',
                        color: AppTheme.success500,
                        onTap: () =>
                            _showAddTransaction(context, isIncome: true),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.credit_card,
                        label: 'Add Expense',
                        color: AppTheme.danger500,
                        onTap: () =>
                            _showAddTransaction(context, isIncome: false),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.track_changes,
                        label: 'Goals',
                        color: AppTheme.primary900,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Recent Transactions header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: AppTheme.h3SemiBold.copyWith(fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: AppTheme.captionMedium.copyWith(
                          color: AppTheme.success500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Transaction list / loading / empty state
            if (txnProvider.isLoading)
              const SliverFillRemaining(
                hasScrollBody: true,
                child: TransactionListSkeleton(),
              )
            else if (recentTxns.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  child: EmptyState(
                    title: 'No recent transactions',
                    message: 'Your latest activity will appear here once you add a transaction.',
                    icon: Icons.receipt_long,
                    actionLabel: 'Add transaction',
                    onAction: () => _showAddTransaction(
                      context,
                      isIncome: false,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TransactionTile(transaction: recentTxns[index]),
                      ),
                    );
                  }, childCount: recentTxns.length),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showAddTransaction(BuildContext context, {required bool isIncome}) {
    // Navigate to Add Transaction - handled by parent
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTheme.smallMedium.copyWith(
                  color: AppTheme.neutral900,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
