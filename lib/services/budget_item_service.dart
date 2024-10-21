import 'package:myfinanceapp/data/db/budget_dao.dart';
import 'package:myfinanceapp/data/db/budget_item_dao.dart';

class BudgetItemService {
  final BudgetItemDAO _budgetItemDAO = BudgetItemDAO();

  Future<int> insert(Map<String, Object?> budget) async {
    return await _budgetItemDAO.insert(budget);
  }

  Future<List<Map<String, dynamic>>> getByUserIdAndBudget(
      userId, budgetId) async {
    return await _budgetItemDAO.getByUserIdAndBudget(userId, budgetId);
  }
}
