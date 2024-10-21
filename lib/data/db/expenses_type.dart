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

  // Delete an item
  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'expenses_type',
      where: 'id = ?',
      whereArgs: [id],
    );
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
