import '../database/database_helper.dart';
import '../models/category_model.dart';

/// Repository that persists custom [Category] objects in SQLite,
/// scoped to a specific user via [userId].
class CategoryRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ── CREATE ──────────────────────────────────────────────────
  Future<void> insert(Category category, {required String userId}) async {
    final row = category.toMap();
    row['user_id'] = userId;
    row['is_custom'] = 1;
    await _db.insert(DatabaseHelper.tableCategories, row);
  }

  // ── READ ────────────────────────────────────────────────────
  Future<List<Category>> getCustomCategories({required String userId}) async {
    final rows = await _db.queryAll(
      DatabaseHelper.tableCategories,
      userId: userId,
      orderBy: 'created_at DESC',
    );
    return rows.map((row) => Category.fromMap(row)).toList();
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
    await _db.update(DatabaseHelper.tableCategories, row, id: category.id);
  }

  // ── DELETE ──────────────────────────────────────────────────
  Future<void> delete(String id) async {
    await _db.delete(DatabaseHelper.tableCategories, id: id);
  }

  Future<void> deleteAllForUser({required String userId}) async {
    await _db.deleteAllForUser(
      DatabaseHelper.tableCategories,
      userId: userId,
    );
  }
}
