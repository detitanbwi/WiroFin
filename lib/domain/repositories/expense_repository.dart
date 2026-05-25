abstract class ExpenseRepository {
  Future<List<Map<String, dynamic>>> getExpenses({String? type, String? transactionType, DateTime? startDate, DateTime? endDate});
  Future<String> saveExpense(Map<String, dynamic> data);
  Future<int> updateExpense(String id, Map<String, dynamic> data);
  Future<int> deleteExpense(String id);
}
