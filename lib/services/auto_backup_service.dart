import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/preference_service.dart';
import 'database_helper.dart';

class AutoBackupService {
  static final AutoBackupService instance = AutoBackupService._();
  AutoBackupService._();

  Future<Directory> getBackupDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    final backupPath = p.join(docDir.path, 'wirofin_autobackups');
    final directory = Directory(backupPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<void> checkAndExecuteBackup() async {
    if (kIsWeb) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Auto backup default is true
      final bool isEnabled = prefs.getBool('auto_backup_enabled') ?? true;
      if (!isEnabled) return;

      final int intervalDays = prefs.getInt('auto_backup_interval') ?? 1;
      final String? lastBackupStr = prefs.getString('last_autobackup_date');

      final now = DateTime.now();
      bool shouldBackup = false;

      if (lastBackupStr == null) {
        shouldBackup = true;
      } else {
        try {
          final lastBackupDate = DateTime.parse(lastBackupStr);
          final difference = now.difference(lastBackupDate).inDays;
          if (difference >= intervalDays) {
            shouldBackup = true;
          }
        } catch (_) {
          shouldBackup = true;
        }
      }

      if (shouldBackup) {
        await executeBackup();
        // Save today's date in YYYY-MM-DD format
        final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        await prefs.setString('last_autobackup_date', todayStr);
      }
    } catch (e) {
      debugPrint('Auto-backup trigger check failed: $e');
    }
  }

  Future<File?> executeBackup() async {
    if (kIsWeb) return null;
    try {
      final db = DatabaseHelper.instance;
      final transactions = await db.queryAll('expenses');
      final accounts = await db.queryAll('accounts');
      final categories = await db.queryAll('categories');

      final backupData = {
        'version': 2,
        'timestamp': DateTime.now().toIso8601String(),
        'preferences': PreferenceService.instance.exportPreferences(),
        'expenses': transactions,
        'accounts': accounts,
        'categories': categories,
      };

      final jsonString = jsonEncode(backupData);
      final backupDir = await getBackupDirectory();

      final now = DateTime.now();
      final dateStr = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
      final fileName = 'wirofin_auto_v120_$dateStr.json';
      final file = File(p.join(backupDir.path, fileName));

      await file.writeAsString(jsonString);

      // Perform FIFO rotation
      await rotateBackups();

      return file;
    } catch (e) {
      debugPrint('Auto-backup execution failed: $e');
      return null;
    }
  }

  Future<void> rotateBackups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int retentionLimit = prefs.getInt('auto_backup_retention') ?? 5;
      
      final backupDir = await getBackupDirectory();
      final List<FileSystemEntity> entities = await backupDir.list().toList();
      
      // Filter only JSON backup files matching our pattern
      final List<File> backupFiles = entities
          .whereType<File>()
          .where((file) => p.basename(file.path).startsWith('wirofin_auto_v120_') && p.basename(file.path).endsWith('.json'))
          .toList();

      // Sort ascending by filename (which naturally sorts by date timestamp)
      backupFiles.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

      while (backupFiles.length > retentionLimit) {
        final fileToDelete = backupFiles.first;
        if (await fileToDelete.exists()) {
          await fileToDelete.delete();
        }
        backupFiles.removeAt(0);
      }
    } catch (e) {
      debugPrint('Auto-backup rotation failed: $e');
    }
  }

  Future<List<File>> getLocalBackups() async {
    if (kIsWeb) return [];
    try {
      final backupDir = await getBackupDirectory();
      final List<FileSystemEntity> entities = await backupDir.list().toList();
      final List<File> backupFiles = entities
          .whereType<File>()
          .where((file) => p.basename(file.path).startsWith('wirofin_auto_v120_') && p.basename(file.path).endsWith('.json'))
          .toList();

      // Sort descending (latest first)
      backupFiles.sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
      return backupFiles;
    } catch (e) {
      debugPrint('Failed to list local backups: $e');
      return [];
    }
  }

  Future<bool> restoreFromLocalFile(File file) async {
    if (kIsWeb) return false;
    try {
      if (!await file.exists()) return false;
      final content = await file.readAsString();

      Map<String, dynamic> data;
      try {
        data = jsonDecode(content);
      } catch (e) {
        debugPrint('JSON Corrupted or Invalid: $e');
        return false;
      }

      if (data['expenses'] is! List || data['accounts'] is! List || data['categories'] is! List) {
        return false;
      }

      if (data['preferences'] is Map<String, dynamic>) {
        await PreferenceService.instance.importPreferences(data['preferences'] as Map<String, dynamic>);
      }

      final db = await DatabaseHelper.instance.database;

      await db.transaction((txn) async {
        // Clear existing data before restoring
        await txn.delete('expenses');
        await txn.delete('accounts');
        await txn.delete('categories');

        for (var item in data['accounts']) {
          final acc = Map<String, dynamic>.from(item);
          await txn.insert('accounts', acc);
        }
        for (var item in data['categories']) {
          final cat = Map<String, dynamic>.from(item);
          cat['transaction_type'] ??= 'expense';
          await txn.insert('categories', cat);
        }
        for (var item in data['expenses']) {
          final exp = Map<String, dynamic>.from(item);
          exp['transaction_type'] ??= 'expense';
          if (exp['description'] != null) {
            exp['description'] = exp['description'].toString().trim();
          }
          await txn.insert('expenses', exp);
        }
      });

      // Ensure default income categories exist
      await DatabaseHelper.instance.ensureDefaultCategoriesExist();

      return true;
    } catch (e) {
      debugPrint('Local restore error: $e');
      return false;
    }
  }
}
