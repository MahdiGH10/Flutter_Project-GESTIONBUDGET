import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bar_chart_widget.dart';
import '../../widgets/pie_chart_widget.dart';
import '../../widgets/transaction_table_widget.dart';
import '../../widgets/shared_widgets.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  String _timeRange = 'month'; // day | week | month | year
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, CategoryProvider>(
      builder: (context, txnProvider, categoryProvider, _) {
        final categoryLookup = {
          for (final c in DefaultCategories.all) c.id: c,
          for (final c in categoryProvider.customCategories) c.id: c,
        };

        final filteredTxns = _filterTransactions(txnProvider.transactions);
        final totalIncome = _sum(filteredTxns.where((t) => t.isIncome));
        final totalExpense = _sum(filteredTxns.where((t) => t.isExpense));
        final saved = totalIncome - totalExpense;

        final expenseByCategory = _getExpenseByCategory(filteredTxns);
        final monthlyIncomeExpense = _getMonthlyIncomeExpenseSeries(filteredTxns);
        final balanceSeries = monthlyIncomeExpense
            .map((e) => MapEntry(e.label, e.income - e.expense))
            .toList();

        final hasData = filteredTxns.isNotEmpty;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    Text('Statistics', style: AppTheme.h2Bold.copyWith(fontSize: 20)),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.insights, color: AppTheme.neutral900),
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
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.neutral100,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: ['Day', 'Week', 'Month', 'Year'].map((range) {
                    final key = range.toLowerCase();
                    final isActive = _timeRange == key;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _timeRange = key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isActive ? AppTheme.shadowSm : null,
                          ),
                          child: Text(
                            range,
                            textAlign: TextAlign.center,
                            style: AppTheme.captionMedium.copyWith(
                              color: isActive ? AppTheme.neutral900 : AppTheme.neutral500,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (!hasData)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
                  child: EmptyState(
                    title: 'No data yet',
                    message: 'Add transactions to see your statistics and insights.',
                    icon: Icons.insights_outlined,
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.0, 0.35),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Row(
                      children: [
                        _StatCard(
                          label: 'Income',
                          value: totalIncome.toStringAsFixed(0),
                          color: AppTheme.success500,
                        ),
                        const SizedBox(width: 8),
                        _StatCard(
                          label: 'Expense',
                          value: totalExpense.toStringAsFixed(0),
                          color: AppTheme.danger500,
                        ),
                        const SizedBox(width: 8),
                        _StatCard(
                          label: 'Saved',
                          value: saved.toStringAsFixed(0),
                          color: AppTheme.neutral900,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _ChartCard(
                  title: 'Income vs Expense (Monthly)',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _LegendDot(color: AppTheme.success500, label: 'Income'),
                          const SizedBox(width: 12),
                          _LegendDot(color: AppTheme.danger500, label: 'Expense'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      BarChartWidget(data: monthlyIncomeExpense),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: _ChartCard(
                  title: 'Spending by Category',
                  child: PieChartWidget(
                    expenseByCategory: expenseByCategory,
                    categoryLookup: categoryLookup,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: _ChartCard(
                  title: 'Monthly Balance Trend',
                  child: SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= balanceSeries.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(balanceSeries[idx].key, style: AppTheme.smallMedium),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: balanceSeries
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                                .toList(),
                            color: AppTheme.primary900,
                            barWidth: 3,
                            isCurved: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primary900.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: _ChartCard(
                  title: 'Transactions Table',
                  child: TransactionTableWidget(
                    transactions: filteredTxns,
                    categoryLookup: categoryLookup,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ],
        );
      },
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final start = switch (_timeRange) {
      'day' => DateTime(now.year, now.month, now.day),
      'week' => DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6)),
      'month' => DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29)),
      _ => DateTime(now.year - 1, now.month, now.day),
    };

    return transactions
        .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, double> _getExpenseByCategory(List<Transaction> transactions) {
    final map = <String, double>{};
    for (final t in transactions) {
      if (t.isExpense) {
        map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
      }
    }
    return map;
  }

  List<IncomeExpensePoint> _getMonthlyIncomeExpenseSeries(
    List<Transaction> transactions,
  ) {
    final now = DateTime.now();
    final months = _timeRange == 'year' ? 12 : 6;

    return List.generate(months, (index) {
      final month = DateTime(now.year, now.month - (months - 1 - index), 1);
      final income = transactions
          .where((t) => t.isIncome && t.date.year == month.year && t.date.month == month.month)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      final expense = transactions
          .where((t) => t.isExpense && t.date.year == month.year && t.date.month == month.month)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      return IncomeExpensePoint(
        label: DateFormat('MMM').format(month),
        income: income,
        expense: expense,
      );
    });
  }

  double _sum(Iterable<Transaction> transactions) {
    return transactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTheme.h3SemiBold.copyWith(color: color, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTheme.smallMedium),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.h3SemiBold.copyWith(fontSize: 18)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.smallMedium),
      ],
    );
  }
}
