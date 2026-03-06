import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();
  bool _isLoading = false;
  String? _userId;

  bool get isLoading => _isLoading;

  List<Transaction> get transactions => _service.transactions;
  double get totalIncome => _service.totalIncome;
  double get totalExpense => _service.totalExpense;
  double get balance => _service.balance;

  bool get hasUserContext => _userId != null;

  /// Ensure provider is bound to the current Firebase user.
  Future<bool> ensureUserContext() async {
    if (_userId != null) return true;
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    await loadForUser(uid);
    return true;
  }

  /// Load transactions for [userId] from SQLite.
  Future<void> loadForUser(String userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();
    await _service.loadForUser(userId);
    _isLoading = false;
    notifyListeners();
  }

  /// Reload transactions from SQLite for the current user.
  Future<void> refresh() async {
    final ready = await ensureUserContext();
    if (!ready) return;
    _isLoading = true;
    notifyListeners();
    await _service.loadForUser(_userId!);
    _isLoading = false;
    notifyListeners();
  }

  /// Clear data on logout.
  void clear() {
    _userId = null;
    _service.clear();
    notifyListeners();
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required DateTime date,
    required String categoryId,
    required CategoryType type,
    String? description,
  }) async {
    final ready = await ensureUserContext();
    if (!ready) {
      throw StateError('Aucun utilisateur connecté. Veuillez vous reconnecter.');
    }
    await _service.addTransaction(
      userId: _userId!,
      title: title,
      amount: amount,
      date: date,
      categoryId: categoryId,
      type: type,
      description: description,
    );
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    final ready = await ensureUserContext();
    if (!ready) return;
    await _service.deleteTransaction(id, userId: _userId!);
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
