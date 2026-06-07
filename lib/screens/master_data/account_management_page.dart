import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../services/database_helper.dart';
import 'currency_input_formatter.dart';

class AccountManagementPage extends StatefulWidget {
  final String activeMode;
  const AccountManagementPage({super.key, required this.activeMode});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;
  late String _currentType;

  @override
  void initState() {
    super.initState();
    _currentType = widget.activeMode;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final accounts = await DatabaseHelper.instance.getAccounts(_currentType);
    setState(() {
      _accounts = accounts;
      _isLoading = false;
    });
  }

  void _showAddEditDialog({Map<String, dynamic>? item}) {
    final TextEditingController nameController = TextEditingController(text: item?['name'] ?? '');
    final int initialBalance = item?['balance'] ?? 0;
    final String formattedInitialBalance = initialBalance == 0 ? '' : NumberFormat('#,###', 'id_ID').format(initialBalance);
    final TextEditingController balanceController = TextEditingController(text: formattedInitialBalance);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          item == null
              ? (AppLocalizations.of(context)?.addBankAccount ?? 'Tambah Rekening')
              : (AppLocalizations.of(context)?.editBankAccount ?? 'Edit Rekening'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.bankAccountName ?? 'Nama Rekening',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: balanceController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.initialBalance ?? 'Saldo Awal',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final balanceStr = balanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
                final balance = int.tryParse(balanceStr) ?? 0;
                final data = {'name': nameController.text.trim(), 'type': _currentType, 'balance': balance};
                if (item == null) {
                  await DatabaseHelper.instance.insertAccount(data);
                } else {
                  await DatabaseHelper.instance.updateAccount(item['id'], data);
                }
                Navigator.pop(context);
                _loadData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(AppLocalizations.of(context)?.save ?? 'Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.deleteDataTitle ?? 'Hapus Data'),
        content: Text(AppLocalizations.of(context)?.confirmDeleteAccount ?? 'Apakah Anda yakin ingin menghapus rekening ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)?.cancel ?? 'Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context)?.delete ?? 'Hapus', style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteAccount(id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isId = AppLocalizations.of(context)?.localeName == 'id';
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.bankAccountManagement ?? 'Pengelolaan Rekening', style: const TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'personal', label: Text('Pribadi')),
                  ButtonSegment(value: 'company', label: Text('Perusahaan')),
                ],
                selected: {_currentType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _currentType = newSelection.first;
                  });
                  _loadData();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).primaryColor.withOpacity(0.1);
                    }
                    return Colors.white;
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)?.emptyAccount ?? 'Belum ada data rekening', style: TextStyle(color: Colors.grey.shade400)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _accounts.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = _accounts[index];
                    final balance = (item['balance'] as num?)?.toInt() ?? 0;
                    final formattedBalance = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(balance);
                    return ListTile(
                      title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('${isId ? "Saldo" : "Balance"}: $formattedBalance', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showAddEditDialog(item: item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteItem(item['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
