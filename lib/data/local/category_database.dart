import 'package:expense_manager/data/local/database_helper.dart';
import 'package:expense_manager/domain/entities/category.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class CategoryDatabase {
  CategoryDatabase({required DatabaseHelper dbHelper}) : _dbHelper = dbHelper;

  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  Future<Database> get _db async => _dbHelper.database;

  CategoryEntity _fromMap(Map<String, dynamic> map) {
    return CategoryEntity(
      id: map[DatabaseHelper.categoryId] as String,
      name: map[DatabaseHelper.categoryName] as String,
      isSynced: map[DatabaseHelper.categoryIsSynced] as int,
      isDeleted: map[DatabaseHelper.categoryIsDeleted] as int,
    );
  }

  Map<String, dynamic> _toMap(CategoryEntity cat) {
    return {
      DatabaseHelper.categoryId: cat.id,
      DatabaseHelper.categoryName: cat.name,
      DatabaseHelper.categoryIsSynced: cat.isSynced,
      DatabaseHelper.categoryIsDeleted: cat.isDeleted,
    };
  }

  Future<List<CategoryEntity>> getActiveCategories() async {
    final db = await _db;
    final maps = await db.query(
      DatabaseHelper.categoryTable,
      where: '${DatabaseHelper.categoryIsDeleted} = ?',
      whereArgs: [0],
      orderBy: DatabaseHelper.categoryName,
    );
    return maps.map(_fromMap).toList();
  }

  Future<List<CategoryEntity>> getPendingSync() async {
    final db = await _db;
    final maps = await db.query(
      DatabaseHelper.categoryTable,
      where:
          '${DatabaseHelper.categoryIsSynced} = ? AND ${DatabaseHelper.categoryIsDeleted} = ?',
      whereArgs: [0, 0],
    );
    return maps.map(_fromMap).toList();
  }

  Future<List<CategoryEntity>> getPendingDeletion() async {
    final db = await _db;
    final maps = await db.query(
      DatabaseHelper.categoryTable,
      where: '${DatabaseHelper.categoryIsDeleted} = ?',
      whereArgs: [1],
    );
    return maps.map(_fromMap).toList();
  }

  Future<CategoryEntity> insert(String name) async {
    final db = await _db;
    final cat = CategoryEntity(
      id: _uuid.v4(),
      name: name,
      isSynced: 0,
      isDeleted: 0,
    );
    await db.insert(
      DatabaseHelper.categoryTable,
      _toMap(cat),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return cat;
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.update(
      DatabaseHelper.categoryTable,
      {DatabaseHelper.categoryIsDeleted: 1},
      where: '${DatabaseHelper.categoryId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> completeDelete(String id) async {
    final db = await _db;
    await db.delete(
      DatabaseHelper.categoryTable,
      where: '${DatabaseHelper.categoryId} = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db;
    final batch = db.batch();
    for (final id in ids) {
      batch.update(
        DatabaseHelper.categoryTable,
        {DatabaseHelper.categoryIsSynced: 1},
        where: '${DatabaseHelper.categoryId} = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertFromRemote(CategoryEntity cat) async {
    final db = await _db;
    await db.insert(
      DatabaseHelper.categoryTable,
      _toMap(cat.copyWith(isSynced: 1)),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}
