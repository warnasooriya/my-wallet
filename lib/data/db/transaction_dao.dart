import 'package:myfinanceapp/data/db/database_helper.dart';
import 'package:myfinanceapp/data/dto/DashbardResponseDto.dart';

class TransactionDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Map<String, Object?> transaction) async {
    final db = await _dbHelper.database;
    return await db.insert('transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getByUserId(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps;
  }

  Future<List<Map<String, dynamic>>> getByUserIdAndPeriod(
      String uid, String selectedFromDate, String selectedToDate) {
    return _dbHelper.database.then((db) {
      return db.rawQuery(
        "SELECT t.* , i.name as section_name FROM transactions t inner join income_types i ON t.section=i.id where t.userId=? and date between ? and ?  UNION ALL SELECT t.* , i.name as section_name FROM transactions t inner join expenses_type i ON t.section=i.id where t.userId=? and date between ? and ?  order by date desc",
        [
          uid,
          selectedFromDate,
          selectedToDate,
          uid,
          selectedFromDate,
          selectedToDate
        ],
      );
    });
  }

  Future<DashbardResponseDto> getDataForDashbord(String userId) async {
    double budgetAmount = 0.0;
    final db = await _dbHelper.database;
    String today = DateTime.now().toIso8601String().substring(0, 10);
    List<Map<String, dynamic>> currectBudget = await db.rawQuery(
        "select id,startDate,enddate from budget where ? between startDate and endDate AND userId=?  limit 1",
        [today, userId]);

    // get current month start date and end date
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    String startDate = firstDayOfMonth.toIso8601String().substring(0, 10);
    String endDate = lastDayOfMonth.toIso8601String().substring(0, 10);

    if (currectBudget.isNotEmpty) {
      startDate = (currectBudget.first['startDate'] as String).substring(0, 10);
      endDate = (currectBudget.first['enddate'] as String).substring(0, 10);
      List<Map> budgetAmountList = await db.rawQuery(
          "SELECT  ifnull( sum(amount),0) as budget  FROM  budget_item where userId=? and type='Expense' and budgetId=? ",
          [userId, currectBudget.first['id']]);
      if (budgetAmountList.isNotEmpty) {
        budgetAmount =
            double.parse(budgetAmountList.first['budget'].toString());
      }
    }

    List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT (select ifnull(sum(amount),0) as amount from transactions where userId=? and type='Income') as totaincome , (select ifnull(sum(amount),0) as amount from transactions where userId=? and type='Expense') totalexpenses   FROM transactions where userId=? and date between ? and ?",
      [userId, userId, userId, startDate, endDate],
    );

    List<Map<String, dynamic>> expensesList = await db.rawQuery(
        "select sum(t.amount) as value , e.name  from transactions t inner join expenses_type e ON t.section=e.id where t.type='Expense' and t.userId=? and t.date between ? and ? group by e.name",
        [userId, startDate, endDate]);

    List<Map<String, dynamic>> incomeList = await db.rawQuery(
        "select sum(t.amount) as value , e.name  from transactions t inner join income_types e ON t.section=e.id where t.type='Income' and t.userId=? and t.date between ? and ? group by e.name",
        [userId, startDate, endDate]);

    List<Map<String, dynamic>> incomeVsExpensesList = await db.rawQuery(
        "SELECT sum(amount) as value, strftime('%Y-%m', date) as category, type FROM transactions WHERE userId=?   AND strftime('%Y', date) = strftime('%Y', 'now') GROUP BY strftime('%Y-%m', date), type",
        [userId]);

    if (result.isEmpty) {
      return DashbardResponseDto(
          totalIncome: 0,
          totalExpenses: 0,
          totalBalance: 0,
          startDate: startDate,
          endDate: endDate,
          totalBudget: budgetAmount,
          expensesList: expensesList,
          incomeList: incomeList,
          incomeVsExpensesList: incomeVsExpensesList);
    } else {
      return DashbardResponseDto(
          totalIncome: double.parse(result.first['totaincome'].toString()),
          totalExpenses: double.parse(result.first['totalexpenses'].toString()),
          totalBalance: double.parse(result.first['totaincome'].toString()) -
              double.parse(result.first['totalexpenses'].toString()),
          startDate: startDate,
          endDate: endDate,
          totalBudget: budgetAmount,
          expensesList: expensesList,
          incomeList: incomeList,
          incomeVsExpensesList: incomeVsExpensesList);
    }
  }
}
