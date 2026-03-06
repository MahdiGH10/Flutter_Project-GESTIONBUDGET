import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton helper that manages the SQLite database.
/// Every data table carries a `user_id` column so each Firebase user
/// only sees their own data.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  static const _dbName = 'gestion_budgetaire.db';
  static const _dbVersion = 1;

  // ── Table names ──────────────────────────────────────────────
  static const tableTransactions = 'transactions';
  static const tableCategories = 'categories';
  static const tableBudgetGoals = 'budget_goals';

  // ── Get / create database ────────────────────────────────────
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ── Schema creation ──────────────────────────────────────────
  Future<void> _onCreate(Database db, int version) async {
    // Transactions table
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // Categories table (custom user-created categories)
    await db.execute('''
      CREATE TABLE $tableCategories (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        colorValue INTEGER NOT NULL,
        type TEXT NOT NULL,
        budget REAL NOT NULL DEFAULT 0,
        is_custom INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // Budget goals table
    await db.execute('''
      CREATE TABLE $tableBudgetGoals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL DEFAULT 0,
        month TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // ── Indexes for fast per-user queries ──
    await db.execute(
      'CREATE INDEX idx_transactions_user ON $tableTransactions(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_categories_user ON $tableCategories(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_budget_goals_user ON $tableBudgetGoals(user_id)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here
  }

  // ── Generic CRUD helpers ─────────────────────────────────────
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(
    String table, {
    required String userId,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: orderBy,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> row, {
    required String id,
  }) async {
    final db = await database;
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, {required String id}) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all rows for a user in a given table (used on logout / data reset).
  Future<int> deleteAllForUser(String table, {required String userId}) async {
    final db = await database;
    return await db.delete(table, where: 'user_id = ?', whereArgs: [userId]);
  }

  /// Close the database (useful for testing).
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
