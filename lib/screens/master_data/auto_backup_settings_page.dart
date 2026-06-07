import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auto_backup_service.dart';
import '../../widgets/top_toast.dart';

class AutoBackupSettingsPage extends StatefulWidget {
  const AutoBackupSettingsPage({super.key});

  @override
  State<AutoBackupSettingsPage> createState() => _AutoBackupSettingsPageState();
}

class _AutoBackupSettingsPageState extends State<AutoBackupSettingsPage> {
  bool _isEnabled = true;
  int _interval = 1;
  int _retention = 5;
  List<File> _backups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEnabled = prefs.getBool('auto_backup_enabled') ?? true;
      _interval = prefs.getInt('auto_backup_interval') ?? 1;
      _retention = prefs.getInt('auto_backup_retention') ?? 5;
    });
    await _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    final list = await AutoBackupService.instance.getLocalBackups();
    setState(() {
      _backups = list;
      _isLoading = false;
    });
  }

  Future<void> _toggleAutoBackup(bool value) async {
    final loc = AppLocalizations.of(context);
    if (!value) {
      // Show warning before disabling
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(loc?.deleteDataTitle ?? 'Peringatan'),
          content: Text(loc?.autoBackupDisableWarning ?? 'PERHATIAN: Menonaktifkan auto-backup berarti data Anda tidak akan dicadangkan secara otomatis dan berisiko hilang jika aplikasi terhapus.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(loc?.cancel ?? 'Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(loc?.continueLabel ?? 'Lanjutkan', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_backup_enabled', value);
    setState(() {
      _isEnabled = value;
    });
  }

  Future<void> _changeInterval(int? value) async {
    if (value == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('auto_backup_interval', value);
    setState(() {
      _interval = value;
    });
  }

  Future<void> _changeRetention(int? value) async {
    if (value == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('auto_backup_retention', value);
    setState(() {
      _retention = value;
    });
  }

  Future<void> _runBackupNow() async {
    final loc = AppLocalizations.of(context);
    final file = await AutoBackupService.instance.executeBackup();
    if (file != null) {
      TopToast.show(context, loc?.autoBackupSuccess ?? 'Backup otomatis berhasil dibuat');
      _loadBackups();
    } else {
      TopToast.show(context, loc?.autoBackupFailed ?? 'Gagal membuat backup otomatis');
    }
  }

  Future<void> _restoreBackup(File file) async {
    final loc = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(loc?.autoBackupConfirmRestoreTitle ?? 'Konfirmasi Restore'),
        content: Text(loc?.autoBackupConfirmRestoreWarning ?? 'Apakah Anda yakin ingin memulihkan file cadangan ini? Semua data saat ini akan ditimpa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc?.cancel ?? 'Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc?.continueLabel ?? 'Lanjutkan', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await AutoBackupService.instance.restoreFromLocalFile(file);
      if (success && mounted) {
        TopToast.show(context, loc?.autoBackupRestoreSuccess ?? 'Data berhasil dipulihkan!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.autoBackupSettingTitle ?? 'Pengaturan Auto-Backup', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Educational Notice Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc?.autoBackupNoticeTitle ?? 'Manajemen File Cadangan',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue.shade800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc?.autoBackupNoticeDesc ?? 'File cadangan disimpan secara offline di folder khusus \'wirofin_autobackups\'. Sistem akan otomatis menghapus file cadangan terlama jika jumlah file melebihi batas penumpukan.',
                          style: TextStyle(fontSize: 13, color: Colors.blue.shade700, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings options card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(loc?.autoBackupSwitch ?? 'Aktifkan Auto-Backup', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(loc?.autoBackupSwitchDesc ?? 'Cadangkan data secara otomatis ketika membuka aplikasi'),
                      value: _isEnabled,
                      onChanged: _toggleAutoBackup,
                      activeColor: Colors.blue,
                    ),
                    if (_isEnabled) ...[
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(loc?.autoBackupInterval ?? 'Interval Pencadangan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        trailing: DropdownButton<int>(
                          value: _interval,
                          items: [
                            DropdownMenuItem(value: 1, child: Text(loc?.autoBackupIntervalDaily ?? 'Setiap Hari')),
                            DropdownMenuItem(value: 7, child: Text(loc?.autoBackupIntervalWeekly ?? 'Setiap 7 Hari')),
                            DropdownMenuItem(value: 30, child: Text(loc?.autoBackupIntervalMonthly ?? 'Setiap 30 Hari')),
                          ],
                          onChanged: _changeInterval,
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(loc?.autoBackupMaxFiles ?? 'Batas Penumpukan Cadangan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(loc?.autoBackupMaxFilesDesc ?? 'Jumlah maksimal file cadangan yang disimpan di folder lokal sebelum file tertua dihapus (FIFO).'),
                        trailing: DropdownButton<int>(
                          value: _retention,
                          items: List.generate(6, (index) => index + 2).map((val) {
                            return DropdownMenuItem(value: val, child: Text('$val file'));
                          }).toList(),
                          onChanged: _changeRetention,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Backup Now Button
            ElevatedButton.icon(
              onPressed: _runBackupNow,
              icon: const Icon(Icons.backup),
              label: Text(loc?.autoBackupBtn ?? 'Cadangkan Sekarang'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 30),

            // Local Backups List Title
            Text(
              loc?.autoBackupFileHeading ?? 'File Cadangan Lokal',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // Backups List View
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _backups.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            loc?.autoBackupNoFiles ?? 'Tidak ada file cadangan lokal ditemukan',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _backups.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final file = _backups[index];
                          final filename = p.basename(file.path);
                          final sizeBytes = file.lengthSync();
                          final sizeKb = (sizeBytes / 1024).toStringAsFixed(1);
                          
                          // Format date from filename
                          String displayDate = '';
                          final match = RegExp(r'_(\d{8})\.json').firstMatch(filename);
                          if (match != null) {
                            final dateStr = match.group(1)!;
                            displayDate = '${dateStr.substring(6, 8)}-${dateStr.substring(4, 6)}-${dateStr.substring(0, 4)}';
                          }

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
                            title: Text(filename, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            subtitle: Text('$displayDate • $sizeKb KB', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.settings_backup_restore, color: Colors.green),
                              onPressed: () => _restoreBackup(file),
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
