import '../models/transaction_model.dart';

/// Pure financial calculations extracted for deterministic unit testing.
class FinanceCalculator {
  static double totalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double totalExpense(List<Transaction> transactions) {
    return transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double balance(List<Transaction> transactions) {
    return totalIncome(transactions) - totalExpense(transactions);
  }

  static Map<String, double> expenseTotalsByCategory(
    List<Transaction> transactions,
  ) {
    final map = <String, double>{};
    for (final t in transactions.where((t) => t.isExpense)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  static double spentForCategory(
    List<Transaction> transactions,
    String categoryId,
  ) {
    return transactions
        .where((t) => t.isExpense && t.categoryId == categoryId)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double spentForCategoryInMonth(
    List<Transaction> transactions, {
    required String categoryId,
    required DateTime month,
  }) {
    return transactions
        .where(
          (t) =>
              t.isExpense &&
              t.categoryId == categoryId &&
              t.date.year == month.year &&
              t.date.month == month.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
