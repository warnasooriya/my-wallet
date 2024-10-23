import 'package:myfinanceapp/data/db/database_helper.dart';

class BudgetItemDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Insert a new item
  Future<int> insert(Map<String, Object?> budgetItem) async {
    final db = await _dbHelper.database;
    return await db.insert('budget_item', budgetItem);
  }

  Future<List<Map<String, dynamic>>> getByUserIdAndBudget(
      String userId, String budgetId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      "SELECT it.name AS section_name, bi.* FROM budget_item bi INNER JOIN income_types it ON bi.section = it.id WHERE   bi.userId=? and bi.budgetId=?      UNION SELECT et.name AS section_name, bi.* FROM budget_item bi INNER JOIN expenses_type et ON bi.section = et.id WHERE    bi.userId=? and bi.budgetId=?",
      [userId, budgetId, userId, budgetId],
    );
    return maps;
  }

  Future<int> delete(String id, String userId) async {
    final db = await _dbHelper.database;
    int deleteStatus = 0;
    try {
      await db.delete(
        'budget_item',
        where: 'id = ?',
        whereArgs: [id],
      );

      await db.rawQuery(
          'inert into delete_detection (table_name,key_name,key_value,userId) values (?,?,?,?)',
          ['budget_item', 'id', id, userId]);

      deleteStatus = 1;
    } catch (e) {
      print('Error deleting budget items: $e');
    }

    return deleteStatus;
  }
}
