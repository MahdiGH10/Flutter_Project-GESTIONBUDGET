import '../models/budget_goal_model.dart';
import 'package:uuid/uuid.dart';

class BudgetService {
  final List<BudgetGoal> _goals = [];
  final _uuid = const Uuid();

  BudgetService() {
    _loadSampleGoals();
  }

  void _loadSampleGoals() {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    _goals.addAll([
      BudgetGoal(
        id: _uuid.v4(),
        name: 'Monthly Savings',
        categoryId: 'savings',
        targetAmount: 1000,
        currentAmount: 650,
        month: month,
      ),
      BudgetGoal(
        id: _uuid.v4(),
        name: 'Food Budget',
        categoryId: 'food',
        targetAmount: 400,
        currentAmount: 285,
        month: month,
      ),
      BudgetGoal(
        id: _uuid.v4(),
        name: 'Transport Limit',
        categoryId: 'transport',
        targetAmount: 200,
        currentAmount: 124,
        month: month,
      ),
      BudgetGoal(
        id: _uuid.v4(),
        name: 'Entertainment',
        categoryId: 'entertainment',
        targetAmount: 150,
        currentAmount: 89,
        month: month,
      ),
      BudgetGoal(
        id: _uuid.v4(),
        name: 'Shopping Cap',
        categoryId: 'shopping',
        targetAmount: 300,
        currentAmount: 450,
        month: month,
      ),
    ]);
  }

  List<BudgetGoal> get goals => List.unmodifiable(_goals);

  BudgetGoal addGoal({
    required String name,
    required String categoryId,
    required double targetAmount,
    required DateTime month,
  }) {
    final goal = BudgetGoal(
      id: _uuid.v4(),
      name: name,
      categoryId: categoryId,
      targetAmount: targetAmount,
      month: month,
    );
    _goals.add(goal);
    return goal;
  }

  void updateGoalProgress(String goalId, double currentAmount) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(currentAmount: currentAmount);
    }
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
  }

  int get onTrackCount => _goals.where((g) => g.isOnTrack).length;
  int get warningCount => _goals.where((g) => g.isWarning).length;
  int get exceededCount => _goals.where((g) => g.isExceeded).length;
}
