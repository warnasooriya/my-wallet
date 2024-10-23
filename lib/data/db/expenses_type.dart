import 'package:myfinanceapp/data/models/ExpensesType.dart';
import 'database_helper.dart';

class ExpensesTypeDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Insert a new item
  Future<int> insert(Map<String, Object?> expenseType) async {
    final db = await _dbHelper.database;
    return await db.insert('expenses_type', expenseType);
  }

  // Update an item
  Future<int> update(Expensestype item) async {
    final db = await _dbHelper.database;
    return await db.update(
      'expenses_type',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(String id, String userId) async {
    final db = await _dbHelper.database;
    int deleteStatus = 0;
    try {
      await db.delete(
        'expenses_type',
        where: 'id = ?',
        whereArgs: [id],
      );

      await db.rawQuery(
          'inert into delete_detection (table_name,key_name,key_value,userId) values (?,?,?,?)',
          ['expenses_type', 'id', id, userId]);

      deleteStatus = 1;
    } catch (e) {
      print('Error deleting expenses_type : $e');
    }

    return deleteStatus;
  }

  Future<List<Map<String, dynamic>>> getByUserId(String userId) async {
    print('calling to DAO');
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses_type',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps;
  }
}
