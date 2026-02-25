import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'add_transaction_page.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, txnProvider, _) {
        final allTxns = txnProvider.transactions;
        final filteredTxns = _filter == 'all'
            ? allTxns
            : _filter == 'income'
            ? allTxns.where((t) => t.isIncome).toList()
            : allTxns.where((t) => t.isExpense).toList();

        return CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    Text(
                      'Transactions',
                      style: AppTheme.h2Bold.copyWith(fontSize: 20),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        color: AppTheme.neutral900,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.neutral100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter Tabs
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.neutral100,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: ['all', 'income', 'expense'].map((f) {
                    final isActive = _filter == f;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isActive ? AppTheme.shadowSm : null,
                          ),
                          child: Text(
                            f[0].toUpperCase() + f.substring(1),
                            textAlign: TextAlign.center,
                            style: AppTheme.captionMedium.copyWith(
                              color: isActive
                                  ? AppTheme.neutral900
                                  : AppTheme.neutral500,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Summary Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppTheme.success500.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.trending_up,
                                    color: AppTheme.success500,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Income', style: AppTheme.smallMedium),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${txnProvider.totalIncome.toStringAsFixed(0)} TND',
                              style: AppTheme.h3SemiBold.copyWith(
                                color: AppTheme.success500,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppTheme.danger500.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.trending_down,
                                    color: AppTheme.danger500,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Expense', style: AppTheme.smallMedium),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${txnProvider.totalExpense.toStringAsFixed(0)} TND',
                              style: AppTheme.h3SemiBold.copyWith(
                                color: AppTheme.danger500,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HISTORY',
                      style: AppTheme.smallMedium.copyWith(
                        color: AppTheme.neutral500,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.filter_list,
                          color: AppTheme.neutral900,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Filter',
                          style: AppTheme.captionMedium.copyWith(
                            color: AppTheme.neutral900,
                          ),
                        ),
                      ],
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
            else if (filteredTxns.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: EmptyState(
                    title: 'No transactions yet',
                    message: 'Add your first income or expense to see it here.',
                    icon: Icons.receipt_long,
                    actionLabel: 'Add transaction',
                    onAction: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionPage(),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TransactionTile(
                        transaction: filteredTxns[index],
                        onDismissed: () {
                          txnProvider.deleteTransaction(filteredTxns[index].id);
                        },
                      ),
                    );
                  }, childCount: filteredTxns.length),
                ),
              ),
          ],
        );
      },
    );
  }
}
