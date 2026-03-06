import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IncomeExpensePoint {
  final String label;
  final double income;
  final double expense;

  const IncomeExpensePoint({
    required this.label,
    required this.income,
    required this.expense,
  });
}

class BarChartWidget extends StatelessWidget {
  final List<IncomeExpensePoint> data;

  const BarChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No data yet')),
      );
    }

    final maxValue = data
        .map((e) => max(e.income, e.expense))
        .fold<double>(0.0, max);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: max(1, maxValue * 1.25),
          groupsSpace: 18,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppTheme.primary900,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final point = data[group.x.toInt()];
                final isIncome = rodIndex == 0;
                return BarTooltipItem(
                  '${point.label}\n${isIncome ? 'Income' : 'Expense'}: ${rod.toY.toStringAsFixed(0)} TND',
                  AppTheme.smallMedium.copyWith(color: Colors.white),
                );
              },
            ),
          ),
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
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(data[idx].label, style: AppTheme.smallMedium),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: data
              .asMap()
              .entries
              .map(
                (entry) => BarChartGroupData(
                  x: entry.key,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.income,
                      color: AppTheme.success500,
                      width: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: entry.value.expense,
                      color: AppTheme.danger500,
                      width: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
