import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../core/services/preference_service.dart';
import 'database_helper.dart';

class BackupService {
  static final BackupService instance = BackupService._();
  BackupService._();

  Future<String?> exportData() async {
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
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      // Save to a temporary file first
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/expense_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      // Use FilePicker to save it permanently via Storage Access Framework
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Pilih lokasi simpan backup',
        fileName: 'wirofin_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (outputFile != null) {
        return outputFile;
      }
      return file.path;
    } catch (e) {
      print('Export error: $e');
      return null;
    }
  }

  Future<bool> importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Request bytes for compatibility across storage frameworks
      );

      if (result == null || result.files.isEmpty) return false;

      final filePicked = result.files.single;
      String content;

      if (filePicked.path != null && File(filePicked.path!).existsSync()) {
        content = await File(filePicked.path!).readAsString();
      } else if (filePicked.bytes != null) {
        content = utf8.decode(filePicked.bytes!);
      } else {
        return false;
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(content);
      } catch (e) {
        print('JSON Corrupted or Invalid: $e');
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
          // Sanitize description
          if (exp['description'] != null) {
            exp['description'] = exp['description'].toString().trim();
          }
          await txn.insert('expenses', exp);
        }
      });

      // Ensure default income categories exist if the backup was from an older version
      await DatabaseHelper.instance.ensureDefaultCategoriesExist();

      return true;
    } catch (e) {
      print('Import error: $e');
      return false;
    }
  }
}
