import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // In-memory data untuk Web / Chrome preview
  static final List<Map<String, dynamic>> _webExpenses = [];
  static final List<Map<String, dynamic>> _webCategories = [];
  static final List<Map<String, dynamic>> _webAccounts = [];
  static bool _webInitialized = false;

  void _initWebData() {
    if (_webInitialized) return;
    final uuid = const Uuid();
    
    // Add default accounts
    for (var type in ['personal', 'company']) {
      _webAccounts.add({
        'id': uuid.v4(),
        'name': 'Tunai',
        'type': type,
        'balance': 22223,
        'sync_status': 'synced',
      });
    }

    // Add default categories
    for (var type in ['personal', 'company']) {
      for (var txType in ['expense', 'income']) {
        _webCategories.add({
          'id': uuid.v4(),
          'name': 'Other',
          'type': type,
          'transaction_type': txType,
          'sync_status': 'synced',
        });
      }
    }

    final defaultExpenseCats = ['Food & Drink', 'Transportation'];
    for (var type in ['personal', 'company']) {
      for (var name in defaultExpenseCats) {
        _webCategories.add({
          'id': uuid.v4(),
          'name': name,
          'type': type,
          'transaction_type': 'expense',
          'sync_status': 'synced',
        });
      }
    }

    final personalIncomeCats = ['Gaji', 'Freelance', 'Investasi'];
    for (var name in personalIncomeCats) {
      _webCategories.add({
        'id': uuid.v4(),
        'name': name,
        'type': 'personal',
        'transaction_type': 'income',
        'sync_status': 'synced',
      });
    }

    final companyIncomeCats = ['Proyek', 'Retainer', 'Penjualan Lisensi'];
    for (var name in companyIncomeCats) {
      _webCategories.add({
        'id': uuid.v4(),
        'name': name,
        'type': 'company',
        'transaction_type': 'income',
        'sync_status': 'synced',
      });
    }

    // Pre-populate some dummy transactions
    final tunaiPersonal = _webAccounts.firstWhere((a) => a['type'] == 'personal')['id'];
    final foodPersonal = _webCategories.firstWhere((c) => c['name'] == 'Food & Drink' && c['type'] == 'personal')['id'];
    final transPersonal = _webCategories.firstWhere((c) => c['name'] == 'Transportation' && c['type'] == 'personal')['id'];
    
    _webExpenses.addAll([
      {
        'id': uuid.v4(),
        'amount': 25000,
        'description': 'Makan Siang',
        'category_id': foodPersonal,
        'account_id': tunaiPersonal,
        'date': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'type': 'personal',
        'transaction_type': 'expense',
        'sync_status': 'synced',
      },
      {
        'id': uuid.v4(),
        'amount': 15000,
        'description': 'Ojek Online',
        'category_id': transPersonal,
        'account_id': tunaiPersonal,
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'type': 'personal',
        'transaction_type': 'expense',
        'sync_status': 'synced',
      },
    ]);

    _webInitialized = true;
  }

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError("SQLite native is not supported on Web. Methods are intercepted.");
    }
    if (_database != null) return _database!;
    _database = await _initDB('wiro_expense.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
    await _ensureOtherCategoryExists(db);
    await _ensureDefaultExpenseCategoriesExist(db);
    await _ensureDefaultIncomeCategoriesExist(db);
    return db;
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE accounts ADD COLUMN balance INTEGER NOT NULL DEFAULT 0;");
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE categories ADD COLUMN transaction_type TEXT NOT NULL DEFAULT 'expense';");
      await db.execute("ALTER TABLE expenses ADD COLUMN transaction_type TEXT NOT NULL DEFAULT 'expense';");
    }
    if (oldVersion < 4) {
      await db.execute("ALTER TABLE accounts ADD COLUMN linked_package TEXT;");
    }
  }

  Future<void> ensureDefaultCategoriesExist() async {
    final db = await database;
    await _ensureOtherCategoryExists(db);
    await _ensureDefaultExpenseCategoriesExist(db);
    await _ensureDefaultIncomeCategoriesExist(db);
    await _ensureDefaultAccountsExist(db);
  }

  Future<void> _ensureDefaultAccountsExist(Database db) async {
    final uuid = const Uuid();
    for (var type in ['personal', 'company']) {
      final res = await db.query(
        'accounts',
        where: 'type = ?',
        whereArgs: [type],
      );
      if (res.isEmpty) {
        await db.insert('accounts', {
          'id': uuid.v4(),
          'name': 'Tunai',
          'type': type,
          'balance': 0,
          'sync_status': 'synced',
        });
      }
    }
  }

  Future<void> _ensureOtherCategoryExists(Database db) async {
    final uuid = const Uuid();
    for (var type in ['personal', 'company']) {
      for (var txType in ['expense', 'income']) {
        final List<Map<String, dynamic>> maps = await db.query(
          'categories',
          where: 'name = ? AND type = ? AND transaction_type = ?',
          whereArgs: ['Other', type, txType],
        );
        if (maps.isEmpty) {
          await db.insert('categories', {
            'id': uuid.v4(),
            'name': 'Other',
            'type': type,
            'transaction_type': txType,
            'sync_status': 'synced'
          });
        }
      }
    }
  }

  Future<void> _ensureDefaultExpenseCategoriesExist(Database db) async {
    final uuid = const Uuid();
    final defaultExpenseCats = ['Food & Drink', 'Transportation'];

    for (var type in ['personal', 'company']) {
      for (var name in defaultExpenseCats) {
        final res = await db.query(
          'categories',
          where: 'name = ? AND type = ? AND transaction_type = ?',
          whereArgs: [name, type, 'expense'],
        );
        if (res.isEmpty) {
          await db.insert('categories', {
            'id': uuid.v4(),
            'name': name,
            'type': type,
            'transaction_type': 'expense',
            'sync_status': 'synced',
          });
        }
      }
    }
  }

  Future<void> _ensureDefaultIncomeCategoriesExist(Database db) async {
    final uuid = const Uuid();
    final personalIncomeCats = ['Gaji', 'Freelance', 'Investasi'];
    final companyIncomeCats = ['Proyek', 'Retainer', 'Penjualan Lisensi'];

    for (var name in personalIncomeCats) {
      final res = await db.query('categories', where: 'name = ? AND type = ? AND transaction_type = ?', whereArgs: [name, 'personal', 'income']);
      if (res.isEmpty) {
        await db.insert('categories', {
          'id': uuid.v4(),
          'name': name,
          'type': 'personal',
          'transaction_type': 'income',
          'sync_status': 'synced',
        });
      }
    }

    for (var name in companyIncomeCats) {
      final res = await db.query('categories', where: 'name = ? AND type = ? AND transaction_type = ?', whereArgs: [name, 'company', 'income']);
      if (res.isEmpty) {
        await db.insert('categories', {
          'id': uuid.v4(),
          'name': name,
          'type': 'company',
          'transaction_type': 'income',
          'sync_status': 'synced',
        });
      }
    }
  }

  Future _createDB(Database db, int version) async {
    const uuidType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE accounts (
        id $uuidType,
        name $textType,
        type $textType, -- 'personal' or 'company'
        balance INTEGER NOT NULL DEFAULT 0,
        linked_package TEXT,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id $uuidType,
        name $textType,
        type $textType, -- 'personal' or 'company'
        transaction_type TEXT NOT NULL DEFAULT 'expense',
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id $uuidType,
        amount $integerType,
        description TEXT,
        category_id TEXT,
        account_id TEXT,
        date $textType,
        type $textType, -- 'personal' or 'company'
        transaction_type TEXT NOT NULL DEFAULT 'expense',
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (category_id) REFERENCES categories (id),
        FOREIGN KEY (account_id) REFERENCES accounts (id)
      )
    ''');

    // Pre-populate data dihapus agar tidak bentrok dengan data server
  }

  // Generic Query
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    if (kIsWeb) {
      _initWebData();
      if (table == 'expenses') return List<Map<String, dynamic>>.from(_webExpenses);
      if (table == 'accounts') return List<Map<String, dynamic>>.from(_webAccounts);
      if (table == 'categories') return List<Map<String, dynamic>>.from(_webCategories);
      return [];
    }
    final db = await instance.database;
    return await db.query(table);
  }

  // Get Expenses with joins
  Future<List<Map<String, dynamic>>> getExpensesWithDetails({String? type, String? transactionType, DateTime? startDate, DateTime? endDate}) async {
    if (kIsWeb) {
      _initWebData();
      List<Map<String, dynamic>> results = [];
      for (var e in _webExpenses) {
        if (type != null && e['type'] != type) continue;
        if (transactionType != null && e['transaction_type'] != transactionType) continue;
        if (startDate != null && DateTime.parse(e['date'] as String).isBefore(startDate)) continue;
        if (endDate != null && DateTime.parse(e['date'] as String).isAfter(endDate)) continue;

        var cat = _webCategories.firstWhere((c) => c['id'] == e['category_id'], orElse: () => {'name': 'Unknown'});
        var acc = _webAccounts.firstWhere((a) => a['id'] == e['account_id'], orElse: () => {'name': 'Unknown'});

        results.add({
          ...e,
          'category': cat['name'],
          'account': acc['name'],
        });
      }
      results.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
      return results;
    }
    final db = await instance.database;
    List<String> conditions = [];
    if (type != null) conditions.add("e.type = '$type'");
    if (transactionType != null) conditions.add("e.transaction_type = '$transactionType'");
    if (startDate != null) conditions.add("e.date >= '${startDate.toIso8601String()}'");
    if (endDate != null) conditions.add("e.date <= '${endDate.toIso8601String()}'");
    
    String whereClause = conditions.isNotEmpty ? "WHERE ${conditions.join(' AND ')}" : "";
    
    return await db.rawQuery('''
      SELECT e.*, c.name as category, a.name as account
      FROM expenses e
      LEFT JOIN categories c ON e.category_id = c.id
      LEFT JOIN accounts a ON e.account_id = a.id
      $whereClause
      ORDER BY date DESC
    ''');
  }

  // Insert Expense
  Future<String> insertExpense(Map<String, dynamic> data) async {
    if (kIsWeb) {
      _initWebData();
      final id = const Uuid().v4();
      _webExpenses.add({
        'transaction_type': 'expense',
        ...data,
        'id': id,
        'sync_status': 'pending',
      });
      return id;
    }
    final db = await instance.database;
    final id = const Uuid().v4();
    await db.insert('expenses', {
      'transaction_type': 'expense',
      ...data,
      'id': id,
      'sync_status': 'pending',
    });
    return id;
  }

  // Update Expense
  Future<int> updateExpense(String id, Map<String, dynamic> data) async {
    if (kIsWeb) {
      _initWebData();
      final index = _webExpenses.indexWhere((e) => e['id'] == id);
      if (index != -1) {
        _webExpenses[index] = {
          ..._webExpenses[index],
          ...data,
          'sync_status': 'pending',
        };
        return 1;
      }
      return 0;
    }
    final db = await instance.database;
    return await db.update(
      'expenses',
      {...data, 'sync_status': 'pending'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete Expense
  Future<int> deleteExpense(String id) async {
    if (kIsWeb) {
      _initWebData();
      final before = _webExpenses.length;
      _webExpenses.removeWhere((e) => e['id'] == id);
      return before - _webExpenses.length;
    }
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get categories and accounts for a specific type
  Future<List<Map<String, dynamic>>> getCategories(String type, {String? transactionType}) async {
    if (kIsWeb) {
      _initWebData();
      final seen = <String>{};
      final list = _webCategories.where((c) => c['type'] == type).toList();
      final unique = <Map<String, dynamic>>[];
      for (var c in list) {
        if (seen.add(c['name'] as String)) {
          unique.add(c);
        }
      }
      return unique;
    }
    final db = await instance.database;
    // We ignore transactionType now because categories are general and apply to both income/expense
    return await db.query('categories', where: 'type = ?', whereArgs: [type], groupBy: 'name');
  }

  Future<List<Map<String, dynamic>>> getAccounts(String type) async {
    if (kIsWeb) {
      _initWebData();
      return _webAccounts.where((a) => a['type'] == type).toList();
    }
    final db = await instance.database;
    final res = await db.query('accounts', where: 'type = ?', whereArgs: [type]);
    if (res.isEmpty) {
      await _ensureDefaultAccountsExist(db);
      return await db.query('accounts', where: 'type = ?', whereArgs: [type]);
    }
    return res;
  }

  // Master Data CRUD
  Future<String> insertAccount(Map<String, dynamic> data) async {
    if (kIsWeb) {
      _initWebData();
      final id = const Uuid().v4();
      _webAccounts.add({
        ...data,
        'id': id,
        'sync_status': 'pending',
      });
      return id;
    }
    final db = await instance.database;
    final id = const Uuid().v4();
    await db.insert('accounts', {
      ...data,
      'id': id,
      'sync_status': 'pending',
    });
    return id;
  }

  Future<int> updateAccount(String id, Map<String, dynamic> data) async {
    if (kIsWeb) {
      _initWebData();
      final index = _webAccounts.indexWhere((a) => a['id'] == id);
      if (index != -1) {
        _webAccounts[index] = {
          ..._webAccounts[index],
          ...data,
          'sync_status': 'pending',
        };
        return 1;
      }
      return 0;
    }
    final db = await instance.database;
    return await db.update(
      'accounts',
      {...data, 'sync_status': 'pending'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAccount(String id) async {
    if (kIsWeb) {
      _initWebData();
      final before = _webAccounts.length;
      _webAccounts.removeWhere((a) => a['id'] == id);
      return before - _webAccounts.length;
    }
    final db = await instance.database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<String> insertCategory(Map<String, dynamic> data) async {
    if (kIsWeb) {
      _initWebData();
      final id = const Uuid().v4();
      _webCategories.add({
        'transaction_type': 'expense',
        ...data,
        'id': id,
        'sync_status': 'pending',
      });
      return id;
    }
    final db = await instance.database;
    final id = const Uuid().v4();
    await db.insert('categories', {
      'transaction_type': 'expense',
      ...data,
      'id': id,
      'sync_status': 'pending',
    });
    return id;
  }

  Future<int> updateCategory(String id, Map<String, dynamic> data) async {
    if (kIsWeb) {
      _initWebData();
      final index = _webCategories.indexWhere((c) => c['id'] == id);
      if (index != -1) {
        _webCategories[index] = {
          ..._webCategories[index],
          ...data,
          'sync_status': 'pending',
        };
        return 1;
      }
      return 0;
    }
    final db = await instance.database;
    return await db.update(
      'categories',
      {...data, 'sync_status': 'pending'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCategory(String id) async {
    if (kIsWeb) {
      _initWebData();
      final index = _webCategories.indexWhere((c) => c['id'] == id);
      if (index == -1) return 0;
      final cat = _webCategories[index];
      if (cat['name'] == 'Other') return 0;

      final type = cat['type'] as String;
      final txType = cat['transaction_type'] as String;

      final otherCat = _webCategories.firstWhere(
        (c) => c['name'] == 'Other' && c['type'] == type && c['transaction_type'] == txType,
        orElse: () => <String, dynamic>{},
      );

      if (otherCat.isNotEmpty) {
        final otherId = otherCat['id'] as String;
        for (var i = 0; i < _webExpenses.length; i++) {
          if (_webExpenses[i]['category_id'] == id) {
            _webExpenses[i] = {
              ..._webExpenses[i],
              'category_id': otherId,
              'sync_status': 'pending',
            };
          }
        }
      }

      _webCategories.removeAt(index);
      return 1;
    }
    final db = await instance.database;
    final cats = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (cats.isEmpty) return 0;
    
    final cat = cats.first;
    final type = cat['type'] as String;
    final txType = cat['transaction_type'] as String;

    if (cat['name'] == 'Other') return 0;

    final others = await db.query(
      'categories',
      where: 'name = ? AND type = ? AND transaction_type = ?',
      whereArgs: ['Other', type, txType],
    );

    if (others.isNotEmpty) {
      final otherId = others.first['id'] as String;
      await db.update(
        'expenses',
        {'category_id': otherId, 'sync_status': 'pending'},
        where: 'category_id = ?',
        whereArgs: [id],
      );
    }

    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Statistics Queries
  Future<List<Map<String, dynamic>>> getCategoryExpenses(String type, {String? transactionType, DateTime? startDate, DateTime? endDate}) async {
    if (kIsWeb) {
      _initWebData();
      final Map<String, int> totals = {};
      for (var e in _webExpenses) {
        if (e['type'] != type) continue;
        if (transactionType != null && e['transaction_type'] != transactionType) continue;
        if (startDate != null && DateTime.parse(e['date'] as String).isBefore(startDate)) continue;
        if (endDate != null && DateTime.parse(e['date'] as String).isAfter(endDate)) continue;

        final cat = _webCategories.firstWhere((c) => c['id'] == e['category_id'], orElse: () => {'name': 'Unknown'});
        final catName = cat['name'] as String;
        final amount = e['amount'] as int;
        totals[catName] = (totals[catName] ?? 0) + amount;
      }
      return totals.entries.map((entry) => {'category': entry.key, 'total': entry.value}).toList();
    }
    final db = await instance.database;
    List<String> conditions = ["e.type = ?"];
    List<dynamic> args = [type];
    
    if (transactionType != null) {
      conditions.add("e.transaction_type = ?");
      args.add(transactionType);
    }
    if (startDate != null) {
      conditions.add("e.date >= ?");
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      conditions.add("e.date <= ?");
      args.add(endDate.toIso8601String());
    }

    return await db.rawQuery('''
      SELECT c.name as category, SUM(e.amount) as total
      FROM expenses e
      JOIN categories c ON e.category_id = c.id
      WHERE ${conditions.join(' AND ')}
      GROUP BY c.id
    ''', args);
  }

  Future<List<Map<String, dynamic>>> getDailyExpensesTrend(String type, {String? transactionType, DateTime? startDate, DateTime? endDate}) async {
    if (kIsWeb) {
      _initWebData();
      final Map<String, int> dailyTotals = {};
      for (var e in _webExpenses) {
        if (e['type'] != type) continue;
        if (transactionType != null && e['transaction_type'] != transactionType) continue;
        if (startDate != null && DateTime.parse(e['date'] as String).isBefore(startDate)) continue;
        if (endDate != null && DateTime.parse(e['date'] as String).isAfter(endDate)) continue;

        final dateStr = e['date'].toString().substring(0, 10);
        final amount = e['amount'] as int;
        dailyTotals[dateStr] = (dailyTotals[dateStr] ?? 0) + amount;
      }
      final list = dailyTotals.entries.map((entry) => {'day': entry.key, 'total': entry.value}).toList();
      list.sort((a, b) => (a['day'] as String).compareTo(b['day'] as String));
      if (startDate == null && endDate == null && list.length > 7) {
        return list.sublist(list.length - 7);
      }
      return list;
    }
    final db = await instance.database;
    List<String> conditions = ["type = ?"];
    List<dynamic> args = [type];
    
    if (transactionType != null) {
      conditions.add("transaction_type = ?");
      args.add(transactionType);
    }
    if (startDate != null) {
      conditions.add("date >= ?");
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      conditions.add("date <= ?");
      args.add(endDate.toIso8601String());
    }

    String limitClause = (startDate == null && endDate == null) ? "LIMIT 7" : "";

    return await db.rawQuery('''
      SELECT strftime('%Y-%m-%d', date) as day, SUM(amount) as total
      FROM expenses
      WHERE ${conditions.join(' AND ')}
      GROUP BY day
      ORDER BY day ASC
      $limitClause
    ''', args);
  }
}
