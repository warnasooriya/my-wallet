import 'package:myfinanceapp/data/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class DataSyncDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getTableByUserId(
      String tableName, String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps;
    // sync data
  }

  Future<int> insertData(String tableName, Map<String, Object?> data) async {
    final db = await _dbHelper.database;
    return await db.insert(tableName, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
