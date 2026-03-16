import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  static const String transactionTable = 'transactions';
  static const String categoryTable = 'categories';
  // transactions
  static const String transId = 'id';
  static const String amount = 'amount';
  static const String transNote = 'note';
  static const String transType = 'type';
  static const String transCatId = 'category_id';
  static const String transTimestamp = 'timestamp';
  static const String transIsSynced = 'is_synced';
  static const String transIsDeleted = 'is_deleted';
  // categories
  static const String categoryId = 'id';
  static const String categoryName = 'name';
  static const String categoryIsSynced = 'is_synced';
  static const String categoryIsDeleted = 'is_deleted';

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense-management.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $categoryTable (
        $categoryId        TEXT PRIMARY KEY,
        $categoryName      TEXT NOT NULL,
        $categoryIsSynced  INTEGER NOT NULL DEFAULT 0,
        $categoryIsDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE $transactionTable (
        $transId         TEXT PRIMARY KEY,
        $amount     REAL NOT NULL,
        $transNote       TEXT NOT NULL,
        $transType       TEXT NOT NULL,
        $transCatId TEXT NOT NULL,
        $transTimestamp  TEXT NOT NULL,
        $transIsSynced   INTEGER NOT NULL DEFAULT 0,
        $transIsDeleted  INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY ($transCatId) REFERENCES $categoryTable ($categoryId)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
