import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();
  bool _isLoading = true;

  TransactionProvider() {
    _bootstrap();
  }

  bool get isLoading => _isLoading;

  List<Transaction> get transactions => _service.transactions;
  double get totalIncome => _service.totalIncome;
  double get totalExpense => _service.totalExpense;
  double get balance => _service.balance;

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 250));
    _isLoading = false;
    notifyListeners();
  }

  void addTransaction({
    required String title,
    required double amount,
    required DateTime date,
    required String categoryId,
    required CategoryType type,
    String? description,
  }) {
    _service.addTransaction(
      title: title,
      amount: amount,
      date: date,
      categoryId: categoryId,
      type: type,
      description: description,
    );
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _service.deleteTransaction(id);
    notifyListeners();
  }

  List<Transaction> getByCategory(String categoryId) =>
      _service.getByCategory(categoryId);

  List<Transaction> getByType(CategoryType type) => _service.getByType(type);

  Map<String, double> getExpenseByCategory() => _service.getExpenseByCategory();

  double getSpentForCategory(String categoryId) =>
      _service.getSpentForCategory(categoryId);

  List<MapEntry<String, double>> getDailyExpenses(int days) =>
      _service.getDailyExpenses(days);
}
