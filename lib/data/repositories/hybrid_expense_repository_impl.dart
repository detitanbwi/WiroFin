import '../../domain/repositories/expense_repository.dart';
import '../../services/database_helper.dart';
import '../../services/sync_service.dart';

class HybridExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseHelper _dbHelper;
  final SyncService _syncService;

  HybridExpenseRepositoryImpl(this._dbHelper, this._syncService);

  @override
  Future<List<Map<String, dynamic>>> getExpenses({String? type, String? transactionType, DateTime? startDate, DateTime? endDate}) {
    return _dbHelper.getExpensesWithDetails(type: type, transactionType: transactionType, startDate: startDate, endDate: endDate);
  }

  @override
  Future<String> saveExpense(Map<String, dynamic> data) async {
    final id = await _dbHelper.insertExpense(data);
    _syncService.syncPendingData(); // Trigger sync
    return id;
  }

  @override
  Future<int> updateExpense(String id, Map<String, dynamic> data) async {
    final result = await _dbHelper.updateExpense(id, data);
    _syncService.syncPendingData(); // Trigger sync
    return result;
  }

  @override
  Future<int> deleteExpense(String id) {
    // Note: Delete normally requires soft delete if syncing, 
    // but here we follow existing logic.
    return _dbHelper.deleteExpense(id);
  }
}
