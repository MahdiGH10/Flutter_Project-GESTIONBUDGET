import '../models/transaction_model.dart';
import '../models/category_model.dart';
import 'package:uuid/uuid.dart';

class TransactionService {
  final List<Transaction> _transactions = [];
  final _uuid = const Uuid();

  TransactionService() {
    _loadSampleData();
  }

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  void _loadSampleData() {
    final now = DateTime.now();
    _transactions.addAll([
      Transaction(
        id: _uuid.v4(),
        title: 'Monthly Salary',
        amount: 2500.00,
        date: now.subtract(const Duration(days: 1)),
        categoryId: 'salary',
        type: CategoryType.income,
        description: 'January salary',
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Freelance Project',
        amount: 450.00,
        date: now.subtract(const Duration(days: 5)),
        categoryId: 'freelance',
        type: CategoryType.income,
        description: 'Website redesign',
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Grocery Shopping',
        amount: 125.50,
        date: now,
        categoryId: 'food',
        type: CategoryType.expense,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Uber Ride',
        amount: 24.00,
        date: now.subtract(const Duration(days: 1)),
        categoryId: 'transport',
        type: CategoryType.expense,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Netflix Subscription',
        amount: 15.99,
        date: now.subtract(const Duration(days: 2)),
        categoryId: 'entertainment',
        type: CategoryType.expense,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Restaurant',
        amount: 85.00,
        date: now.subtract(const Duration(days: 3)),
        categoryId: 'food',
        type: CategoryType.expense,
        description: 'Dinner with friends',
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Gas Station',
        amount: 60.00,
        date: now.subtract(const Duration(days: 4)),
        categoryId: 'transport',
        type: CategoryType.expense,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Electric Bill',
        amount: 120.00,
        date: now.subtract(const Duration(days: 6)),
        categoryId: 'utilities',
        type: CategoryType.expense,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'New Shoes',
        amount: 189.00,
        date: now.subtract(const Duration(days: 7)),
        categoryId: 'shopping',
        type: CategoryType.expense,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Gym Membership',
        amount: 45.00,
        date: now.subtract(const Duration(days: 8)),
        categoryId: 'health',
        type: CategoryType.expense,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Rent Payment',
        amount: 800.00,
        date: now.subtract(const Duration(days: 1)),
        categoryId: 'housing',
        type: CategoryType.expense,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Online Course',
        amount: 49.99,
        date: now.subtract(const Duration(days: 10)),
        categoryId: 'education',
        type: CategoryType.expense,
      ),
    ]);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  Transaction addTransaction({
    required String title,
    required double amount,
    required DateTime date,
    required String categoryId,
    required CategoryType type,
    String? description,
  }) {
    final transaction = Transaction(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      date: date,
      categoryId: categoryId,
      type: type,
      description: description,
    );
    _transactions.insert(0, transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    return transaction;
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
  }

  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.isExpense)
      .fold(0, (sum, t) => sum + t.amount);

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
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      result.add(MapEntry(dayNames[day.weekday - 1], total));
    }
    return result;
  }
}
