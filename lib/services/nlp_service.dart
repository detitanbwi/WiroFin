import 'package:flutter/foundation.dart';
import '../services/database_helper.dart';

class NlpParseResult {
  final String transactionType; // 'expense' or 'income'
  final int amount;
  final String description;
  final String? categoryId;
  final DateTime date;

  NlpParseResult({
    required this.transactionType,
    required this.amount,
    required this.description,
    this.categoryId,
    required this.date,
  });
}

class NlpService {
  static final NlpService instance = NlpService._();
  NlpService._();

  bool _isTfliteInitialized = false;

  Future<void> initTflite() async {
    _isTfliteInitialized = true;
  }

  Future<NlpParseResult> parseSentence(String text) async {
    final cleanText = text.toLowerCase().trim();

    // 1. Intent Classification (Income vs Expense)
    String txType = 'expense'; // default
    final incomeKeywords = ['gaji', 'masuk', 'terima', 'bonus', 'cair', 'profit', 'jual', 'dapat', 'pemasukan', 'honor', 'fee', 'dividen'];
    final expenseKeywords = ['beli', 'bayar', 'ngopi', 'makan', 'bensin', 'keluar', 'kasih', 'pengeluaran', 'tagihan', 'belanja', 'gojek', 'grab', 'pulsa', 'parkir', 'tol', 'tiket'];

    int incomeScore = incomeKeywords.where((kw) => cleanText.contains(kw)).length;
    int expenseScore = expenseKeywords.where((kw) => cleanText.contains(kw)).length;

    if (incomeScore > expenseScore) {
      txType = 'income';
    }

    // 2. Amount Extraction (supporting numbers, 'k', 'rb', 'jt')
    int amount = 0;
    final amountRegex = RegExp(r'\b(\d+)(k|rb|jt|m|\.000|,000)?\b');
    final matches = amountRegex.allMatches(cleanText);

    if (matches.isNotEmpty) {
      for (final match in matches) {
        final numStr = match.group(1);
        final unit = match.group(2);
        if (numStr != null) {
          int val = int.tryParse(numStr) ?? 0;
          if (unit == 'k' || unit == 'rb') {
            val *= 1000;
          } else if (unit == 'jt') {
            val *= 1000000;
          } else if (unit == 'm') {
            val *= 1000000000;
          } else if (val < 100 && (cleanText.contains('ribu') || cleanText.contains('rb'))) {
            val *= 1000;
          }
          if (val > amount) {
            amount = val;
          }
        }
      }
    }

    // 3. Date Extraction
    DateTime date = DateTime.now();
    if (cleanText.contains('kemaren') || cleanText.contains('kemarin')) {
      date = date.subtract(const Duration(days: 1));
    } else if (cleanText.contains('lusa')) {
      date = date.add(const Duration(days: 2));
    } else if (cleanText.contains('besok')) {
      date = date.add(const Duration(days: 1));
    }

    // 4. Category Matching from Database
    String? catId;
    final categories = await DatabaseHelper.instance.queryAll('categories');
    for (final cat in categories) {
      final catName = cat['name'].toString().toLowerCase();
      if (cleanText.contains(catName) && cat['transaction_type'] == txType) {
        catId = cat['id']?.toString();
        break;
      }
    }

    if (catId == null) {
      final filterCat = categories.where((c) => c['transaction_type'] == txType).toList();
      if (filterCat.isNotEmpty) {
        catId = filterCat.first['id']?.toString();
      }
    }

    if (amount == 0) {
      throw Exception('Nominal transaksi tidak ditemukan');
    }

    return NlpParseResult(
      transactionType: txType,
      amount: amount,
      description: text,
      categoryId: catId,
      date: date,
    );
  }
}
