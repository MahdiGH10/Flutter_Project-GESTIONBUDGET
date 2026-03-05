import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  String _timeRange = 'month';
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
        final filteredTxns = _filterTransactions(txnProvider.transactions);
        final expenseByCategory = _getExpenseByCategory(filteredTxns);
        final barSeries = _getBarSeries(filteredTxns);
        final totalExpense = _sum(filteredTxns.where((t) => t.isExpense));
        final totalIncome = _sum(filteredTxns.where((t) => t.isIncome));
        final monthlySeries = _getMonthlyBalanceSeries(
          filteredTxns,
          _timeRange == 'year' ? 12 : 6,
        );
        final saved = totalIncome - totalExpense;

        final categoryEntries = expenseByCategory.entries.toList();
        final pieData = categoryEntries.map((entry) {
          final cat = DefaultCategories.all
              .where((c) => c.id == entry.key)
              .firstOrNull;
          return PieChartSectionData(
            value: entry.value,
            color: cat?.color ?? AppTheme.neutral400,
            title: '',
            radius: 40,
          );
        }).toList();

        final hasData = filteredTxns.isNotEmpty;
        final slivers = <Widget>[
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Text(
                    'Statistics',
                    style: AppTheme.h2Bold.copyWith(fontSize: 20),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_horiz,
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
                  final isActive = _timeRange == range.toLowerCase();
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _timeRange = range.toLowerCase()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
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
                            color: isActive
                                ? AppTheme.neutral900
                                : AppTheme.neutral500,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
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
        ];

        if (!hasData) {
          slivers.add(
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
                child: EmptyState(
                  title: 'No data yet',
                  message:
                      'Add transactions to see your statistics and insights.',
                  icon: Icons.insights_outlined,
                ),
              ),
            ),
          );
          return CustomScrollView(slivers: slivers);
        }

        slivers.addAll([
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _animController,
                curve: const Interval(0.0, 0.4),
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
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(
                        0.2,
                        0.6,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.2, 0.5),
                ),
                child: _ChartCard(
                  title: 'Expense Overview',
                  child: SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: max(
                          1,
                          barSeries.map((e) => e.value).fold(0.0, max) * 1.3,
                        ),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => AppTheme.primary900,
                            getTooltipItem: (group, gIdx, rod, rIdx) {
                              return BarTooltipItem(
                                '${rod.toY.toStringAsFixed(0)} TND',
                                AppTheme.smallMedium.copyWith(
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < barSeries.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      barSeries[value.toInt()].key,
                                      style: AppTheme.smallMedium,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barGroups: barSeries
                            .asMap()
                            .entries
                            .map(
                              (e) => BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value.value,
                                    color: AppTheme.danger500,
                                    width: 20,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: _ChartCard(
              title: 'Spending by Category',
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: pieData.isNotEmpty
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: pieData,
                                  centerSpaceRadius: 60,
                                  sectionsSpace: 2,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    totalExpense.toStringAsFixed(0),
                                    style: AppTheme.h2Bold,
                                  ),
                                  Text('TND', style: AppTheme.smallMedium),
                                ],
                              ),
                            ],
                          )
                        : const Center(child: Text('No expense data yet')),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: categoryEntries.map((entry) {
                      final cat = DefaultCategories.all
                          .where((c) => c.id == entry.key)
                          .firstOrNull;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: cat?.color ?? AppTheme.neutral400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat?.name ?? entry.key,
                            style: AppTheme.smallMedium,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: _ChartCard(
              title: 'Balance Trend',
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < monthlySeries.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  monthlySeries[value.toInt()].key,
                                  style: AppTheme.smallMedium,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: monthlySeries
                            .asMap()
                            .entries
                            .map(
                              (entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value.value,
                              ),
                            )
                            .toList(),
                        color: AppTheme.primary900,
                        barWidth: 3,
                        isCurved: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primary900.withOpacity(0.1),
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
              title: 'Category Breakdown',
              child: categoryEntries.isEmpty
                  ? Text(
                      'No expense data available.',
                      style: AppTheme.smallMedium.copyWith(
                        color: AppTheme.neutral500,
                      ),
                    )
                  : Column(
                      children: (() {
                        final sortedEntries = [...categoryEntries]
                          ..sort((a, b) => b.value.compareTo(a.value));
                        return sortedEntries.map((entry) {
                          final cat = DefaultCategories.all
                              .where((c) => c.id == entry.key)
                              .firstOrNull;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: cat?.color ?? AppTheme.neutral400,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    cat?.name ?? entry.key,
                                    style: AppTheme.smallMedium,
                                  ),
                                ),
                                Text(
                                  '${entry.value.toStringAsFixed(0)} TND',
                                  style: AppTheme.bodySemiBold.copyWith(
                                    fontSize: 14,
                                    color: AppTheme.neutral900,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      })(),
                    ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]);

        return CustomScrollView(slivers: slivers);
      },
    );
  }

  List<MapEntry<String, double>> _getBarSeries(List<Transaction> transactions) {
    final now = DateTime.now();
    if (_timeRange == 'year') {
      return List.generate(12, (index) {
        final month = DateTime(now.year, now.month - (11 - index), 1);
        final total = transactions
            .where(
              (t) =>
                  t.isExpense &&
                  t.date.year == month.year &&
                  t.date.month == month.month,
            )
            .fold(0.0, (sum, t) => sum + t.amount);
        return MapEntry(DateFormat('MMM').format(month), total);
      });
    }

    final days = _timeRange == 'day'
        ? 1
        : _timeRange == 'week'
        ? 7
        : 30;
    return List.generate(days, (index) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: days - 1 - index));
      final total = transactions
          .where(
            (t) =>
                t.isExpense &&
                t.date.year == day.year &&
                t.date.month == day.month &&
                t.date.day == day.day,
          )
          .fold(0.0, (sum, t) => sum + t.amount);
      final label = _timeRange == 'month'
          ? DateFormat('d').format(day)
          : _timeRange == 'day'
          ? 'Today'
          : DateFormat('EEE').format(day);
      return MapEntry(label, total);
    });
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    final start = _timeRange == 'day'
        ? DateTime(now.year, now.month, now.day)
        : _timeRange == 'week'
        ? DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 6))
        : _timeRange == 'month'
        ? DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 29))
        : DateTime(now.year - 1, now.month, now.day);

    return transactions
        .where((t) => !t.date.isBefore(start) && !t.date.isAfter(now))
        .toList();
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

  double _sum(Iterable<Transaction> transactions) {
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  List<MapEntry<String, double>> _getMonthlyBalanceSeries(
    List<Transaction> transactions,
    int months,
  ) {
    final now = DateTime.now();
    return List.generate(months, (index) {
      final month = DateTime(now.year, now.month - (months - 1 - index), 1);
      final income = transactions
          .where(
            (t) =>
                t.isIncome &&
                t.date.year == month.year &&
                t.date.month == month.month,
          )
          .fold(0.0, (sum, t) => sum + t.amount);
      final expense = transactions
          .where(
            (t) =>
                t.isExpense &&
                t.date.year == month.year &&
                t.date.month == month.month,
          )
          .fold(0.0, (sum, t) => sum + t.amount);
      final label = DateFormat('MMM').format(month);
      return MapEntry(label, income - expense);
    });
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
