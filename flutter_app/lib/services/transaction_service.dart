import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';

/// Service layer for transactions. Delegates persistence to
/// [TransactionRepository] and keeps an in-memory cache for fast reads.
class TransactionService {
  final TransactionRepository _repo = TransactionRepository();
  final _uuid = const Uuid();

  List<Transaction> _transactions = [];

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  /// Load all transactions for the given user from SQLite.
  Future<void> loadForUser(String userId) async {
    _transactions = await _repo.getAll(userId: userId);
  }

  /// Clear the in-memory cache (e.g. on logout).
  void clear() {
    _transactions = [];
  }

  Future<Transaction> addTransaction({
    required String userId,
    required String title,
    required double amount,
    required DateTime date,
    required String categoryId,
    required CategoryType type,
    String? description,
  }) async {
    final transaction = Transaction(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      date: date,
      categoryId: categoryId,
      type: type,
      description: description,
    );
    await _repo.insert(transaction, userId: userId);
    _transactions.insert(0, transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    return transaction;
  }

  Future<void> deleteTransaction(String id, {required String userId}) async {
    await _repo.delete(id);
    _transactions.removeWhere((t) => t.id == id);
  }

  // ── Computed values (from cache) ────────────────────────────
  double get totalIncome =>
      _transactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);

  double get totalExpense =>
      _transactions.where((t) => t.isExpense).fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  List<Transaction> getByCategory(String categoryId) =>
      _transactions.where((t) => t.categoryId == categoryId).toList();

  List<Transaction> getByType(CategoryType type) =>
      _transactions.where((t) => t.type == type).toList();

  List<Transaction> getByDateRange(DateTime start, DateTime end) =>
      _transactions
          .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
          .toList();

  Map<String, double> getExpenseByCategory() {
    final map = <String, double>{};
    for (final t in _transactions.where((t) => t.isExpense)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  double getSpentForCategory(String categoryId) {
    return _transactions
        .where((t) => t.isExpense && t.categoryId == categoryId)
        .fold(0, (sum, t) => sum + t.amount);
  }

  List<MapEntry<String, double>> getDailyExpenses(int days) {
    final now = DateTime.now();
    final result = <MapEntry<String, double>>[];
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final total = _transactions
          .where(
            (t) =>
                t.isExpense &&
                t.date.year == day.year &&
                t.date.month == day.month &&
                t.date.day == day.day,
          )
          .fold(0.0, (sum, t) => sum + t.amount);
      result.add(MapEntry(dayNames[day.weekday - 1], total));
    }
    return result;
  }
}
