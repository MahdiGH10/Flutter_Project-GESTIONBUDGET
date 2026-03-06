import '../models/budget_goal_model.dart';
import '../models/transaction_model.dart';
import '../repositories/budget_repository.dart';
import 'package:uuid/uuid.dart';

/// Service layer for budget goals. Delegates persistence to
/// [BudgetRepository] and keeps an in-memory cache for fast reads.
class BudgetService {
  final BudgetRepository _repo = BudgetRepository();
  final _uuid = const Uuid();

  List<BudgetGoal> _goals = [];

  List<BudgetGoal> get goals => List.unmodifiable(_goals);

  /// Load all goals for the given user from SQLite.
  Future<void> loadForUser(String userId) async {
    _goals = await _repo.getAll(userId: userId);
  }

  /// Clear the in-memory cache (e.g. on logout).
  void clear() {
    _goals = [];
  }

  Future<BudgetGoal> addGoal({
    required String userId,
    required String name,
    required String categoryId,
    required double targetAmount,
    required DateTime month,
  }) async {
    final goal = BudgetGoal(
      id: _uuid.v4(),
      name: name,
      categoryId: categoryId,
      targetAmount: targetAmount,
      month: month,
    );
    await _repo.insert(goal, userId: userId);
    _goals.add(goal);
    return goal;
  }

  Future<void> updateGoalProgress(
    String goalId,
    double currentAmount, {
    required String userId,
  }) async {
    await _repo.updateProgress(goalId, currentAmount, userId: userId);
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(currentAmount: currentAmount);
    }
  }

  Future<void> deleteGoal(String id, {required String userId}) async {
    await _repo.delete(id);
    _goals.removeWhere((g) => g.id == id);
  }

  Future<void> updateGoal(BudgetGoal goal, {required String userId}) async {
    await _repo.update(goal, userId: userId);
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
    }
  }

  /// Recalculate each goal's progress from real monthly expense transactions.
  /// Returns true if at least one goal changed.
  Future<bool> recalculateProgressFromTransactions(
    List<Transaction> transactions, {
    required String userId,
  }) async {
    bool changed = false;

    for (int i = 0; i < _goals.length; i++) {
      final goal = _goals[i];
      final spent = transactions
          .where((t) =>
              t.isExpense &&
              t.categoryId == goal.categoryId &&
              t.date.year == goal.month.year &&
              t.date.month == goal.month.month)
          .fold<double>(0.0, (double sum, t) => sum + t.amount);

      if ((goal.currentAmount - spent).abs() > 0.001) {
        await _repo.updateProgress(goal.id, spent, userId: userId);
        _goals[i] = goal.copyWith(currentAmount: spent);
        changed = true;
      }
    }

    return changed;
  }

  int get onTrackCount => _goals.where((g) => g.isOnTrack).length;
  int get warningCount => _goals.where((g) => g.isWarning).length;
  int get exceededCount => _goals.where((g) => g.isExceeded).length;
}
