# 🚀 Catatan Rilis (Release Notes) - WiroFin v1.2.3

**Versi:** `1.2.3 (Build 8)`
**Tanggal Rilis:** Juni 2026
**Status Rilis:** Production Release (Google Play Store)

---

## ✨ Fitur Baru & Peningkatan Utama

### 🔗 1. Integrasi Target Rekening & Aplikasi Otomasi (Auto-Track App Linking)
Kami menambahkan fitur penting untuk memberikan kontrol penuh kepada pengguna mengenai otomasi transaksi perbankan:
* **Koneksi Rekening Spesifik:** Pengguna kini dapat menghubungkan rekening/wallet tertentu di WiroFin ke aplikasi perbankan/e-wallet pilihan (seperti menghubungkan rekening "Mandiri Utama" ke aplikasi "Livin' by Mandiri").
* **Filter Notifikasi Tertarget:** WiroFin **hanya akan mencatat transaksi** jika notifikasi perbankan berasal dari aplikasi yang telah dikonfigurasikan di salah satu rekening Anda. Notifikasi dari aplikasi bank lain yang belum dihubungkan akan diabaikan secara aman demi ketepatan data.
* **Indikator Visual Premium:** Rekening yang terhubung dengan otomasi akan menampilkan badge berwarna biru dengan ikon petir `Auto-Track: [Nama Aplikasi]` di menu Pengelolaan Rekening.

### 🤖 2. Deteksi Notifikasi M-Banking myBCA & E-Wallet (Auto-Track)
* **Whitelist Aplikasi myBCA:** Mendukung pendeteksian otomatis notifikasi transaksi dari aplikasi myBCA (`com.bca.mybca.omni.android`).
* **Penyimpanan Cerdas & Kategori Otomatis:** Transaksi dari notifikasi bank otomatis disimpan langsung ke mode **Pribadi** dengan kategori **Lainnya / Other** di bawah rekening yang terhubung.
* **Notifikasi Lokal Pencatatan:** WiroFin mengirimkan notifikasi internal "Transaksi pengeluaran/pemasukan tercatat Rp xxxx" sebagai konfirmasi instan setelah mendeteksi notifikasi perbankan.
* **Deskripsi Lebih Bersih:** Menghapus prefiks `"Auto-Track: "` dari deskripsi transaksi agar catatan bersih dan nyaman dibaca.

### 🛡️ 3. Fitur Pencadangan Otomatis & Pemulihan (Auto-Backup & Restore)
* **Auto-Backup Harian (FIFO):** Data dicadangkan secara otomatis berdasarkan interval harian yang Anda pilih (Harian, 3 Hari, atau 7 Hari).
* **Batas Penumpukan Cadangan:** Sistem otomatis melakukan rotasi *First-In-First-Out* (FIFO) untuk menghapus file cadangan terlama demi menghemat ruang penyimpanan perangkat Anda.
* **Halaman Pengaturan Khusus:** Menu baru di Master Data untuk mengaktifkan pencadangan otomatis, mengatur interval, batas file, melihat daftar file cadangan lokal, serta melakukan pemulihan (*restore*) langsung.
* **Pengembalian Tombol Ekspor/Impor:** Memulihkan kembali tombol Ekspor ke Excel (.xlsx) dan Impor JSON manual dari folder eksternal di halaman Backup & Restore.

### 🎛️ 4. Pengubah Mode Transaksi Aman (Pribadi ↔ Usaha Switcher)
* **Switcher di Bottom Sheet Edit:** Tombol pengubah mode diletakkan dengan rapi di bagian atas lembar edit transaksi (*Edit Transaction Bottom Sheet*).
* **Keamanan Skema Transaksi Baru:** Fitur pemindah mode ini **hanya aktif saat mengedit transaksi lama**. Untuk transaksi baru, tombol ini disembunyikan dan digantikan dengan *badge* status statis untuk mencegah *error* database.
* **Indikator Latar Belakang Psikologis:** Latar belakang halaman edit otomatis berubah warna dengan lembut mengikuti mode aktif (Warna Orange lembut untuk Pribadi, Teal lembut untuk Usaha) guna membantu psikologi pengguna agar mengenali mode aktif secara instan.
* **Tampilan List Bersih:** Menghapus tombol pemindah mode dari baris daftar utama (*transaction list row*) agar UI daftar transaksi tetap minimalis dan bersih.

### 📦 5. Modularisasi & Struktur Kode Bersih (Clean Code Architecture)
* **Pemisahan Modul Master Data:** Berkas utama `master_data_screen.dart` yang awalnya sangat panjang (1800+ baris) kini dipecah secara rapi ke dalam modul-modul sub-page terpisah di folder `lib/screens/master_data/`.
* **Bebas Warnings & Lints:** Hasil audit statis (`flutter analyze`) pada file yang diubah menunjukkan **0 error & warnings** untuk menjamin kestabilan performa build aplikasi.
