import '../database/database_helper.dart';
import '../models/budget_goal_model.dart';

/// Repository that persists [BudgetGoal] objects in SQLite,
/// scoped to a specific user via [userId].
class BudgetRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ── CREATE ──────────────────────────────────────────────────
  Future<void> insert(BudgetGoal goal, {required String userId}) async {
    final row = goal.toMap();
    row['user_id'] = userId;
    await _db.insert(DatabaseHelper.tableBudgetGoals, row);
  }

  // ── READ ────────────────────────────────────────────────────
  Future<List<BudgetGoal>> getAll({required String userId}) async {
    final rows = await _db.queryAll(
      DatabaseHelper.tableBudgetGoals,
      userId: userId,
      orderBy: 'month DESC, created_at DESC',
    );
    return rows.map((row) => BudgetGoal.fromMap(row)).toList();
  }

  Future<List<BudgetGoal>> getActiveGoals({required String userId}) async {
    final all = await getAll(userId: userId);
    return all.where((g) => g.isActive).toList();
  }

  Future<List<BudgetGoal>> getGoalsForMonth(
    DateTime month, {
    required String userId,
  }) async {
    final all = await getAll(userId: userId);
    return all
        .where((g) => g.month.year == month.year && g.month.month == month.month)
        .toList();
  }

  // ── UPDATE ──────────────────────────────────────────────────
  Future<void> update(BudgetGoal goal, {required String userId}) async {
    final row = goal.toMap();
    row['user_id'] = userId;
    await _db.update(DatabaseHelper.tableBudgetGoals, row, id: goal.id);
  }

  Future<void> updateProgress(String goalId, double currentAmount, {required String userId}) async {
    final db = await _db.database;
    await db.update(
      DatabaseHelper.tableBudgetGoals,
      {'currentAmount': currentAmount},
      where: 'id = ? AND user_id = ?',
      whereArgs: [goalId, userId],
    );
  }

  // ── DELETE ──────────────────────────────────────────────────
  Future<void> delete(String id) async {
    await _db.delete(DatabaseHelper.tableBudgetGoals, id: id);
  }

  Future<void> deleteAllForUser({required String userId}) async {
    await _db.deleteAllForUser(
      DatabaseHelper.tableBudgetGoals,
      userId: userId,
    );
  }
}
