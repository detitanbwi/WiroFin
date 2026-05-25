# Technical Implementation Plan & Architecture Blueprint (Android Only)
**Expense Tracker App (Offline-First Hybrid)**

---

## 1. Penjelasan Arsitektur Baru (High-Level)

Arsitektur ini menggunakan **Clean Architecture** dengan **SQLite sebagai Single Source of Truth**. Fokus pengembangan adalah platform **Android**.

*   **Mode Full Offline (Free):** Berjalan 100% tanpa API.
*   **Mode Hybrid (Pro):** Menyinkronkan data SQLite ke Laravel API di latar belakang.

---

## 2. Perubahan Struktur Folder

```text
lib/
├── core/
│   ├── config/      # AppConfig & Environment (Free/Pro)
│   ├── di/          # GetIt Injection setup
│   └── database/    # SQLite Helper
├── data/
│   ├── datasources/ # Local & Remote Data Sources
│   └── repositories/# Repository Implementations (Offline vs Hybrid)
├── domain/          # Entities & Repository Interfaces
├── presentation/    # UI (Dashboard, Master Data, Settings)
├── main_free.dart   # Entry Point Lite (Offline)
└── main_pro.dart    # Entry Point Pro (Hybrid)
```

---

## 3. Panduan Eksekusi 3 Fase

### Fase 1: Setup Arsitektur Environment & Flutter Flavors (Android Only)

**Langkah 1: Konfigurasi Android Flavors (`android/app/build.gradle`)**
Membedakan Package Name agar aplikasi Lite dan Pro bisa diinstal bersamaan.
*   Lite: `com.wirodev.expense.lite`
*   Pro: `com.wirodev.expense.pro`

```gradle
android {
    flavorDimensions "mode"
    productFlavors {
        free {
            dimension "mode"
            applicationIdSuffix ".lite"
            resValue "string", "app_name", "Expense Tracker Lite"
        }
        pro {
            dimension "mode"
            applicationIdSuffix ".pro"
            resValue "string", "app_name", "Expense Tracker Pro"
        }
    }
}
```

**Langkah 2: Pemisahan Aset (App Icon)**
Letakkan ikon berbeda di:
*   `android/app/src/free/res/mipmap-*/ic_launcher.png`
*   `android/app/src/pro/res/mipmap-*/ic_launcher.png`

**Langkah 3: Dart Entry Points**
Gunakan `main_free.dart` dan `main_pro.dart` untuk menginisialisasi `AppConfig` yang sesuai sebelum `runApp()`.

---

### Fase 2: Pembuatan In-App Dashboard & Modul Master Data

**Langkah 1: Dashboard Statistik Lokal**
*   Implementasi `fl_chart` untuk grafik Pie (kategori) dan Line/Bar (pengeluaran).
*   Logic: Menghitung data langsung dari query agregasi SQLite.

**Langkah 2: In-App CRUD Bank / Wallet**
*   Membuat manajemen Rekening/Dompet mandiri.
*   Tabel SQLite `wallets`: menyimpan saldo dan status sinkronisasi.

**Langkah 3: In-App CRUD Category**
*   Membuat manajemen Kategori kustom (pilih ikon/warna).
*   Seeding data kategori default saat startup pertama kali.

---

### Fase 3: Pemisahan Logika (Repository Pattern) & Fitur Backup

**Langkah 1: Implementasi Repository Pattern & DI**
*   Gunakan `get_it` untuk memilih repository saat runtime.
*   `OfflineExpenseRepository`: Hanya eksekusi ke SQLite.
*   `HybridExpenseRepository`: Eksekusi ke SQLite + Trigger background sync ke API.

**Langkah 2: Fitur Backup & Restore (Local Storage)**
*   **Export:** Mengonversi tabel SQLite ke file `.json`.
*   **Import:** Menggunakan `file_picker` untuk membaca file JSON dan melakukan restorasi data ke SQLite.
*   Hal ini krusial bagi pengguna versi Free agar data mereka tetap aman meskipun ganti perangkat.

---

## 4. Build & Run Commands

```bash
# Mode Lite (Free)
flutter run --flavor free -t lib/main_free.dart
flutter build apk --flavor free -t lib/main_free.dart

# Mode Pro (Hybrid)
flutter run --flavor pro -t lib/main_pro.dart
flutter build apk --flavor pro -t lib/main_pro.dart
```
