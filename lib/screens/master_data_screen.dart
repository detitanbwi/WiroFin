import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../services/database_helper.dart';
import '../services/backup_service.dart';
import '../core/services/preference_service.dart';
import '../core/config/app_config.dart';
import '../widgets/top_toast.dart';

class MasterDataScreen extends StatelessWidget {
  final String activeMode;
  const MasterDataScreen({super.key, required this.activeMode});

  @override
  Widget build(BuildContext context) {
    final isPersonal = activeMode == 'personal';
    // Gunakan warna sesuai instruksi MoM
    final bgColor = isPersonal ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9);
    final leadingIconColor = isPersonal ? const Color(0xFF2563EB) : const Color(0xFFD4AF37);
    final trailingIconColor = const Color(0xFF334155);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.masterData ?? 'Master Data', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuTile(
            context,
            icon: Icons.person_outline,
            title: AppLocalizations.of(context)?.userProfile ?? 'Profil Pengguna',
            iconColor: leadingIconColor,
            trailingColor: trailingIconColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSettingsPage())),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: AppLocalizations.of(context)?.bankAccountManagement ?? 'Pengelolaan Rekening',
            iconColor: leadingIconColor,
            trailingColor: trailingIconColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AccountManagementPage(activeMode: activeMode))),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.category_outlined,
            title: AppLocalizations.of(context)?.transactionCategory ?? 'Kategori Transaksi',
            iconColor: leadingIconColor,
            trailingColor: trailingIconColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategorySettingsPage(activeMode: activeMode))),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.backup_outlined,
            title: AppLocalizations.of(context)?.dataBackupRestore ?? 'Cadangan Data (Backup & Restore)',
            iconColor: leadingIconColor,
            trailingColor: trailingIconColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupRestorePage())),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.help_outline,
            title: AppLocalizations.of(context)?.widgetGuideTitle ?? 'Panduan Widget',
            iconColor: leadingIconColor,
            trailingColor: trailingIconColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WidgetGuidePage())),
          ),
          if (AppConfig.instance.enableDebugTools) ...[
            const SizedBox(height: 12),
            _buildMenuTile(
              context,
              icon: Icons.bug_report_outlined,
              title: 'Uji Coba & Reset Status (Mode Testing)',
              iconColor: const Color(0xFF8B5CF6),
              trailingColor: trailingIconColor,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DebugToolsPage())),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, {
    required IconData icon, 
    required String title, 
    required Color iconColor, 
    required Color trailingColor, 
    required VoidCallback onTap
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        highlightColor: iconColor.withOpacity(0.05),
        splashColor: iconColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
              ),
              Icon(Icons.chevron_right, color: trailingColor),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 1. PROFILE SETTINGS PAGE
