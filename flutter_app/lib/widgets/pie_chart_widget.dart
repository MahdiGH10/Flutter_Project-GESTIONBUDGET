import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> expenseByCategory;
  final Map<String, Category> categoryLookup;

  const PieChartWidget({
    super.key,
    required this.expenseByCategory,
    required this.categoryLookup,
  });

  @override
  Widget build(BuildContext context) {
    final entries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<double>(0.0, (sum, e) => sum + e.value);

    if (entries.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No expense data yet')),
      );
    }

    final sections = entries
        .map(
          (entry) => PieChartSectionData(
            value: entry.value,
            color: categoryLookup[entry.key]?.color ?? AppTheme.neutral400,
            title: '',
            radius: 40,
          ),
        )
        .toList();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 62,
                  sectionsSpace: 2,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(total.toStringAsFixed(0), style: AppTheme.h2Bold),
                  Text('TND', style: AppTheme.smallMedium),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: entries.map((entry) {
            final category = categoryLookup[entry.key];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: category?.color ?? AppTheme.neutral400,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(category?.name ?? entry.key, style: AppTheme.smallMedium),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
