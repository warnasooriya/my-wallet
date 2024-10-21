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
      "SELECT * , (select ifnull(sum(amount),0) as amount from budget_item where userId=? and type='Income') as totaincome , (select ifnull(sum(amount),0) as amount from budget_item where userId=? and type='Expense') totalexpenses FROM budget where userId=?",
      [userId, userId, userId],
    );
    return maps;
  }
}
