import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

/// Repository that persists custom [Category] objects in Cloud Firestore,
/// scoped to a specific user via [userId].
class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('categories');
  }

  // ── CREATE ──────────────────────────────────────────────────
  Future<void> insert(Category category, {required String userId}) async {
    final row = category.toMap();
    row['user_id'] = userId;
    row['is_custom'] = 1;
    row['created_at'] = DateTime.now().toIso8601String();
    await _collection(userId).doc(category.id).set(row);
  }

  // ── READ ────────────────────────────────────────────────────
  Future<List<Category>> getCustomCategories({required String userId}) async {
    final snapshot = await _collection(userId).get();
    final docs = snapshot.docs.where((d) => d.data()['is_custom'] == 1);
    return docs.map((doc) => Category.fromMap(doc.data())).toList();
  }

  /// Returns all categories for a user: defaults + custom.
  Future<List<Category>> getAllByType(
    CategoryType type, {
    required String userId,
  }) async {
    final defaults = DefaultCategories.all.where((c) => c.type == type);
    final custom = await getCustomCategories(userId: userId);
    final customFiltered = custom.where((c) => c.type == type);
    return [...defaults, ...customFiltered];
  }

  // ── UPDATE ──────────────────────────────────────────────────
  Future<void> update(Category category, {required String userId}) async {
    final row = category.toMap();
    row['user_id'] = userId;
    row['is_custom'] = 1;
    await _collection(userId).doc(category.id).set(row, SetOptions(merge: true));
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
