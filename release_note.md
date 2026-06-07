# 🚀 Catatan Rilis (Release Notes) - WiroFin v1.2.2

**Versi:** `1.2.2 (Build 7)`
**Tanggal Rilis:** Juni 2026
**Status Rilis:** Production Release (Google Play Store)

---

## ✨ Fitur Baru & Peningkatan Utama

### 🤖 1. Deteksi Notifikasi M-Banking myBCA & E-Wallet (Auto-Track)
Kami meningkatkan fitur pendeteksian otomatis transaksi dari notifikasi keuangan agar lebih akurat dan terintegrasi:
* **Whitelist Aplikasi myBCA:** Menambahkan dukungan penuh untuk mendeteksi notifikasi transaksi dari aplikasi myBCA (`com.bca.mybca.omni.android`).
* **Penyimpanan Cerdas & Kategori Otomatis:** Transaksi dari notifikasi bank otomatis disimpan langsung ke mode **Pribadi** dengan kategori **Lainnya / Other**.
* **Notifikasi Lokal Pencatatan:** WiroFin kini mengirimkan notifikasi internal "Transaksi pengeluaran tercatat Rp xxxx" atau nominal pemasukan sebagai konfirmasi instan setelah mendeteksi notifikasi perbankan.
* **Deskripsi Lebih Bersih:** Menghapus prefiks `"Auto-Track: "` dari deskripsi transaksi agar catatan bersih dan nyaman dibaca.

### 🛡️ 2. Fitur Pencadangan Otomatis & Pemulihan (Auto-Backup & Restore)
Kami menambahkan sistem perlindungan data transaksi secara otomatis agar data Anda tidak mudah hilang:
* **Auto-Backup Harian (FIFO):** Data dicadangkan secara otomatis berdasarkan interval harian yang Anda pilih (Harian, 3 Hari, atau 7 Hari).
* **Batas Penumpukan Cadangan:** Sistem otomatis melakukan rotasi *First-In-First-Out* (FIFO) untuk menghapus file cadangan terlama demi menghemat ruang penyimpanan perangkat Anda.
* **Halaman Pengaturan Khusus:** Menu baru di Master Data untuk mengaktifkan pencadangan otomatis, mengatur interval, batas file, melihat daftar file cadangan lokal, serta melakukan pemulihan (*restore*) langsung.
* **Pengembalian Tombol Ekspor/Impor:** Memulihkan kembali tombol Ekspor ke Excel (.xlsx) dan Impor JSON manual dari folder eksternal di halaman Backup & Restore.

### 🎛️ 3. Pengubah Mode Transaksi Aman (Pribadi ↔ Usaha Switcher)
Sekarang Anda dapat memindahkan catatan transaksi yang salah catat antara mode Pribadi dan Usaha dengan mudah:
* **Switcher di Bottom Sheet Edit:** Tombol pengubah mode diletakkan dengan rapi di bagian atas lembar edit transaksi (*Edit Transaction Bottom Sheet*).
* **Keamanan Skema Transaksi Baru:** Fitur pemindah mode ini **hanya aktif saat mengedit transaksi lama**. Untuk transaksi baru, tombol ini disembunyikan dan digantikan dengan *badge* status statis untuk mencegah *error* database / ketidaksesuaian data.
* **Indikator Latar Belakang Psikologis:** Latar belakang halaman edit otomatis berubah warna dengan lembut mengikuti mode aktif (Warna Orange lembut untuk Pribadi, Teal lembut untuk Usaha) guna membantu psikologi pengguna agar mengenali mode aktif secara instan.
* **Tampilan List Bersih:** Menghapus tombol pemindah mode dari baris daftar utama (*transaction list row*) agar UI daftar transaksi tetap minimalis dan bersih.

### 📦 4. Modularisasi & Struktur Kode Bersih (Clean Code Architecture)
Struktur kode aplikasi telah dirapikan agar lebih mudah dipelihara dan dikembangkan oleh tim:
* **Pemisahan Modul Master Data:** Berkas utama `master_data_screen.dart` yang awalnya sangat panjang (1800+ baris) kini dipecah secara rapi ke dalam modul-modul sub-page terpisah di folder `lib/screens/master_data/` (seperti `profile_settings_page.dart`, `category_settings_page.dart`, dll.).
* **Bebas Warnings & Lints:** Hasil audit statis (`flutter analyze`) pada file yang diubah menunjukkan **0 error & warnings** untuk menjamin kestabilan performa build aplikasi.
