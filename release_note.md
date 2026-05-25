# 🚀 Catatan Rilis (Release Notes) - WiroFin v1.2.0

**Versi:** `1.2.0 (Build 4)`
**Tanggal Rilis:** Mei 2026
**Status Rilis:** Production Release (Google Play Store)

---

## ✨ Fitur Baru & Peningkatan Utama

### 📱 1. WiroFin Home Screen Widget (Baru!)

Sekarang Anda dapat memantau kesehatan finansial langsung dari layar depan (*home screen*) ponsel Android Anda tanpa harus membuka aplikasi!

* **Pemantauan Saldo & Pengeluaran Seketika:** Pantau sisa anggaran dan total pengeluaran harian Anda secara *real-time*.
* **Tombol Cepat "Catat Transaksi":** Tambahkan transaksi baru dalam satu ketukan langsung dari widget layar depan.
* **Integrasi Tema Sistem:** Didukung oleh desain adaptif yang otomatis mengikuti mode Gelap/Terang (*Dark/Light Mode*) dari sistem ponsel Anda.
* **Panduan Interaktif:** Tersedia halaman panduan cara pemasangan widget dan pop-up pengenalan (*What's New*) bernuansa *glassmorphism* yang elegan saat aplikasi pertama kali diperbarui.

### 🔄 2. Ekspor & Impor Data JSON Menyeluruh

Kami telah meningkatkan keandalan fitur pencadangan data (*Backup & Restore*):

* **Penyimpanan Profil & Saldo:** Proses ekspor dan impor kini mencakup seluruh pengaturan konfigurasi profil Anda (Nama Pengguna, Saldo Awal, Bahasa, Mode Personal/Bisnis, serta preferensi notifikasi).
* **Bebas Repot:** Saat memulihkan (*restore*) data di perangkat baru, Anda tidak perlu lagi melakukan pengaturan profil secara manual dari awal.

### 🌐 3. Bahasa, Diksi & Internasionalisasi yang Lebih Profesional

* Seluruh aplikasi kini ditenagai oleh sistem lokalisasi resmi (`AppLocalizations`).
* Penyempurnaan pilihan kata (diksi) dan tata bahasa finansial baku yang lebih konsisten, jelas, dan profesional baik untuk Bahasa Indonesia maupun Bahasa Inggris.

### 🛡️ 4. Peningkatan Sistem Keamanan & Notifikasi Update

* **In-App Update Play Store:** Aplikasi kini memiliki deteksi cerdas yang langsung terhubung ke Google Play Store untuk memastikan Anda selalu mendapatkan pembaruan keamanan terbaru.
* **Navigasi Dialog Pintar:** Sistem otomatis mengatur antrean kemunculan pop-up agar informasi pembaruan wajib dan pengenalan fitur baru tidak saling menutupi.

---

## 🛠️ Khusus Pengembang & Tim QA (Mode Testing)

* **Halaman Uji Coba & Reset Status:** Penambahan menu khusus pada mode *debug* untuk melakukan simulasi pop-up *update* Play Store dan mengulang notifikasi *What's New* seketika.
* **Tombol "Tutup Simulasi":** Dilengkapi tombol keluar cepat saat pengujian agar tidak terkunci di layar *update*.
* **Auto-Hide Production Build:** Menggunakan sistem proteksi kompilator (`enableDebugTools`) di mana seluruh menu dan tombol simulasi ini **otomatis hilang 100%** ketika aplikasi dikompilasi untuk rilis resmi ke Play Store.
