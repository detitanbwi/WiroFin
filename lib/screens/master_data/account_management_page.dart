import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../services/database_helper.dart';
import 'currency_input_formatter.dart';

class InstalledApp {
  final String packageName;
  final String name;
  final String appKey;
  final Uint8List icon;

  InstalledApp({
    required this.packageName,
    required this.name,
    required this.appKey,
    required this.icon,
  });

  factory InstalledApp.fromMap(Map<dynamic, dynamic> map) {
    // Icon dari platform channel bisa berupa List<dynamic> atau Uint8List
    final rawIcon = map['icon'];
    Uint8List iconBytes;
    if (rawIcon is Uint8List) {
      iconBytes = rawIcon;
    } else if (rawIcon is List) {
      iconBytes = Uint8List.fromList(rawIcon.cast<int>());
    } else {
      iconBytes = Uint8List(0);
    }
    return InstalledApp(
      packageName: map['packageName'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown',
      appKey: map['appKey'] as String? ?? '',
      icon: iconBytes,
    );
  }
}

class AccountManagementPage extends StatefulWidget {
  final String activeMode;
  const AccountManagementPage({super.key, required this.activeMode});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage>
    with WidgetsBindingObserver {
  static const Map<String, String> supportedApps = {
    'mybca': 'myBCA',
    'bca_mobile': 'BCA Mobile',
    'blu': 'Blu by BCA',
    'brimo': 'BRImo (BRI)',
    'livin': 'Livin\' by Mandiri',
    'bni': 'BNI Mobile',
    'jago': 'Bank Jago',
    'allobank': 'Allo Bank',
    'btn': 'BTN Mobile',
    'jenius': 'Jenius',
    'dana': 'DANA',
    'krom': 'Krom Bank',
    'seabank': 'Sea Bank',
  };

  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;
  late String _currentType;
  List<InstalledApp> _installedApps = [];
  bool _loadingInstalledApps = true;

  @override
  void initState() {
    super.initState();
    _currentType = widget.activeMode;
    _loadData();
    _loadInstalledApps();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh list saat app kembali dari background
    // (misal: user baru install app perbankan lalu balik ke WiroFin)
    if (state == AppLifecycleState.resumed) {
      _loadInstalledApps();
    }
  }

  Future<void> _loadInstalledApps() async {
    try {
      const channel = MethodChannel('com.wirodev.wirofin/auto_track');
      final List<dynamic>? list = await channel.invokeMethod('getInstalledBankingApps');
      developer.log('getInstalledBankingApps result: ${list?.length} apps', name: 'AccountManagement');
      if (list != null) {
        final apps = <InstalledApp>[];
        for (final item in list) {
          try {
            final app = InstalledApp.fromMap(item as Map<dynamic, dynamic>);
            developer.log('Loaded app: ${app.name} (${app.packageName})', name: 'AccountManagement');
            apps.add(app);
          } catch (e) {
            developer.log('Error parsing app: $e | item: $item', name: 'AccountManagement');
          }
        }
        setState(() {
          _installedApps = apps;
          _loadingInstalledApps = false;
        });
      } else {
        developer.log('getInstalledBankingApps returned null', name: 'AccountManagement');
        setState(() => _loadingInstalledApps = false);
      }
    } catch (e, st) {
      developer.log('Error loading installed apps: $e\n$st', name: 'AccountManagement');
      setState(() => _loadingInstalledApps = false);
    }
  }

  List<DropdownMenuItem<String?>> _buildDropdownItems() {
    final List<DropdownMenuItem<String?>> items = [];
    final installedKeys = _installedApps.map((a) => a.appKey).toSet();

    // 1. Add Installed Apps first
    for (var app in _installedApps) {
      final hasIcon = app.icon.isNotEmpty;
      items.add(
        DropdownMenuItem<String?>(
          value: app.appKey,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: hasIcon
                    ? Image.memory(
                        app.icon,
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, size: 20, color: Colors.blue),
                      )
                    : const Icon(Icons.account_balance, size: 20, color: Colors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  app.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.check_circle, color: Colors.green, size: 14),
            ],
          ),
        ),
      );
    }

    // 2. Add uninstalled supported apps
    supportedApps.forEach((key, name) {
      if (!installedKeys.contains(key)) {
        items.add(
          DropdownMenuItem<String?>(
            value: key,
            child: Row(
              children: [
                const Icon(Icons.account_balance_outlined, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(color: Colors.grey.shade600, overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(Belum Terpasang)',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      }
    });

    return items;
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
      builder: (context) {
        String? dialogSelectedPackage = item?['linked_package'];

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                item == null
                    ? (AppLocalizations.of(context)?.addBankAccount ?? 'Tambah Rekening')
                    : (AppLocalizations.of(context)?.editBankAccount ?? 'Edit Rekening'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              content: SingleChildScrollView(
                child: Column(
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      value: dialogSelectedPackage,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Hubungkan Aplikasi (Auto-Track)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Row(
                            children: [
                              Icon(Icons.link_off, color: Colors.grey, size: 20),
                              SizedBox(width: 8),
                              Text('Tidak Terhubung'),
                            ],
                          ),
                        ),
                        ..._buildDropdownItems(),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          dialogSelectedPackage = val;
                        });
                      },
                    ),
                  ],
                ),
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
                      final data = {
                        'name': nameController.text.trim(),
                        'type': _currentType,
                        'balance': balance,
                        'linked_package': dialogSelectedPackage,
                      };
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
            );
          }
        );
      },
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${isId ? "Saldo" : "Balance"}: $formattedBalance', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          if (item['linked_package'] != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt, size: 12, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Auto-Track: ${supportedApps[item['linked_package']] ?? item['linked_package']}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
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
