import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../services/backup_service.dart';
import '../../services/auto_backup_service.dart';
import '../../widgets/top_toast.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  // Auto-backup states
  bool _isAutoEnabled = true;
  int _interval = 1;
  int _retention = 5;
  List<File> _localBackups = [];
  bool _isLoadingLocal = true;

  @override
  void initState() {
    super.initState();
    _loadAutoBackupSettings();
  }

  Future<void> _loadAutoBackupSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAutoEnabled = prefs.getBool('auto_backup_enabled') ?? true;
      _interval = prefs.getInt('auto_backup_interval') ?? 1;
      _retention = prefs.getInt('auto_backup_retention') ?? 5;
    });
    await _loadLocalBackups();
  }

  Future<void> _loadLocalBackups() async {
    setState(() => _isLoadingLocal = true);
    final list = await AutoBackupService.instance.getLocalBackups();
    setState(() {
      _localBackups = list;
      _isLoadingLocal = false;
    });
  }

  Future<void> _toggleAutoBackup(bool value) async {
    final loc = AppLocalizations.of(context);
    if (!value) {
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
      _isAutoEnabled = value;
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
      _loadLocalBackups();
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
    final primaryColor = Theme.of(context).primaryColor;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(loc?.backupRestoreTitle ?? 'Cadangan & Pemulihan Data', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner/Notice Card
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
                  Icon(Icons.security, color: Colors.blue.shade700, size: 28),
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
                          loc?.autoBackupNoticeDesc ?? 'File cadangan Anda disimpan secara offline di folder khusus \'wirofin_autobackups\' atau dapat diekspor secara manual ke format JSON/Excel.',
                          style: TextStyle(fontSize: 13, color: Colors.blue.shade700, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SECTION 1: AUTO-BACKUP SETTINGS
            Text(
              loc?.autoBackupSettingTitle ?? 'Pengaturan Auto-Backup',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(loc?.autoBackupSwitch ?? 'Aktifkan Auto-Backup', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Text(loc?.autoBackupSwitchDesc ?? 'Cadangkan data secara otomatis ketika membuka aplikasi'),
                      value: _isAutoEnabled,
                      onChanged: _toggleAutoBackup,
                      activeColor: Colors.blue,
                    ),
                    if (_isAutoEnabled) ...[
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(loc?.autoBackupInterval ?? 'Interval Pencadangan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                        title: Text(loc?.autoBackupMaxFiles ?? 'Batas Penumpukan Cadangan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
            const SizedBox(height: 24),

            // SECTION 2: MANUAL EXPORT & IMPORT
            Text(
              'Ekspor & Impor Manual',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [


                    ElevatedButton.icon(
                      onPressed: () async {
                        final path = await BackupService.instance.exportExcelData();
                        if (path != null && mounted) {
                          TopToast.show(context, '${loc?.successExport ?? "Data Berhasil diekspor ke "} $path');
                        }
                      },
                      icon: const Icon(Icons.table_chart),
                      label: Text(loc?.exportExcel ?? 'Ekspor Data ke Excel'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.green.shade50,
                        foregroundColor: Colors.green.shade700,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final path = await BackupService.instance.exportData();
                        if (path != null && mounted) {
                          TopToast.show(context, '${loc?.successExport ?? "Data Berhasil diekspor ke "} $path');
                        }
                      },
                      icon: const Icon(Icons.code),
                      label: Text(loc?.exportJson ?? 'Ekspor Data ke JSON'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade700,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(loc?.confirmRestoreTitle ?? 'Konfirmasi Restore'),
                            content: Text(loc?.confirmRestoreWarning ?? 'PERHATIAN: Mengimpor data akan menghapus semua data saat ini dan menggantinya dengan isi file backup. Lanjutkan?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc?.cancel ?? 'Batal')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: Text(loc?.continueLabel ?? 'Lanjutkan', style: const TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        
                        if (confirmed == true) {
                          final success = await BackupService.instance.importData();
                          if (success && mounted) {
                            TopToast.show(context, loc?.successImport ?? 'Data berhasil diimpor!');
                          }
                        }
                      },
                      icon: const Icon(Icons.file_download),
                      label: Text(loc?.importJson ?? 'Impor Data dari JSON'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.08),
                        foregroundColor: Theme.of(context).primaryColorDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // SECTION 3: LOCAL BACKUPS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    loc?.autoBackupFileHeading ?? 'File Cadangan Lokal',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _runBackupNow,
                  icon: const Icon(Icons.backup, size: 16),
                  label: const Text('Cadangkan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _isLoadingLocal
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _localBackups.isEmpty
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
                            itemCount: _localBackups.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final file = _localBackups[index];
                              final filename = p.basename(file.path);
                              final sizeBytes = file.lengthSync();
                              final sizeKb = (sizeBytes / 1024).toStringAsFixed(1);
                              
                              String displayDate = '';
                              final match = RegExp(r'_(\d{8})\.json').firstMatch(filename);
                              if (match != null) {
                                final dateStr = match.group(1)!;
                                displayDate = '${dateStr.substring(6, 8)}-${dateStr.substring(4, 6)}-${dateStr.substring(0, 4)}';
                              }

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
                                title: Text(filename, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                subtitle: Text('$displayDate • $sizeKb KB', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.settings_backup_restore, color: Colors.green),
                                  onPressed: () => _restoreBackup(file),
                                  tooltip: 'Pulihkan Versi Ini',
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
