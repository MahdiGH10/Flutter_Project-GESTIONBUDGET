import 'package:flutter/material.dart';
import '../models/budget_goal_model.dart';
import '../services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _service = BudgetService();
  bool _isLoading = false;
  String? _userId;

  bool get isLoading => _isLoading;

  List<BudgetGoal> get goals => _service.goals;
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
    if (_userId == null) return;
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
    if (_userId == null) return;
    await _service.updateGoalProgress(goalId, currentAmount, userId: _userId!);
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    if (_userId == null) return;
    await _service.deleteGoal(id, userId: _userId!);
    notifyListeners();
  }
}
