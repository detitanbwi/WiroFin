import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  SyncService._init();

  bool _isSyncing = false;
  final _connectivity = Connectivity();
  VoidCallback? onSyncComplete; // Callback untuk refresh UI
  
  static const String baseUrl = 'http://192.168.18.51/autodocument/api';

  void init() {
    if (kIsWeb) return;
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        syncAll();
      }
    });
    syncAll();
  }

  Future<void> syncAll() async {
    if (kIsWeb) return;
    await fetchMasterData(); 
    await syncPendingData(); 
  }

  Future<void> fetchMasterData() async {
    try {
      final db = await DatabaseHelper.instance.database;      
      // Bersihkan data master lama (Account/Category) saja agar selalu update dari server
      await db.delete('accounts');
      await db.delete('categories');
      
      // Fetch Accounts
      final accRes = await http.get(Uri.parse('$baseUrl/tracker/accounts'));
      if (accRes.statusCode == 200) {
        List<dynamic> accounts = jsonDecode(accRes.body);
        print('Fetched ${accounts.length} accounts from server.');
        for (var acc in accounts) {
          await db.insert('accounts', {
            'id': acc['id'],
            'name': acc['name'],
            'type': acc['type'],
            'sync_status': 'synced'
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      final catRes = await http.get(Uri.parse('$baseUrl/tracker/categories'));
      if (catRes.statusCode == 200) {
        List<dynamic> categories = jsonDecode(catRes.body);
        print('Fetched ${categories.length} categories from server.');
        for (var cat in categories) {
          await db.insert('categories', {
            'id': cat['id'],
            'name': cat['name'],
            'type': cat['type'],
            'transaction_type': cat['transaction_type'] ?? 'expense',
            'sync_status': 'synced'
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      
      // Pastikan kategori default (Other dan Income) tetap ada setelah reset
      await DatabaseHelper.instance.ensureDefaultCategoriesExist();
    } catch (e) {
      print('Fetch Master Data Error: $e');
    }
  }

  Future<void> syncPendingData() async {
    if (_isSyncing) return;
    
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return;

    _isSyncing = true;

    try {
      final db = await DatabaseHelper.instance.database;
      final pendingExpenses = await db.query('expenses', where: 'sync_status = ?', whereArgs: ['pending']);

      if (pendingExpenses.isEmpty) {
        _isSyncing = false;
        return;
      }

      // MARK AS SYNCING
      for (var expense in pendingExpenses) {
        await db.update('expenses', {'sync_status': 'syncing'}, where: 'id = ?', whereArgs: [expense['id']]);
      }

      final syncData = {
        'expenses': pendingExpenses.map((e) => {
          'id': e['id'],
          'account_id': e['account_id'],
          'category_id': e['category_id'],
          'type': e['type'],
          'transaction_type': e['transaction_type'],
          'amount': e['amount'],
          'expense_date': e['date'],
          'description': e['description'],
        }).toList(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/tracker/expenses/sync'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(syncData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        for (var expense in pendingExpenses) {
          await db.update(
            'expenses',
            {'sync_status': 'synced'},
            where: 'id = ?',
            whereArgs: [expense['id']],
          );
        }
        print('Sync Success: ${pendingExpenses.length} records updated.');
        onSyncComplete?.call(); // Beritahu UI untuk refresh
      } else {
        // REVERT TO PENDING IF FAILED
        for (var expense in pendingExpenses) {
          await db.update('expenses', {'sync_status': 'pending'}, where: 'id = ?', whereArgs: [expense['id']]);
        }
        print('Sync Failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // REVERT TO PENDING ON ERROR
      print('Sync Exception: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
