# Panduan Penggunaan & Build (Flutter Flavors)
**Expense Tracker App**

Dokumen ini menjelaskan cara menjalankan dan membangun aplikasi dalam dua mode: **Full Offline (Lite)** dan **Hybrid (Pro)** menggunakan satu codebase yang sama.

---

## 1. Konsep Arsitektur
Aplikasi dipisahkan menggunakan **Flutter Flavors**. Tidak perlu mengubah kode secara manual untuk berganti mode. Cukup jalankan perintah terminal yang sesuai atau pilih *run configuration* di IDE Anda.

| Fitur | Flavor `free` (Lite) | Flavor `pro` (Pro) |
|---|---|---|
| **Mode** | Full Offline | Hybrid (Offline-First + API Sync) |
| **Package Name** | `com.wirodev.expense.lite` | `com.wirodev.expense.pro` |
| **App Name** | Expense Tracker Lite | Expense Tracker Pro |
| **Entry Point** | `lib/main_free.dart` | `lib/main_pro.dart` |

---

## 2. Cara Menjalankan (Development)

Gunakan flag `--flavor` dan `-t` (target file) untuk menentukan versi mana yang ingin dijalankan.

### Menjalankan Versi Lite (Full Offline)
```bash
flutter run --flavor free -t lib/main_free.dart
```

### Menjalankan Versi Pro (Hybrid)
```bash
flutter run --flavor pro -t lib/main_pro.dart
```

---

## 3. Cara Membangun (Build APK)

Hasil build akan memiliki **Package Name** yang berbeda, sehingga kedua versi bisa diinstal secara bersamaan di satu HP.

### Build APK Lite (Full Offline)
```bash
flutter build apk --release --flavor free -t lib/main_free.dart
```
*Output: `build/app/outputs/flutter-apk/app-free-release.apk`*

### Build APK Pro (Hybrid)
```bash
flutter build apk --release --flavor pro -t lib/main_pro.dart
```
*Output: `build/app/outputs/flutter-apk/app-pro-release.apk`*

---

## 4. Cara Kerja di Dalam Kode (Control Switch)

Semua logika perbedaan mode dikontrol oleh variabel `AppConfig.instance.isOfflineMode`.

### Contoh Penggunaan di UI:
```dart
// Menyembunyikan tombol sinkronisasi jika mode offline
if (!AppConfig.instance.isOfflineMode) {
  SyncIndicatorWidget(),
}
```

### Contoh Penggunaan di Service:
```dart
void saveData() {
  saveToLocalDatabase();
  
  // Hanya kirim ke API jika bukan mode offline
  if (!AppConfig.instance.isOfflineMode) {
    apiService.uploadData();
  }
}
```

---

## 5. Pengaturan Ikon Aplikasi
Ikon aplikasi dipisahkan di folder native Android untuk masing-masing flavor:
*   **Lite:** `android/app/src/free/res/mipmap-*`
*   **Pro:** `android/app/src/pro/res/mipmap-*`

Jika Anda ingin mengganti ikon, cukup ganti file `ic_launcher.png` di dalam folder tersebut sesuai flavor-nya.

---

*Dibuat oleh Assistant - 2026*
