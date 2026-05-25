import '../../domain/repositories/expense_repository.dart';
import '../../services/database_helper.dart';

class OfflineExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseHelper _dbHelper;

  OfflineExpenseRepositoryImpl(this._dbHelper);

  @override
  Future<List<Map<String, dynamic>>> getExpenses({String? type, String? transactionType, DateTime? startDate, DateTime? endDate}) {
    return _dbHelper.getExpensesWithDetails(type: type, transactionType: transactionType, startDate: startDate, endDate: endDate);
  }

  @override
  Future<String> saveExpense(Map<String, dynamic> data) {
    return _dbHelper.insertExpense(data);
  }

  @override
  Future<int> updateExpense(String id, Map<String, dynamic> data) {
    return _dbHelper.updateExpense(id, data);
  }

  @override
  Future<int> deleteExpense(String id) {
    return _dbHelper.deleteExpense(id);
  }
}
