import 'package:myfinanceapp/data/db/expenses_type.dart';
import 'package:myfinanceapp/data/models/ExpensesType.dart';

class ExpensesTypeService {
  final ExpensesTypeDAO _expensesTypeDAO = ExpensesTypeDAO();

  Future<int> insertIncomeType(Map<String, Object?> expenseType) async {
    return await _expensesTypeDAO.insert(expenseType);
  }

  Future<List<Map<String, dynamic>>> getItemsForUser(String userId) async {
    return await _expensesTypeDAO.getByUserId(userId);
  }

  Future<int> delete(String id, String userId) async {
    return await _expensesTypeDAO.delete(id, userId);
  }
}
