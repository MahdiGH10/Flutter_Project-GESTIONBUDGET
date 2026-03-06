import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/budget_goal_model.dart';
import '../models/transaction_model.dart';
import '../services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _service = BudgetService();
  bool _isLoading = false;
  String? _userId;

  bool get isLoading => _isLoading;

  bool get hasUserContext => _userId != null;

  /// Ensure provider is bound to the current Firebase user.
  Future<bool> ensureUserContext() async {
    if (_userId != null) return true;
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    await loadForUser(uid);
    return true;
  }

  List<BudgetGoal> get goals => _service.goals;
  List<BudgetGoal> get exceededGoals =>
      _service.goals.where((g) => g.isExceeded).toList();
  int get onTrackCount => _service.onTrackCount;
  int get warningCount => _service.warningCount;
  int get exceededCount => _service.exceededCount;

  /// Load goals for [userId] from SQLite.
  Future<void> loadForUser(String userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();
    await _service.loadForUser(userId);
    _isLoading = false;
    notifyListeners();
  }

  /// Clear data on logout.
  void clear() {
    _userId = null;
    _service.clear();
    notifyListeners();
  }

  Future<void> addGoal({
    required String name,
    required String categoryId,
    required double targetAmount,
    required DateTime month,
  }) async {
    final ready = await ensureUserContext();
    if (!ready) {
      throw StateError('Aucun utilisateur connecté. Veuillez vous reconnecter.');
    }
    await _service.addGoal(
      userId: _userId!,
      name: name,
      categoryId: categoryId,
      targetAmount: targetAmount,
      month: month,
    );
    notifyListeners();
  }

  Future<void> updateGoalProgress(String goalId, double currentAmount) async {
    final ready = await ensureUserContext();
    if (!ready) return;
    await _service.updateGoalProgress(goalId, currentAmount, userId: _userId!);
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    final ready = await ensureUserContext();
    if (!ready) return;
    await _service.deleteGoal(id, userId: _userId!);
    notifyListeners();
  }

  Future<void> updateGoal(BudgetGoal goal) async {
    final ready = await ensureUserContext();
    if (!ready) return;
    await _service.updateGoal(goal, userId: _userId!);
    notifyListeners();
  }

  Future<void> recalculateProgress(List<Transaction> transactions) async {
    final ready = await ensureUserContext();
    if (!ready) return;
    final changed = await _service.recalculateProgressFromTransactions(
      transactions,
      userId: _userId!,
    );
    if (changed) {
      notifyListeners();
    }
  }
}
