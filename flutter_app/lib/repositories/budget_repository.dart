import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_goal_model.dart';

/// Repository that persists [BudgetGoal] objects in Cloud Firestore,
/// scoped to a specific user via [userId].
class BudgetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budget_goals');
  }

  // ── CREATE ──────────────────────────────────────────────────
  Future<void> insert(BudgetGoal goal, {required String userId}) async {
    final row = goal.toMap();
    row['user_id'] = userId;
    row['created_at'] = DateTime.now().toIso8601String();
    await _collection(userId).doc(goal.id).set(row);
  }

  // ── READ ────────────────────────────────────────────────────
  Future<List<BudgetGoal>> getAll({required String userId}) async {
    final snapshot = await _collection(userId).get();
    final goals = snapshot.docs.map((doc) => BudgetGoal.fromMap(doc.data())).toList();
    goals.sort((a, b) => b.month.compareTo(a.month));
    return goals;
  }

  Stream<List<BudgetGoal>> watchAll({required String userId}) {
    return _collection(userId).snapshots().map((snapshot) {
      final goals = snapshot.docs
          .map((doc) => BudgetGoal.fromMap(doc.data()))
          .toList();
      goals.sort((a, b) => b.month.compareTo(a.month));
      return goals;
    });
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
    await _collection(userId).doc(goal.id).set(row, SetOptions(merge: true));
  }

  Future<void> updateProgress(String goalId, double currentAmount, {required String userId}) async {
    await _collection(userId).doc(goalId).set(
      {'currentAmount': currentAmount},
      SetOptions(merge: true),
    );
  }

  // ── DELETE ──────────────────────────────────────────────────
  Future<void> delete(String id, {required String userId}) async {
    await _collection(userId).doc(id).delete();
  }

  Future<void> deleteAllForUser({required String userId}) async {
    final snapshot = await _collection(userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
