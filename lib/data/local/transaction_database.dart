import 'package:expense_manager/data/local/database_helper.dart';
import 'package:expense_manager/domain/entities/transaction.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class TransactionDatabase {
  TransactionDatabase({required DatabaseHelper dbHelper})
    : _dbHelper = dbHelper;

  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  Future<Database> get _db async => _dbHelper.database;

  TransactionEntity _fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map[DatabaseHelper.transId] as String,
      amount: (map[DatabaseHelper.amount] as num).toDouble(),
      note: map[DatabaseHelper.transNote] as String,
      type: map[DatabaseHelper.transType] as String,
      categoryId: map[DatabaseHelper.transCatId] as String,
      categoryName: map['category_name'] as String? ?? '',
      timestamp: DateTime.parse(map[DatabaseHelper.transTimestamp] as String),
      isSynced: map[DatabaseHelper.transIsSynced] as int,
      isDeleted: map[DatabaseHelper.transIsDeleted] as int,
    );
  }

  Future<List<TransactionEntity>> getRecent({int limit = 10}) async {
    final db = await _db;
    final maps = await db.rawQuery(
      '''
      SELECT t.*, c.${DatabaseHelper.categoryName} AS category_name
      FROM ${DatabaseHelper.transactionTable} t
      LEFT JOIN ${DatabaseHelper.categoryTable} c
        ON t.${DatabaseHelper.transCatId} = c.${DatabaseHelper.categoryId}
      WHERE t.${DatabaseHelper.transIsDeleted} = 0
      ORDER BY t.${DatabaseHelper.transTimestamp} DESC
      LIMIT ?
    ''',
      [limit],
    );
    return maps.map(_fromMap).toList();
  }

  Future<List<TransactionEntity>> getAllTransactions() async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT t.*, c.${DatabaseHelper.categoryName} AS category_name
      FROM ${DatabaseHelper.transactionTable} t
      LEFT JOIN ${DatabaseHelper.categoryTable} c
        ON t.${DatabaseHelper.transCatId} = c.${DatabaseHelper.categoryId}
      WHERE t.${DatabaseHelper.transIsDeleted} = 0
      ORDER BY t.${DatabaseHelper.transTimestamp} DESC
    ''');
    return maps.map(_fromMap).toList();
  }

  Future<List<TransactionEntity>> getPendingSync() async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT t.*, c.${DatabaseHelper.categoryName} AS category_name
      FROM ${DatabaseHelper.transactionTable} t
      LEFT JOIN ${DatabaseHelper.categoryTable} c
        ON t.${DatabaseHelper.transCatId} = c.${DatabaseHelper.categoryId}
      WHERE t.${DatabaseHelper.transIsSynced} = 0 AND t.${DatabaseHelper.transIsDeleted} = 0
    ''');
    return maps.map(_fromMap).toList();
  }

  Future<List<TransactionEntity>> getPendingDeletion() async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT t.*, c.${DatabaseHelper.categoryName} AS category_name
      FROM ${DatabaseHelper.transactionTable} t
      LEFT JOIN ${DatabaseHelper.categoryTable} c
        ON t.${DatabaseHelper.transCatId} = c.${DatabaseHelper.categoryId}
      WHERE t.${DatabaseHelper.transIsDeleted} = 1
    ''');
    return maps.map(_fromMap).toList();
  }

  Future<TransactionEntity> insert({
    required double amount,
    required String note,
    required String type,
    required String categoryId,
    required String categoryName,
  }) async {
    final db = await _db;
    final trans = TransactionEntity(
      id: _uuid.v4(),
      amount: amount,
      note: note,
      type: type,
      categoryId: categoryId,
      categoryName: categoryName,
      timestamp: DateTime.now(),
      isSynced: 0,
      isDeleted: 0,
    );
    await db.insert(
      DatabaseHelper.transactionTable,
      {
        DatabaseHelper.transId: trans.id,
        DatabaseHelper.amount: trans.amount,
        DatabaseHelper.transNote: trans.note,
        DatabaseHelper.transType: trans.type,
        DatabaseHelper.transCatId: trans.categoryId,
        DatabaseHelper.transTimestamp: trans.timestamp.toIso8601String(),
        DatabaseHelper.transIsSynced: trans.isSynced,
        DatabaseHelper.transIsDeleted: trans.isDeleted,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return trans;
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.update(
      DatabaseHelper.transactionTable,
      {DatabaseHelper.transIsDeleted: 1},
      where: '${DatabaseHelper.transId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> completeDelete(String id) async {
    final db = await _db;
    await db.delete(
      DatabaseHelper.transactionTable,
      where: '${DatabaseHelper.transId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db;
    final batch = db.batch();
    for (final id in ids) {
      batch.update(
        DatabaseHelper.transactionTable,
        {DatabaseHelper.transIsSynced: 1},
        where: '${DatabaseHelper.transId} = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertFromRemote(TransactionEntity trans) async {
    final db = await _db;
    await db.insert(DatabaseHelper.transactionTable, {
      DatabaseHelper.transId: trans.id,
      DatabaseHelper.amount: trans.amount,
      DatabaseHelper.transNote: trans.note,
      DatabaseHelper.transType: trans.type,
      DatabaseHelper.transCatId: trans.categoryId,
      DatabaseHelper.transTimestamp: trans.timestamp.toIso8601String(),
      DatabaseHelper.transIsSynced: 1,
      DatabaseHelper.transIsDeleted: 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}
