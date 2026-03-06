import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';

class TransactionTableWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final Map<String, Category> categoryLookup;

  const TransactionTableWidget({
    super.key,
    required this.transactions,
    required this.categoryLookup,
  });

  @override
  Widget build(BuildContext context) {
    final rows = transactions.take(20).toList();
    final income = rows
        .where((t) => t.isIncome)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
    final expense = rows
        .where((t) => t.isExpense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    if (rows.isEmpty) {
      return const Text('No transaction data available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.neutral100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _MiniTotal(
                  label: 'Rows',
                  value: rows.length.toString(),
                  color: AppTheme.neutral900,
                ),
              ),
              Expanded(
                child: _MiniTotal(
                  label: 'Income',
                  value: '${income.toStringAsFixed(0)} TND',
                  color: AppTheme.success500,
                ),
              ),
              Expanded(
                child: _MiniTotal(
                  label: 'Expense',
                  value: '${expense.toStringAsFixed(0)} TND',
                  color: AppTheme.danger500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Showing latest ${rows.length} transactions',
          style: AppTheme.smallMedium.copyWith(color: AppTheme.neutral500),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingTextStyle:
                AppTheme.captionMedium.copyWith(color: AppTheme.neutral900),
            dataTextStyle:
                AppTheme.smallMedium.copyWith(color: AppTheme.neutral900),
            columns: const [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Amount')),
            ],
            rows: rows
                .map(
                  (t) => DataRow(
                    cells: [
                      DataCell(Text(DateFormat('dd/MM/yyyy').format(t.date))),
                      DataCell(
                        Text(
                          t.isIncome ? 'Income' : 'Expense',
                          style: TextStyle(
                            color: t.isIncome
                                ? AppTheme.success500
                                : AppTheme.danger500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(Text(categoryLookup[t.categoryId]?.name ?? t.categoryId)),
                      DataCell(
                        Text(
                          t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataCell(Text('${t.amount.toStringAsFixed(2)} TND')),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _MiniTotal extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniTotal({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.smallMedium.copyWith(color: AppTheme.neutral500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.captionMedium.copyWith(color: color),
        ),
      ],
    );
  }
}