// ============================================================================

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: PreferenceService.instance.userName);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.userProfile ?? 'Profil Pengguna', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.profile ?? 'Profil Pengguna',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.usernameLabel ?? 'Nama Panggilan',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await PreferenceService.instance.setUserName(nameController.text);
                  if (mounted) {
                    TopToast.show(context, AppLocalizations.of(context)?.successSaveProfile ?? 'Profil berhasil disimpan');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)?.saveProfile ?? 'Simpan Profil'),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)?.language ?? 'Bahasa / Language',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<Locale>(
              valueListenable: PreferenceService.instance.localeNotifier,
              builder: (context, locale, child) {
                return SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment<String>(
                      value: 'id',
                      label: Text('🇮🇩 Indonesia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    ButtonSegment<String>(
                      value: 'en',
                      label: Text('🇬🇧 English', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (Set<String> newSelection) {
                    final lang = newSelection.first;
                    PreferenceService.instance.setLanguage(lang);
                    TopToast.show(context, lang == 'id' ? 'Bahasa diubah ke Indonesia' : 'Language changed to English');
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return primaryColor.withOpacity(0.1);
                      }
                      return Colors.white;
                    }),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. ACCOUNT MANAGEMENT PAGE
// ============================================================================

class AccountManagementPage extends StatefulWidget {
  final String activeMode;
  const AccountManagementPage({super.key, required this.activeMode});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final accounts = await DatabaseHelper.instance.getAccounts(widget.activeMode);
    setState(() {
      _accounts = accounts;
      _isLoading = false;
    });
  }

  void _showAddEditDialog({Map<String, dynamic>? item}) {
    final TextEditingController nameController = TextEditingController(text: item?['name'] ?? '');
    final TextEditingController balanceController = TextEditingController(text: (item?['balance'] ?? 0).toString());

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
              ),
              keyboardType: TextInputType.number,
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
                final balance = int.tryParse(balanceController.text) ?? 0;
                final data = {'name': nameController.text.trim(), 'type': widget.activeMode, 'balance': balance};
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

// ============================================================================
// 3. CATEGORY SETTINGS PAGE
// ============================================================================

class CategorySettingsPage extends StatefulWidget {
  final String activeMode;
  const CategorySettingsPage({super.key, required this.activeMode});

  @override
  State<CategorySettingsPage> createState() => _CategorySettingsPageState();
}

class _CategorySettingsPageState extends State<CategorySettingsPage> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final categories = await DatabaseHelper.instance.getCategories(widget.activeMode);
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  void _showAddEditDialog({Map<String, dynamic>? item}) {
    final TextEditingController nameController = TextEditingController(text: item?['name'] ?? '');
    String selectedTxType = item?['transaction_type'] ?? 'expense';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              item == null
                  ? (AppLocalizations.of(context)?.addCategory ?? 'Tambah Kategori')
                  : (AppLocalizations.of(context)?.editCategory ?? 'Edit Kategori'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)?.categoryName ?? 'Nama Kategori',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  autofocus: true,
                ),
                if (item == null) ...[
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)?.transactionType ?? 'Jenis Transaksi', style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => selectedTxType = 'expense'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedTxType == 'expense' ? Colors.red.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: selectedTxType == 'expense' ? Colors.red.shade300 : Colors.transparent),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)?.expense ?? 'Pengeluaran',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: selectedTxType == 'expense' ? Colors.red.shade700 : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => selectedTxType = 'income'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedTxType == 'income' ? Colors.green.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: selectedTxType == 'income' ? Colors.green.shade300 : Colors.transparent),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)?.income ?? 'Pemasukan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: selectedTxType == 'income' ? Colors.green.shade700 : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                    final data = {'name': nameController.text.trim(), 'type': widget.activeMode, 'transaction_type': selectedTxType};
                    if (item == null) {
                      await DatabaseHelper.instance.insertCategory(data);
                    } else {
                      await DatabaseHelper.instance.updateCategory(item['id'], data);
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
        },
      ),
    );
  }

  Future<void> _deleteItem(String id, String name) async {
    if (name == 'Other') {
      TopToast.show(context, AppLocalizations.of(context)?.defaultCategoryError ?? 'Kategori default "Other" tidak dapat dihapus.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.deleteDataTitle ?? 'Hapus Data'),
        content: Text(AppLocalizations.of(context)?.confirmDeleteCategory ?? 'Apakah Anda yakin ingin menghapus kategori ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)?.cancel ?? 'Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context)?.delete ?? 'Hapus', style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteCategory(id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.transactionCategory ?? 'Kategori Transaksi', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)?.emptyCategory ?? 'Belum ada data kategori', style: TextStyle(color: Colors.grey.shade400)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = _categories[index];
                    final isOther = item['name'] == 'Other';
                    final txTypeStr = item['transaction_type'] == 'income'
                        ? (AppLocalizations.of(context)?.income ?? 'Pemasukan')
                        : (AppLocalizations.of(context)?.expense ?? 'Pengeluaran');
                    final badgeColor = item['transaction_type'] == 'income' ? Colors.green : Colors.red;

                    return ListTile(
                      title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(txTypeStr, style: TextStyle(fontSize: 12, color: badgeColor, fontWeight: FontWeight.bold)),
                      trailing: isOther
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                              child: Text(AppLocalizations.of(context)?.defaultLabel ?? 'Default', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showAddEditDialog(item: item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteItem(item['id'], item['name']),
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

// ============================================================================
// 4. BACKUP & RESTORE PAGE
// ============================================================================

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.backupRestoreTitle ?? 'Cadangan & Pemulihan Data', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 80, color: primaryColor),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.backupRestoreTitle ?? 'Cadangan & Pemulihan Data',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.backupRestoreDesc ?? 'Simpan data Anda ke file lokal agar bisa dipulihkan kembali nanti.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () async {
                final path = await BackupService.instance.exportData();
                if (path != null && mounted) {
                  TopToast.show(context, (AppLocalizations.of(context)?.successExport ?? 'Data Berhasil diekspor ke ') + path);
                }
              },
              icon: const Icon(Icons.upload_file),
              label: Text(AppLocalizations.of(context)?.exportJson ?? 'Ekspor Data ke JSON'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: primaryColor.withOpacity(0.1),
                foregroundColor: primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)?.confirmRestoreTitle ?? 'Konfirmasi Restore'),
                    content: Text(AppLocalizations.of(context)?.confirmRestoreWarning ?? 'PERHATIAN: Mengimpor data akan menghapus semua data saat ini dan menggantinya dengan isi file backup. Lanjutkan?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)?.cancel ?? 'Batal')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context)?.continueLabel ?? 'Lanjutkan', style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  final success = await BackupService.instance.importData();
                  if (success && mounted) {
                    TopToast.show(context, AppLocalizations.of(context)?.successImport ?? 'Data berhasil diimpor!');
                  }
                }
              },
              icon: const Icon(Icons.file_download),
              label: Text(AppLocalizations.of(context)?.importJson ?? 'Impor Data dari JSON'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.1),
                foregroundColor: Theme.of(context).primaryColorDark,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 5. WIDGET GUIDE PAGE
// ============================================================================

class WidgetGuidePage extends StatelessWidget {
  const WidgetGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.widgetGuideTitle ?? 'Panduan Pasang Widget', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.widgets, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)?.widgetHomeScreenTitle ?? 'Widget Home Screen WiroFin',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.widgetHomeScreenDesc ?? 'Pantau terus kesehatan finansial Anda tanpa harus membuka aplikasi.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)?.threeEasySteps ?? '3 Langkah Mudah Pemasangan',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            _buildStepCard(
              stepNumber: '1',
              title: AppLocalizations.of(context)?.widgetStep1Title ?? 'Pergi ke Layar Utama HP',
              description: AppLocalizations.of(context)?.widgetStep1Desc ?? 'Tutup atau minimalkan aplikasi WiroFin dan navigasikan ke layar utama (Home Screen) di HP Android atau iOS Anda.',
              icon: Icons.home_outlined,
            ),
            const SizedBox(height: 16),
            _buildStepCard(
              stepNumber: '2',
              title: AppLocalizations.of(context)?.widgetStep2Title ?? 'Tekan & Tahan Area Kosong',
              description: AppLocalizations.of(context)?.widgetStep2Desc ?? 'Tekan dan tahan (long press) pada area kosong di layar utama selama beberapa detik hingga muncul menu pengaturan layar atau pop-up menu.',
              icon: Icons.touch_app_outlined,
            ),
            const SizedBox(height: 16),
            _buildStepCard(
              stepNumber: '3',
              title: AppLocalizations.of(context)?.widgetStep3Title ?? 'Pilih & Seret Widget',
              description: AppLocalizations.of(context)?.widgetStep3Desc ?? 'Ketuk menu "Widget" (atau ikon +), gulir untuk mencari "WiroFin", lalu seret varian widget yang Anda inginkan ke layar utama.',
              icon: Icons.drag_indicator,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber.shade800),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)?.widgetTips ?? 'Tips: Widget WiroFin akan otomatis menyesuaikan warnanya sesuai mode (Personal/Company) saat aplikasi dibuka.',
                      style: TextStyle(fontSize: 13, color: Colors.amber.shade900, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({required String stepNumber, required String title, required String description, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(stepNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Text(description, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4)),
              ],
            ),
          ),
          Icon(icon, color: Colors.grey.shade400, size: 28),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. DEBUG TOOLS PAGE (UJI COBA & RESET STATUS)
