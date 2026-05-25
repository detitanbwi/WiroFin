import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class WidgetService {
  static const String androidWidgetSmall = 'WiroFinSmallWidgetProvider';
  static const String androidWidgetMedium = 'WiroFinMediumWidgetProvider';
  static const String iOSWidgetName = 'WiroFinWidget';

  static Future<void> syncDataToWidget(String activeMode) async {
    final db = DatabaseHelper.instance;
    final transactions = await db.getExpensesWithDetails(type: activeMode);
    final accounts = await db.getAccounts(activeMode);
    final totalInitBalance = accounts.fold<double>(0, (sum, acc) => sum + ((acc['balance'] as num?)?.toDouble() ?? 0));
    
    double balance = totalInitBalance;
    double incomeThisMonth = 0;
    double expenseThisMonth = 0;
    
    final now = DateTime.now();
    final currentMonthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    for (var tx in transactions) {
      final amount = (tx['amount'] as num).toDouble();
      final type = tx['transaction_type'] as String? ?? 'expense';
      final date = tx['date'] as String? ?? ''; 
      
      if (type == 'income') {
        balance += amount;
        if (date.startsWith(currentMonthStr)) incomeThisMonth += amount;
      } else {
        balance -= amount;
        if (date.startsWith(currentMonthStr)) expenseThisMonth += amount;
      }
    }

    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    await HomeWidget.saveWidgetData<String>('widget_balance', currencyFormatter.format(balance));
    await HomeWidget.saveWidgetData<String>('widget_income_str', currencyFormatter.format(incomeThisMonth));
    await HomeWidget.saveWidgetData<String>('widget_expense_str', currencyFormatter.format(expenseThisMonth));
    
    await HomeWidget.saveWidgetData<String>('widget_income_raw', incomeThisMonth.toString());
    await HomeWidget.saveWidgetData<String>('widget_expense_raw', expenseThisMonth.toString());
    await HomeWidget.saveWidgetData<String>('widget_active_mode', activeMode);
    
    await HomeWidget.updateWidget(
      name: androidWidgetSmall,
      iOSName: iOSWidgetName,
    );
    await HomeWidget.updateWidget(
      name: androidWidgetMedium,
      iOSName: iOSWidgetName,
    );
  }
}
