import 'package:myfinanceapp/data/db/transaction_dao.dart';
import 'package:myfinanceapp/data/dto/DashbardResponseDto.dart';

class TransactionService {
  final TransactionDAO _transactionDAO = TransactionDAO();

  Future<int> insertTransaction(Map<String, Object?> transaction) async {
    return await _transactionDAO.insert(transaction);
  }

  Future<List<Map<String, dynamic>>> getItemsForUser(String userId) async {
    return await _transactionDAO.getByUserId(userId);
  }

  Future<List<Map<String, dynamic>>> getByUserIdAndPeriod(
      String uid, String selectedFromDate, String selectedToDate) {
    return _transactionDAO.getByUserIdAndPeriod(
        uid, selectedFromDate, selectedToDate);
  }

  Future<DashbardResponseDto> getDataForDashbord(String userId) {
    return _transactionDAO.getDataForDashbord(userId);
  }

  Future<int> delete(String id, String userId) async {
    return _transactionDAO.delete(id, userId);
  }
}
