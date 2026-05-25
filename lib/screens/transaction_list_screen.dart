import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../widgets/transaction_bottom_sheet.dart';
import '../widgets/top_toast.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import '../core/config/app_config.dart';
import '../core/di/injection.dart';
import '../domain/repositories/expense_repository.dart';

class TransactionListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final String activeMode;
  final VoidCallback onRefresh;

  const TransactionListScreen({
    super.key,
    required this.transactions,
    required this.activeMode,
    required this.onRefresh,
  });

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  DateTimeRange? _selectedDateRange;
  late List<Map<String, dynamic>> _allTransactions = [];
  late List<Map<String, dynamic>> _displayTransactions = [];

  @override
  void initState() {
    super.initState();
    _allTransactions = widget.transactions;
    // Refresh UI otomatis jika ada sinkronisasi di background
    if (!AppConfig.instance.isOfflineMode) {
      SyncService.instance.onSyncComplete = _loadTransactions;
    }
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await getIt<ExpenseRepository>().getExpenses(type: widget.activeMode);
    if (mounted) {
      setState(() {
        _allTransactions = List<Map<String, dynamic>>.from(data).map((item) {
          return {
            ...item,
            'date': DateTime.parse(item['date']),
          };
        }).toList();
        _applyFilter();
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _displayTransactions = _allTransactions.where((t) {
        final matchesMode = t['type'] == widget.activeMode;
        if (!matchesMode) return false;
        
        if (_selectedDateRange == null) return true;
        
        final transactionDate = t['date'] as DateTime;
        return transactionDate.isAfter(_selectedDateRange!.start.subtract(const Duration(seconds: 1))) &&
               transactionDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    });
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.deleteTransactionTitle ?? 'Hapus Transaksi'),
        content: Text(AppLocalizations.of(context)?.confirmDeleteTransaction ?? 'Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Batal', style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await getIt<ExpenseRepository>().deleteExpense(transaction['id']);
              await _loadTransactions(); // Refresh lokal
              widget.onRefresh(); // Refresh Dashboard (untuk saat kembali)
              if (mounted) {
                Navigator.pop(context);
                TopToast.show(context, AppLocalizations.of(context)?.successDeleteTransaction ?? 'Transaksi berhasil dihapus');
              }
            },
            child: Text(AppLocalizations.of(context)?.delete ?? 'Hapus', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openEditSheet(BuildContext context, Map<String, dynamic> transaction) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TransactionBottomSheet(
          activeMode: widget.activeMode,
          initialTransaction: transaction,
        ),
      ),
    );

    if (result != null) {
      await getIt<ExpenseRepository>().updateExpense(transaction['id'], {
        'amount': result['amount'],
        'description': result['description'],
        'category_id': result['category_id'],
        'account_id': result['account_id'],
        'type': result['type'],
        'transaction_type': result['transaction_type'] ?? 'expense',
      });
      await _loadTransactions(); // Refresh lokal
      widget.onRefresh(); // Refresh Dashboard
      if (mounted) {
        TopToast.show(context, AppLocalizations.of(context)?.successUpdateTransaction ?? 'Transaksi berhasil diperbarui');
      }
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final primaryColor = Colors.orange.shade600;
    final rangeColor = Colors.orange.shade100;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF1E293B),
            ),
            datePickerTheme: DatePickerThemeData(
              rangeSelectionBackgroundColor: rangeColor,
              rangePickerHeaderBackgroundColor: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'id_ID');
    final Color themeColor = widget.activeMode == 'personal' ? Colors.orange.shade600 : Colors.teal.shade600;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.allTransactionsTitle ?? 'Semua Transaksi'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month, color: _selectedDateRange != null ? themeColor : Colors.grey),
            onPressed: () => _selectDateRange(context),
          ),
          if (_selectedDateRange != null)
            IconButton(
              icon: const Icon(Icons.filter_list_off, color: Colors.red),
              onPressed: () {
                setState(() => _selectedDateRange = null);
                _applyFilter();
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Text(
                  _selectedDateRange == null 
                    ? (AppLocalizations.of(context)?.showingAll ?? 'Menampilkan Semua')
                    : '${AppLocalizations.of(context)?.filterLabel ?? 'Filter'}: ${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  '${_displayTransactions.length} ${AppLocalizations.of(context)?.transactionCountLabel ?? 'Transaksi'}',
                  style: TextStyle(fontSize: 12, color: themeColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: _displayTransactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)?.emptyTransaction ?? 'Belum ada transaksi',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _displayTransactions.length,
              itemBuilder: (context, index) {
                final item = _displayTransactions[index];
                final isIncome = item['transaction_type'] == 'income';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openEditSheet(context, item),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isIncome ? Colors.green.shade600 : Colors.red.shade600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['category'] ?? 'Uncategorized',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                         if (!AppConfig.instance.isOfflineMode) ...[
                                          if (item['sync_status'] == 'syncing')
                                            const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                                            )
                                          else if (item['sync_status'] == 'pending')
                                            Icon(Icons.cloud_queue, size: 14, color: Colors.grey.shade400),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['description'] == null || item['description'].isEmpty 
                                          ? (item['account'] ?? 'Unknown Account') 
                                          : item['description'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMM yyyy, HH:mm').format(item['date']),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${isIncome ? '+' : '-'} Rp ${formatter.format(item['amount'])}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isIncome ? Colors.green.shade600 : Colors.red.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _actionIcon(Icons.edit_outlined, Colors.blue, () => _openEditSheet(context, item)),
                                      const SizedBox(width: 8),
                                      _actionIcon(Icons.delete_outline, Colors.red, () => _showDeleteConfirmation(context, item)),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
