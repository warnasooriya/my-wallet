import 'package:myfinanceapp/data/db/database_helper.dart';

class BudgetDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Insert a new item
  Future<int> insert(Map<String, Object?> budget) async {
    final db = await _dbHelper.database;
    return await db.insert('budget', budget);
  }

  Future<List<Map<String, dynamic>>> getByUserId(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      "SELECT * , (select ifnull(sum(amount),0) as amount from budget_item where userId=? and type='Income' and budgetId=budget.id) as totaincome , (select ifnull(sum(amount),0) as amount from budget_item where userId=? and type='Expense' and budgetId=budget.id) totalexpenses FROM budget where userId=?",
      [userId, userId, userId],
    );
    return maps;
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    int deleteStatus = 0;
    try {
      await db.delete(
        'budget_item',
        where: 'budgetId = ?',
        whereArgs: [id],
      );

      await db.delete(
        'budget',
        where: 'id = ?',
        whereArgs: [id],
      );

      await db.rawQuery(
          'inert into delete_detection (table_name,key_name,key_value,userId) values (?,?,?,?)',
          [id, 'budget_item', 'budgetId', id]);

      await db.rawQuery(
          'inert into delete_detection (table_name,key_name,key_value,userId) values (?,?,?,?)',
          [id, 'budget', 'id', id]);

      deleteStatus = 1;
    } catch (e) {
      print('Error deleting budget: $e');
    }
    return deleteStatus;
  }
}