// ============================================================================

class DebugToolsPage extends StatefulWidget {
  const DebugToolsPage({super.key});

  @override
  State<DebugToolsPage> createState() => _DebugToolsPageState();
}

class _DebugToolsPageState extends State<DebugToolsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Uji Coba & Reset Status', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Gunakan menu ini saat mode pengujian (testing/debugging) untuk mensimulasikan pembaruan versi atau mengulang notifikasi widget tanpa harus mengubah kode aplikasi.',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade900, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildDebugOption(
            icon: Icons.cloud_download_outlined,
            title: 'Simulasikan Popup Update Play Store (In-App Update)',
            subtitle: 'Munculkan seketika dialog simulasi saat terdeteksi versi baru di Google Play Store (meminta pengguna memperbarui aplikasi).',
            buttonText: 'Uji Play Store Update',
            buttonColor: Colors.purple.shade700,
            onTap: () {
              _simulatePlayStoreUpdateDialog(context);
            },
          ),
          const SizedBox(height: 16),
          _buildDebugOption(
            icon: Icons.widgets_outlined,
            title: 'Tampilkan Langsung Popup What\'s New',
            subtitle: 'Munculkan seketika pop-up dialog bergaya glassmorphism yang menginformasikan fitur baru widget WiroFin.',
            buttonText: 'Uji What\'s New',
            buttonColor: Colors.indigo.shade700,
            onTap: () {
              _simulateWhatsNewModal(context);
            },
          ),
          const SizedBox(height: 16),
          _buildDebugOption(
            icon: Icons.system_update_alt_outlined,
            title: 'Simulasikan Pembaruan Versi (Internal & Play Store)',
            subtitle: 'Reset versi tersimpan ke "dummy-v0.0.0" dan set versi Play Store ke "99.0.0" agar saat restart, sistem memicu popup versi baru otomatis.',
            buttonText: 'Reset Versi',
            buttonColor: Colors.blue.shade700,
            onTap: () async {
              await PreferenceService.instance.setLastSeenVersion('dummy-v0.0.0');
              await PreferenceService.instance.setForcedRemoteVersion('99.0.0');
              if (mounted) {
                TopToast.show(context, 'Versi berhasil direset! Restart aplikasi untuk memicu popup otomatis.');
              }
            },
          ),
          const SizedBox(height: 16),
          _buildDebugOption(
            icon: Icons.restore_page_outlined,
            title: 'Tampilkan Ulang Banner Widget di Dashboard',
            subtitle: 'Mengaktifkan kembali banner informasi widget berwarna biru/hijau di bagian atas halaman Dashboard.',
            buttonText: 'Tampilkan Banner',
            buttonColor: Colors.teal.shade700,
            onTap: () async {
              await PreferenceService.instance.setWidgetCardDismissed(false);
              if (mounted) {
                TopToast.show(context, 'Banner widget di Dashboard kembali diaktifkan!');
              }
            },
          ),
          const SizedBox(height: 16),
          _buildDebugOption(
            icon: Icons.notifications_active_outlined,
            title: 'Reset Pemicu Toast Transaksi Pertama',
            subtitle: 'Atur ulang status transaksi pertama. Buat 1 transaksi baru di Dashboard untuk melihat notifikasi ajakan pasang widget.',
            buttonText: 'Reset Transaksi',
            buttonColor: Colors.orange.shade700,
            onTap: () async {
              await PreferenceService.instance.setHasCreatedFirstTransaction(false);
              if (mounted) {
                TopToast.show(context, 'Status pemicu transaksi pertama direset!');
              }
            },
          ),
          const SizedBox(height: 16),
          _buildDebugOption(
            icon: Icons.refresh,
            title: 'Reset Semua Status Onboarding & Edukasi',
            subtitle: 'Kembalikan semua pengaturan edukasi dan pengenalan aplikasi ke kondisi awal (fresh install).',
            buttonText: 'Reset Semua',
            buttonColor: Colors.red.shade700,
            onTap: () async {
              await PreferenceService.instance.setFirstLaunch(true);
              await PreferenceService.instance.setLastSeenVersion('');
              await PreferenceService.instance.setForcedRemoteVersion('');
              await PreferenceService.instance.setWidgetCardDismissed(false);
              await PreferenceService.instance.setHasCreatedFirstTransaction(false);
              if (mounted) {
                TopToast.show(context, 'Seluruh status edukasi & onboarding berhasil direset ke awal!');
              }
            },
          ),
        ],
      ),
    );
  }

  void _simulatePlayStoreUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {},
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppLocalizations.of(context)?.updateAvailableTitle ?? 'Update Tersedia!', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            AppLocalizations.of(context)?.updateAvailableMessage ?? 'Versi terbaru WiroFin sudah tersedia di Play Store. Silakan update untuk melanjutkan menggunakan aplikasi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)?.exit ?? 'Tutup Simulasi', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                TopToast.show(context, 'Membuka link Google Play Store...');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(AppLocalizations.of(context)?.updateNow ?? 'Update Sekarang', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateWhatsNewModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.widgets_outlined, size: 56, color: Colors.white),
                          SizedBox(height: 12),
                          Text(
                            'WiroFin Widget',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Baru! Pantau keuangan langsung dari layar HP Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.3),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kini Anda dapat memasang widget WiroFin di beranda HP untuk melihat saldo dan mencatat transaksi secara instan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Tutup', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const WidgetGuidePage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cara Pasang', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebugOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: buttonColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: buttonColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
