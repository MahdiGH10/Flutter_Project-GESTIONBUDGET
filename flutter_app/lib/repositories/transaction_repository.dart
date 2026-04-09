import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/transaction_model.dart';
import '../models/category_model.dart';

/// Repository that persists [Transaction] objects in Cloud Firestore,
/// scoped to a specific user via [userId].
class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  // ── CREATE ──────────────────────────────────────────────────
  Future<void> insert(Transaction transaction, {required String userId}) async {
    final row = transaction.toMap();
    row['user_id'] = userId;
    await _collection(userId).doc(transaction.id).set(row);
  }

  // ── READ ────────────────────────────────────────────────────
  Future<List<Transaction>> getAll({required String userId}) async {
    final snapshot = await _collection(userId).orderBy('date', descending: true).get();
    return snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data()))
        .toList();
  }

  Stream<List<Transaction>> watchAll({required String userId}) {
    return _collection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Transaction.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<List<Transaction>> getByType(
    CategoryType type, {
    required String userId,
  }) async {
    final all = await getAll(userId: userId);
    return all.where((t) => t.type == type).toList();
  }

  Future<List<Transaction>> getByCategory(
    String categoryId, {
    required String userId,
  }) async {
    final all = await getAll(userId: userId);
    return all.where((t) => t.categoryId == categoryId).toList();
  }

  Future<List<Transaction>> getByDateRange(
    DateTime start,
    DateTime end, {
    required String userId,
  }) async {
    final all = await getAll(userId: userId);
    return all
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }

  // ── UPDATE ──────────────────────────────────────────────────
  Future<void> update(Transaction transaction, {required String userId}) async {
    final row = transaction.toMap();
    row['user_id'] = userId;
    await _collection(userId).doc(transaction.id).set(row, SetOptions(merge: true));
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

  // ── AGGREGATES ──────────────────────────────────────────────
  Future<double> totalIncome({required String userId}) async {
    final all = await getAll(userId: userId);
    return all
        .where((t) => t.isIncome)
      .fold<double>(0.0, (double sum, t) => sum + t.amount);
  }

  Future<double> totalExpense({required String userId}) async {
    final all = await getAll(userId: userId);
    return all
        .where((t) => t.isExpense)
      .fold<double>(0.0, (double sum, t) => sum + t.amount);
  }

  Future<double> balance({required String userId}) async {
    final income = await totalIncome(userId: userId);
    final expense = await totalExpense(userId: userId);
    return income - expense;
  }

  Future<Map<String, double>> getExpenseByCategory({
    required String userId,
  }) async {
    final all = await getAll(userId: userId);
    final map = <String, double>{};
    for (final t in all.where((t) => t.isExpense)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  Future<double> getSpentForCategory(
    String categoryId, {
    required String userId,
  }) async {
    final all = await getAll(userId: userId);
    return all
        .where((t) => t.isExpense && t.categoryId == categoryId)
        .fold<double>(0.0, (double sum, t) => sum + t.amount);
  }

  Future<List<MapEntry<String, double>>> getDailyExpenses(
    int days, {
    required String userId,
  }) async {
    final all = await getAll(userId: userId);
    final now = DateTime.now();
    final result = <MapEntry<String, double>>[];
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final total = all
          .where((t) =>
              t.isExpense &&
              t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day)
          .fold<double>(0.0, (double sum, t) => sum + t.amount);
      result.add(MapEntry(dayNames[day.weekday - 1], total));
    }
    return result;
  }
}
