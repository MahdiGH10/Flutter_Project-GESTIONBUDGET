import 'package:flutter/material.dart';
import '../models/budget_goal_model.dart';
import '../services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _service = BudgetService();

  List<BudgetGoal> get goals => _service.goals;
  int get onTrackCount => _service.onTrackCount;
  int get warningCount => _service.warningCount;
  int get exceededCount => _service.exceededCount;

  void addGoal({
    required String name,
    required String categoryId,
    required double targetAmount,
    required DateTime month,
  }) {
    _service.addGoal(
      name: name,
      categoryId: categoryId,
      targetAmount: targetAmount,
      month: month,
    );
    notifyListeners();
  }

  void updateGoalProgress(String goalId, double currentAmount) {
    _service.updateGoalProgress(goalId, currentAmount);
    notifyListeners();
  }

  void deleteGoal(String id) {
    _service.deleteGoal(id);
    notifyListeners();
  }
}
