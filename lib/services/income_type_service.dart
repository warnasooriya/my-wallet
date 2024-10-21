import 'package:myfinanceapp/data/db/income_type_dao.dart';

import '../data/models/IncomeTypes.dart';

class IncomeTypeService {
  final IncomeTypeDAO _incomeTypeDAO = IncomeTypeDAO();

  Future<int> insertIncomeType(Map<String, Object?> incomeType) async {
    return await _incomeTypeDAO.insertIncomeType(incomeType);
  }

  Future<List<Map<String, dynamic>>> getItemsForUser(String userId) async {
    return await _incomeTypeDAO.getIncomeTypesByUserId(userId);
  }

  Future<int> delete(String id) async {
    return await _incomeTypeDAO.delete(id);
  }
}
