import 'package:flutter/foundation.dart';

/// Enum untuk membedakan mode aplikasi (Flavor).
enum Flavor { free, pro }

/// Base Configuration untuk aplikasi.
/// Digunakan untuk memisahkan variabel environment antara mode Free (Offline) dan Pro (Hybrid).
/// 
/// Cara Penggunaan:
/// 1. Akses instance melalui `AppConfig.instance`.
/// 2. Gunakan properti seperti `AppConfig.instance.isOfflineMode` untuk logika percabangan di UI/Data layer.
abstract class AppConfig {
  /// Nama aplikasi yang akan tampil di UI.
  String get appName;

  /// Endpoint API Laravel (Hanya digunakan pada mode Pro/Hybrid).
  String get apiEndpoint;

  /// Flag untuk menentukan apakah aplikasi berjalan dalam mode Full Offline.
  bool get isOfflineMode;

  /// Identitas flavor yang sedang aktif.
  Flavor get flavor;

  /// Flag untuk menentukan apakah menu Uji Coba & Debugging aktif.
  /// Otomatis aktif saat mode Debug / testing, dan otomatis nonaktif saat rilis (Release mode) ke Play Store.
  bool get enableDebugTools => kDebugMode;

  /// Global instance yang harus diinisialisasi di `main_free.dart` atau `main_pro.dart`.
  static late AppConfig instance;
}

/// Konfigurasi khusus untuk Flavor Free (Full Offline).
/// Di-inject melalui `lib/main_free.dart`.
class FreeConfig extends AppConfig {
  @override
  String get appName => "Expense Tracker Lite";

  @override
  String get apiEndpoint => "";

  @override
  bool get isOfflineMode => true;

  @override
  Flavor get flavor => Flavor.free;
}

/// Konfigurasi khusus untuk Flavor Pro (Hybrid/Private).
/// Di-inject melalui `lib/main_pro.dart`.
class ProConfig extends AppConfig {
  @override
  String get appName => "Expense Tracker Pro";

  @override
  String get apiEndpoint => "https://api.wirodev.com/v1";

  @override
  bool get isOfflineMode => false;

  @override
  Flavor get flavor => Flavor.pro;
}
