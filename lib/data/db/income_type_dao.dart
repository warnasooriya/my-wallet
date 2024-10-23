import 'package:myfinanceapp/data/models/IncomeTypes.dart';
import 'database_helper.dart';

class IncomeTypeDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Insert a new item
  Future<int> insertIncomeType(Map<String, Object?> incomeType) async {
    final db = await _dbHelper.database;
    return await db.insert('income_types', incomeType);
  }

  // Get all items
  Future<List<IncomeTypes>> getIncomeTypes() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('income_types');

    return List.generate(maps.length, (i) {
      return IncomeTypes.fromMap(maps[i]);
    });
  }

  // Update an item
  Future<int> updateItem(IncomeTypes item) async {
    final db = await _dbHelper.database;
    return await db.update(
      'income_types',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete an item
  Future<int> deleteItem(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'income_types',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getIncomeTypesByUserId(
      String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'income_types',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return maps;
  }

  Future<int> delete(String id, String userId) async {
    final db = await _dbHelper.database;
    int deleteStatus = 0;
    try {
      await db.delete(
        'income_types',
        where: 'id = ?',
        whereArgs: [id],
      );

      await db.rawQuery(
          'inert into delete_detection (table_name,key_name,key_value,userId) values (?,?,?,?)',
          ['income_types', 'id', id, userId]);

      deleteStatus = 1;
    } catch (e) {
      print('Error deleting income_types : $e');
    }

    return deleteStatus;
  }
}
