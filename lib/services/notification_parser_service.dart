import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';
import '../core/services/preference_service.dart';

class NotificationParserService {
  static final NotificationParserService instance = NotificationParserService._init();
  NotificationParserService._init();

  String? getAppKey(String packageName) {
    switch (packageName) {
      case 'com.bca':
        return 'bca_mobile';
      case 'com.bca.mybca':
      case 'com.bca.mybca.omni.android':
        return 'mybca';
      case 'com.bcadigital.blu':
        return 'blu';
      case 'id.co.bri.brimo':
        return 'brimo';
      case 'id.bmri.livin':
        return 'livin';
      case 'id.bni.wondr':
      case 'com.mediasoft.bni':
        return 'bni';
      case 'com.jago.digitalBanking':
        return 'jago';
      case 'com.alloapp.yump':
        return 'allobank';
      case 'id.co.btn.mobilebanking.android':
        return 'btn';
      case 'com.btpn.dc':
        return 'jenius';
      case 'id.dana':
        return 'dana';
      case 'com.krom.android':
        return 'krom';
      case 'id.co.bankbkemobile.digitalbank':
        return 'seabank';
      default:
        return null;
    }
  }

  static const MethodChannel _channel = MethodChannel('com.wirodev.wirofin/auto_track');

  bool _isListening = false;
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      try {
        listener();
      } catch (e) {
        print("WiroFin NotificationParserService: Error notifying listener: $e");
      }
    }
  }

  void init() {
    if (_isListening) return;
    _isListening = true;
    print("WiroFin NotificationParserService: Initialized MethodChannel listener");
    _channel.setMethodCallHandler((call) async {
      print("WiroFin NotificationParserService: Received channel call ${call.method}");
      if (call.method == 'onNotification') {
        final Map<dynamic, dynamic>? args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final String packageName = args['package']?.toString() ?? '';
          final String title = args['title']?.toString() ?? '';
          final String text = args['text']?.toString() ?? '';
          print("WiroFin NotificationParserService: Notification args: pkg=$packageName, title=$title, text=$text");
          await processNotification(packageName, title, text);
        }
      }
    });
  }

  Future<void> processNotification(String packageName, String title, String text) async {
    print("WiroFin NotificationParserService: Processing: $packageName, title=$title, text=$text");
    // Check if auto-track feature is globally enabled in settings
    final prefs = await SharedPreferences.getInstance();
    final bool isEnabled = prefs.getBool('auto_track_enabled') ?? false;
    print("WiroFin NotificationParserService: auto_track_enabled=$isEnabled");
    if (!isEnabled) return;

    final result = parseNotificationText(packageName, title, text);
    print("WiroFin NotificationParserService: parseNotificationText result=$result");
    if (result == null) return; // Fallback: failed to parse amount or transaction type

    final double amount = result['amount'];
    final String type = result['type']; // 'expense' or 'income'
    final String appName = result['appName'];

    // Get active mode (personal or company) -> Force personal mode 'personal'
    final String activeMode = 'personal';

    // Retrieve default accounts and categories
    final accounts = await DatabaseHelper.instance.getAccounts(activeMode);
    final categories = await DatabaseHelper.instance.getCategories(activeMode);
    print("WiroFin NotificationParserService: accounts size=${accounts.length}, categories size=${categories.length}");

    if (accounts.isEmpty || categories.isEmpty) {
      print("WiroFin NotificationParserService: Aborted because accounts or categories are empty");
      return;
    }

    // Find matching linked account for this package
    final appKey = getAppKey(packageName);
    String? accountId;
    
    if (appKey != null) {
      for (var acc in accounts) {
        if (acc['linked_package'] == appKey) {
          accountId = acc['id'];
          break;
        }
      }
    }
    
    // If no account is linked, check if it's the simulator for testing, otherwise IGNORE!
    if (accountId == null) {
      if (appKey == 'wirofin_sim') {
        if (accounts.isNotEmpty) {
          accountId = accounts.first['id'];
        }
      } else {
        print("WiroFin NotificationParserService: No account linked to $appKey ($packageName). Ignoring transaction.");
        return;
      }
    }
    
    if (accountId == null) {
      print("WiroFin NotificationParserService: No account available to record transaction. Ignoring.");
      return;
    }
    
    // Find category ID for "Other" or "Lainnya" or use the first available category
    String categoryId = categories.first['id'];
    for (var cat in categories) {
      final name = cat['name']?.toString().toLowerCase();
      if (name == 'other' || name == 'lainnya') {
        categoryId = cat['id'];
        break;
      }
    }

    final String description = 'Transaksi $appName - ${type == 'expense' ? 'Pengeluaran' : 'Pemasukan'}';

    // Insert to SQLite database
    final id = await DatabaseHelper.instance.insertExpense({
      'amount': amount.round(),
      'description': description,
      'category_id': categoryId,
      'account_id': accountId,
      'date': DateTime.now().toIso8601String(),
      'type': activeMode,
      'transaction_type': type,
    });
    print("WiroFin NotificationParserService: Saved to DB with id=$id");
    _notifyListeners();

    // Send local notification
    try {
      final isEnglish = PreferenceService.instance.languageCode == 'en';
      final formattedAmount = NumberFormat('#,##0', 'id_ID').format(amount);
      
      final String notificationTitle = isEnglish ? 'WiroFin Auto-Track' : 'WiroFin Catat Otomatis';
      final String notificationMessage = isEnglish
          ? 'Tracked ${type == 'expense' ? 'expense' : 'income'} transaction of Rp $formattedAmount'
          : 'Transaksi ${type == 'expense' ? 'pengeluaran' : 'pemasukan'} tercatat Rp $formattedAmount';
          
      print("WiroFin NotificationParserService: Displaying local notification: $notificationMessage");
      await _channel.invokeMethod('showLocalNotification', {
        'title': notificationTitle,
        'message': notificationMessage,
      });
    } catch (e) {
      print('WiroFin NotificationParserService: Error showing local notification: $e');
    }
  }

  Map<String, dynamic>? parseNotificationText(String packageName, String title, String text) {
    String appName = '';
    
    // Determine the application name
    switch (packageName) {
      case 'com.bca.mybca':
      case 'com.bca.mybca.omni.android':
        appName = 'myBCA';
        break;
      case 'com.bcadigital.blu':
        appName = 'Blu by BCA';
        break;
      case 'com.bca':
        appName = 'BCA Mobile';
        break;
      case 'id.co.bri.brimo':
        appName = 'BRImo';
        break;
      case 'id.bmri.livin':
        appName = 'Livin\' by Mandiri';
        break;
      case 'id.bni.wondr':
      case 'com.mediasoft.bni':
        appName = 'BNI Mobile';
        break;
      case 'com.jago.digitalBanking':
        appName = 'Bank Jago';
        break;
      case 'com.alloapp.yump':
        appName = 'Allo Bank';
        break;
      case 'id.co.btn.mobilebanking.android':
        appName = 'BTN Mobile';
        break;
      case 'com.btpn.dc':
        appName = 'Jenius';
        break;
      case 'id.dana':
        appName = 'DANA';
        break;
      case 'com.krom.android':
        appName = 'Krom Bank';
        break;
      case 'id.co.bankbkemobile.digitalbank':
        appName = 'Sea Bank';
        break;
      default:
        return null;
    }

    // 1. Detect Amount using RegExp (Matches common Indonesian formats e.g. Rp 10.000,00 or sebesar 10,000)
    final amountRegex = RegExp(r'(?:Rp\.?\s*|IDR\s*|sebesar\s*)([\d,.]+)', caseSensitive: false);
    final combinedText = '$title\n$text';
    final match = amountRegex.firstMatch(combinedText);
    print("WiroFin NotificationParserService: Regex match for '$combinedText' is $match");
    if (match == null) return null;

    final String rawAmount = match.group(1) ?? '';
    final double? amount = cleanAndParseAmount(rawAmount);
    print("WiroFin NotificationParserService: rawAmount=$rawAmount, cleanAndParsedAmount=$amount");
    if (amount == null || amount <= 0) return null;

    // 2. Detect Transaction Type (income or expense) based on keywords in title or text
    String type = 'expense'; // Default fallback
    final String fullText = '$title $text'.toLowerCase();

    final expenseKeywords = [
      'transfer ke',
      'debet',
      'debit',
      'kirim',
      'sent',
      'spent',
      'bayar',
      'pembayaran',
      'keluar',
      'payment',
      'tarik tunai'
    ];

    final incomeKeywords = [
      'dana masuk',
      'kredit',
      'credit',
      'isi saldo',
      'masuk',
      'received',
      'kiriman uang',
      'top up',
      'diterima',
      'bunga'
    ];

    bool isExpense = false;
    bool isIncome = false;

    for (var key in expenseKeywords) {
      if (fullText.contains(key)) {
        isExpense = true;
        break;
      }
    }

    for (var key in incomeKeywords) {
      if (fullText.contains(key)) {
        isIncome = true;
        break;
      }
    }

    if (isIncome && !isExpense) {
      type = 'income';
    } else {
      type = 'expense';
    }

    return {
      'amount': amount,
      'type': type,
      'appName': appName
    };
  }

  double? cleanAndParseAmount(String rawAmount) {
    try {
      // If the string contains both dot and comma, handle appropriately
      // Indonesian format: 10.000,00 -> remove dot, replace comma with dot
      // English format: 10,000.00 -> remove comma
      String cleaned = rawAmount;
      if (cleaned.contains('.') && cleaned.contains(',')) {
        if (cleaned.indexOf('.') < cleaned.indexOf(',')) {
          // 10.000,00 format
          cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
        } else {
          // 10,000.00 format
          cleaned = cleaned.replaceAll(',', '');
        }
      } else if (cleaned.contains('.')) {
        // Could be thousands separator (10.000) or decimal (10.00). In ID context, usually thousand separator unless followed by 2 digits at the end which is rare without comma
        // If it's like 10.000, we treat dot as thousand separator.
        // Let's count length after the last dot.
        final parts = cleaned.split('.');
        if (parts.last.length == 3 || parts.length > 2) {
          cleaned = cleaned.replaceAll('.', '');
        } else {
          // Decimal dot e.g. 10.5
          // Keep it as is
        }
      } else if (cleaned.contains(',')) {
        // Often thousand separator or decimal comma. Replace with dot.
        final parts = cleaned.split(',');
        if (parts.last.length == 3 || parts.length > 2) {
          cleaned = cleaned.replaceAll(',', '');
        } else {
          cleaned = cleaned.replaceAll(',', '.');
        }
      }

      return double.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }
}
