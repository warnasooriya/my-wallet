import 'package:myfinanceapp/data/db/budget_dao.dart';

class BudgetService {
  final BudgetDAO _budgetDAO = BudgetDAO();

  Future<int> insert(Map<String, Object?> budget) async {
    return await _budgetDAO.insert(budget);
  }

  Future<List<Map<String, dynamic>>> getByUserId(userId) async {
    return await _budgetDAO.getByUserId(userId);
  }
}
