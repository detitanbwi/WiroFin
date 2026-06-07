import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'WiroFin'**
  String get appName;

  /// No description provided for @greetingPrefix.
  ///
  /// In id, this message translates to:
  /// **'Halo'**
  String get greetingPrefix;

  /// No description provided for @personalMode.
  ///
  /// In id, this message translates to:
  /// **'Pribadi'**
  String get personalMode;

  /// No description provided for @companyMode.
  ///
  /// In id, this message translates to:
  /// **'Perusahaan'**
  String get companyMode;

  /// No description provided for @dashboard.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get dashboard;

  /// No description provided for @transactions.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get transactions;

  /// No description provided for @masterData.
  ///
  /// In id, this message translates to:
  /// **'Master Data'**
  String get masterData;

  /// No description provided for @allTime.
  ///
  /// In id, this message translates to:
  /// **'Semua Waktu'**
  String get allTime;

  /// No description provided for @netBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo Bersih'**
  String get netBalance;

  /// No description provided for @income.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get expense;

  /// No description provided for @liveUpdate.
  ///
  /// In id, this message translates to:
  /// **'Terbaru'**
  String get liveUpdate;

  /// No description provided for @expenseDistribution.
  ///
  /// In id, this message translates to:
  /// **'Distribusi Pengeluaran'**
  String get expenseDistribution;

  /// No description provided for @transactionHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Transaksi Hari Ini'**
  String get transactionHistory;

  /// No description provided for @seeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat Semua'**
  String get seeAll;

  /// No description provided for @exitAppTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluar Aplikasi'**
  String get exitAppTitle;

  /// No description provided for @exitAppMessage.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin keluar dari aplikasi Wirofin?'**
  String get exitAppMessage;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get exit;

  /// No description provided for @recordTransaction.
  ///
  /// In id, this message translates to:
  /// **'Catat Transaksi'**
  String get recordTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In id, this message translates to:
  /// **'Edit Transaksi'**
  String get editTransaction;

  /// No description provided for @amount.
  ///
  /// In id, this message translates to:
  /// **'Nominal'**
  String get amount;

  /// No description provided for @descriptionOptional.
  ///
  /// In id, this message translates to:
  /// **'Keterangan (Opsional)'**
  String get descriptionOptional;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menghapus ini?'**
  String get confirmDelete;

  /// No description provided for @successSave.
  ///
  /// In id, this message translates to:
  /// **'Data berhasil disimpan'**
  String get successSave;

  /// No description provided for @successDelete.
  ///
  /// In id, this message translates to:
  /// **'Data berhasil dihapus'**
  String get successDelete;

  /// No description provided for @successUpdate.
  ///
  /// In id, this message translates to:
  /// **'Data berhasil diperbarui'**
  String get successUpdate;

  /// No description provided for @successSaveTransaction.
  ///
  /// In id, this message translates to:
  /// **'Transaksi berhasil tersimpan'**
  String get successSaveTransaction;

  /// No description provided for @amountEmptyError.
  ///
  /// In id, this message translates to:
  /// **'Nominal tidak boleh kosong'**
  String get amountEmptyError;

  /// No description provided for @nlpTitle.
  ///
  /// In id, this message translates to:
  /// **'Pencatatan Cerdas (NLP)'**
  String get nlpTitle;

  /// No description provided for @nlpSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ketik kalimat kasual, WiroFin otomatis mengisinya'**
  String get nlpSubtitle;

  /// No description provided for @nlpExampleHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Beli Bensin 50rb kemarin...'**
  String get nlpExampleHint;

  /// No description provided for @nlpTrySentence.
  ///
  /// In id, this message translates to:
  /// **'Coba kalimat berikut:'**
  String get nlpTrySentence;

  /// No description provided for @nlpSample1.
  ///
  /// In id, this message translates to:
  /// **'Ngopi kopi kenangan 28k'**
  String get nlpSample1;

  /// No description provided for @nlpSample2.
  ///
  /// In id, this message translates to:
  /// **'Gaji bulanan masuk 5jt'**
  String get nlpSample2;

  /// No description provided for @nlpSample3.
  ///
  /// In id, this message translates to:
  /// **'Beli bensin pertamax 50rb kemarin'**
  String get nlpSample3;

  /// No description provided for @nlpSample4.
  ///
  /// In id, this message translates to:
  /// **'Makan siang warteg 20000'**
  String get nlpSample4;

  /// No description provided for @nlpErrorNoAmount.
  ///
  /// In id, this message translates to:
  /// **'Nominal transaksi tidak ditemukan'**
  String get nlpErrorNoAmount;

  /// No description provided for @nlpErrorProcess.
  ///
  /// In id, this message translates to:
  /// **'Gagal memproses kalimat'**
  String get nlpErrorProcess;

  /// No description provided for @allTransactionsTitle.
  ///
  /// In id, this message translates to:
  /// **'Semua Transaksi'**
  String get allTransactionsTitle;

  /// No description provided for @showingAll.
  ///
  /// In id, this message translates to:
  /// **'Menampilkan Semua'**
  String get showingAll;

  /// No description provided for @filterLabel.
  ///
  /// In id, this message translates to:
  /// **'Filter'**
  String get filterLabel;

  /// No description provided for @transactionCountLabel.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get transactionCountLabel;

  /// No description provided for @successUpdateTransaction.
  ///
  /// In id, this message translates to:
  /// **'Transaksi berhasil diperbarui'**
  String get successUpdateTransaction;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Transaksi'**
  String get deleteTransactionTitle;

  /// No description provided for @confirmDeleteTransaction.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menghapus transaksi ini?'**
  String get confirmDeleteTransaction;

  /// No description provided for @successDeleteTransaction.
  ///
  /// In id, this message translates to:
  /// **'Transaksi berhasil dihapus'**
  String get successDeleteTransaction;

  /// No description provided for @emptyTransaction.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi'**
  String get emptyTransaction;

  /// No description provided for @aboutWiroFin.
  ///
  /// In id, this message translates to:
  /// **'Tentang WiroFin'**
  String get aboutWiroFin;

  /// No description provided for @versionLabel.
  ///
  /// In id, this message translates to:
  /// **'Versi'**
  String get versionLabel;

  /// No description provided for @developerLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengembang'**
  String get developerLabel;

  /// No description provided for @createdOnLabel.
  ///
  /// In id, this message translates to:
  /// **'Dibuat Pada'**
  String get createdOnLabel;

  /// No description provided for @licenseLabel.
  ///
  /// In id, this message translates to:
  /// **'Lisensi'**
  String get licenseLabel;

  /// No description provided for @freeToUseLabel.
  ///
  /// In id, this message translates to:
  /// **'Free to Use'**
  String get freeToUseLabel;

  /// No description provided for @legalLabel.
  ///
  /// In id, this message translates to:
  /// **'Hukum'**
  String get legalLabel;

  /// No description provided for @websiteLabel.
  ///
  /// In id, this message translates to:
  /// **'Website'**
  String get websiteLabel;

  /// No description provided for @userProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil Pengguna'**
  String get userProfile;

  /// No description provided for @bankAccountManagement.
  ///
  /// In id, this message translates to:
  /// **'Pengelolaan Rekening'**
  String get bankAccountManagement;

  /// No description provided for @transactionCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori Transaksi'**
  String get transactionCategory;

  /// No description provided for @dataBackupRestore.
  ///
  /// In id, this message translates to:
  /// **'Cadangan Data (Backup & Restore)'**
  String get dataBackupRestore;

  /// No description provided for @profile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @usernameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Panggilan'**
  String get usernameLabel;

  /// No description provided for @saveProfile.
  ///
  /// In id, this message translates to:
  /// **'Simpan Profil'**
  String get saveProfile;

  /// No description provided for @successSaveProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil Berhasil Disimpan'**
  String get successSaveProfile;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @languageSwitch.
  ///
  /// In id, this message translates to:
  /// **'Indonesia / English'**
  String get languageSwitch;

  /// No description provided for @addBankAccount.
  ///
  /// In id, this message translates to:
  /// **'Tambah Rekening'**
  String get addBankAccount;

  /// No description provided for @editBankAccount.
  ///
  /// In id, this message translates to:
  /// **'Edit Rekening'**
  String get editBankAccount;

  /// No description provided for @bankAccountName.
  ///
  /// In id, this message translates to:
  /// **'Nama Rekening'**
  String get bankAccountName;

  /// No description provided for @initialBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo Awal'**
  String get initialBalance;

  /// No description provided for @deleteDataTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Data'**
  String get deleteDataTitle;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menghapus rekening ini?'**
  String get confirmDeleteAccount;

  /// No description provided for @successSaveAccount.
  ///
  /// In id, this message translates to:
  /// **'Rekening berhasil disimpan'**
  String get successSaveAccount;

  /// No description provided for @successDeleteAccount.
  ///
  /// In id, this message translates to:
  /// **'Rekening berhasil dihapus'**
  String get successDeleteAccount;

  /// No description provided for @emptyAccount.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data rekening'**
  String get emptyAccount;

  /// No description provided for @addCategory.
  ///
  /// In id, this message translates to:
  /// **'Tambah Kategori'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In id, this message translates to:
  /// **'Edit Kategori'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In id, this message translates to:
  /// **'Nama Kategori'**
  String get categoryName;

  /// No description provided for @transactionType.
  ///
  /// In id, this message translates to:
  /// **'Jenis Transaksi'**
  String get transactionType;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menghapus kategori ini?'**
  String get confirmDeleteCategory;

  /// No description provided for @successSaveCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori berhasil disimpan'**
  String get successSaveCategory;

  /// No description provided for @successDeleteCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori berhasil dihapus'**
  String get successDeleteCategory;

  /// No description provided for @emptyCategory.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data kategori'**
  String get emptyCategory;

  /// No description provided for @defaultCategoryError.
  ///
  /// In id, this message translates to:
  /// **'Kategori default \"Other\" tidak dapat dihapus.'**
  String get defaultCategoryError;

  /// No description provided for @defaultLabel.
  ///
  /// In id, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In id, this message translates to:
  /// **'Cadangan & Pemulihan Data'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreDesc.
  ///
  /// In id, this message translates to:
  /// **'Simpan data Anda ke file lokal agar bisa dipulihkan kembali nanti'**
  String get backupRestoreDesc;

  /// No description provided for @exportJson.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Data ke JSON'**
  String get exportJson;

  /// No description provided for @exportExcel.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Data ke Excel'**
  String get exportExcel;

  /// No description provided for @importJson.
  ///
  /// In id, this message translates to:
  /// **'Impor Data dari JSON'**
  String get importJson;

  /// No description provided for @successExport.
  ///
  /// In id, this message translates to:
  /// **'Data Berhasil diekspor ke '**
  String get successExport;

  /// No description provided for @confirmRestoreTitle.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Restore'**
  String get confirmRestoreTitle;

  /// No description provided for @confirmRestoreWarning.
  ///
  /// In id, this message translates to:
  /// **'PERHATIAN: Mengimpor data akan menghapus semua data saat ini dan menggantinya dengan isi file backup. Lanjutkan?'**
  String get confirmRestoreWarning;

  /// No description provided for @continueLabel.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get continueLabel;

  /// No description provided for @successImport.
  ///
  /// In id, this message translates to:
  /// **'Data berhasil diimpor!'**
  String get successImport;

  /// No description provided for @voiceRecord.
  ///
  /// In id, this message translates to:
  /// **'Pencatatan Suara/Teks'**
  String get voiceRecord;

  /// No description provided for @onboardingTitle1.
  ///
  /// In id, this message translates to:
  /// **'Kelola Uang Lebih Baik'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In id, this message translates to:
  /// **'Pantau pengeluaran, atur kategori, dan simpan data Anda secara offline dengan aman.'**
  String get onboardingSubtitle1;

  /// No description provided for @agreeTerms.
  ///
  /// In id, this message translates to:
  /// **'Saya menyetujui '**
  String get agreeTerms;

  /// No description provided for @termsConditions.
  ///
  /// In id, this message translates to:
  /// **'Syarat & Ketentuan'**
  String get termsConditions;

  /// No description provided for @usageWiroFin.
  ///
  /// In id, this message translates to:
  /// **' penggunaan WiroFin.'**
  String get usageWiroFin;

  /// No description provided for @startJourney.
  ///
  /// In id, this message translates to:
  /// **'Mulai Perjalanan Anda'**
  String get startJourney;

  /// No description provided for @startFresh.
  ///
  /// In id, this message translates to:
  /// **'Mulai dari Awal'**
  String get startFresh;

  /// No description provided for @startFreshDesc.
  ///
  /// In id, this message translates to:
  /// **'Buat akun baru dan atur profil Anda.'**
  String get startFreshDesc;

  /// No description provided for @importOldData.
  ///
  /// In id, this message translates to:
  /// **'Impor Data Lama'**
  String get importOldData;

  /// No description provided for @importOldDataDesc.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan data dari file backup JSON.'**
  String get importOldDataDesc;

  /// No description provided for @whatsYourName.
  ///
  /// In id, this message translates to:
  /// **'Siapa nama Anda?'**
  String get whatsYourName;

  /// No description provided for @nameGreetingDesc.
  ///
  /// In id, this message translates to:
  /// **'Nama ini akan digunakan untuk menyapa Anda.'**
  String get nameGreetingDesc;

  /// No description provided for @enterName.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama'**
  String get enterName;

  /// No description provided for @mainAccount.
  ///
  /// In id, this message translates to:
  /// **'Rekening Utama'**
  String get mainAccount;

  /// No description provided for @enterInitialBalance.
  ///
  /// In id, this message translates to:
  /// **'Masukkan saldo awal Anda saat ini.'**
  String get enterInitialBalance;

  /// No description provided for @accountNameHint.
  ///
  /// In id, this message translates to:
  /// **'Nama Rekening (Misal: BCA / Tunai)'**
  String get accountNameHint;

  /// No description provided for @back.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get back;

  /// No description provided for @next.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get finish;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In id, this message translates to:
  /// **'Update Tersedia!'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableMessage.
  ///
  /// In id, this message translates to:
  /// **'Versi terbaru WiroFin sudah tersedia di Play Store. Silakan update untuk melanjutkan menggunakan aplikasi.'**
  String get updateAvailableMessage;

  /// No description provided for @updateNow.
  ///
  /// In id, this message translates to:
  /// **'Update Sekarang'**
  String get updateNow;

  /// No description provided for @widgetStatus.
  ///
  /// In id, this message translates to:
  /// **'Terbaru'**
  String get widgetStatus;

  /// No description provided for @totalBalanceAvailable.
  ///
  /// In id, this message translates to:
  /// **'Total Saldo Tersedia'**
  String get totalBalanceAvailable;

  /// No description provided for @instantRecordingWidget.
  ///
  /// In id, this message translates to:
  /// **'Pencatatan Instan via Widget'**
  String get instantRecordingWidget;

  /// No description provided for @widgetDesc.
  ///
  /// In id, this message translates to:
  /// **'Pantau performa keuangan dan total saldo Anda langsung dari layar utama HP tanpa repot membuka aplikasi setiap saat.'**
  String get widgetDesc;

  /// No description provided for @termsConditionsTitle.
  ///
  /// In id, this message translates to:
  /// **'Syarat & Ketentuan'**
  String get termsConditionsTitle;

  /// No description provided for @termsConditionsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Syarat dan Ketentuan Penggunaan WiroFin'**
  String get termsConditionsSubtitle;

  /// No description provided for @termsLastUpdated.
  ///
  /// In id, this message translates to:
  /// **'Terakhir diperbarui: 11 Mei 2026'**
  String get termsLastUpdated;

  /// No description provided for @termsSec1Title.
  ///
  /// In id, this message translates to:
  /// **'1. Penerimaan Ketentuan'**
  String get termsSec1Title;

  /// No description provided for @termsSec1Content.
  ///
  /// In id, this message translates to:
  /// **'Dengan mengunduh atau menggunakan aplikasi WiroFin, Anda secara otomatis menyetujui semua syarat dan ketentuan yang tertulis di sini. Jika Anda tidak setuju, harap segera menghentikan penggunaan aplikasi.'**
  String get termsSec1Content;

  /// No description provided for @termsSec2Title.
  ///
  /// In id, this message translates to:
  /// **'2. Penggunaan Aplikasi'**
  String get termsSec2Title;

  /// No description provided for @termsSec2Content.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi ini disediakan untuk membantu Anda dalam pencatatan keuangan pribadi dan bisnis. Anda bertanggung jawab penuh atas keakuratan data yang Anda masukkan.'**
  String get termsSec2Content;

  /// No description provided for @termsSec3Title.
  ///
  /// In id, this message translates to:
  /// **'3. Batasan Tanggung Jawab'**
  String get termsSec3Title;

  /// No description provided for @termsSec3Content.
  ///
  /// In id, this message translates to:
  /// **'WIROFIN DISEDIAKAN \"APA ADANYA\" TANPA JAMINAN APAPUN. SEGALA KERUGIAN ATAS PEMAKAIAN APLIKASI INI ADALAH SEPENUHNYA TANGGUNG JAWAB PENGGUNA. KAMI TIDAK BERTANGGUNG JAWAB ATAS KEHILANGAN DATA, KESALAHAN PERHITUNGAN, ATAU DAMPAK FINANSIAL APAPUN YANG TIMBUL DARI PENGGUNAAN APLIKASI INI.'**
  String get termsSec3Content;

  /// No description provided for @termsSec4Title.
  ///
  /// In id, this message translates to:
  /// **'4. Keamanan Data'**
  String get termsSec4Title;

  /// No description provided for @termsSec4Content.
  ///
  /// In id, this message translates to:
  /// **'Dalam mode offline, data Anda disimpan secara lokal di perangkat Anda. Anda bertanggung jawab untuk melakukan backup data Anda sendiri.'**
  String get termsSec4Content;

  /// No description provided for @termsSec5Title.
  ///
  /// In id, this message translates to:
  /// **'5. Perubahan Layanan'**
  String get termsSec5Title;

  /// No description provided for @termsSec5Content.
  ///
  /// In id, this message translates to:
  /// **'Kami berhak mengubah atau menghentikan layanan aplikasi kapan saja tanpa pemberitahuan sebelumnya.'**
  String get termsSec5Content;

  /// No description provided for @widgetGuideTitle.
  ///
  /// In id, this message translates to:
  /// **'Panduan Pasang Widget'**
  String get widgetGuideTitle;

  /// No description provided for @widgetHomeScreenTitle.
  ///
  /// In id, this message translates to:
  /// **'Widget Home Screen WiroFin'**
  String get widgetHomeScreenTitle;

  /// No description provided for @widgetHomeScreenDesc.
  ///
  /// In id, this message translates to:
  /// **'Pantau terus kesehatan finansial Anda tanpa harus membuka aplikasi.'**
  String get widgetHomeScreenDesc;

  /// No description provided for @threeEasySteps.
  ///
  /// In id, this message translates to:
  /// **'3 Langkah Mudah Pemasangan'**
  String get threeEasySteps;

  /// No description provided for @widgetStep1Title.
  ///
  /// In id, this message translates to:
  /// **'Pergi ke Layar Utama HP'**
  String get widgetStep1Title;

  /// No description provided for @widgetStep1Desc.
  ///
  /// In id, this message translates to:
  /// **'Tutup atau minimalkan aplikasi WiroFin dan navigasikan ke layar utama (Home Screen) di HP Android atau iOS Anda.'**
  String get widgetStep1Desc;

  /// No description provided for @widgetStep2Title.
  ///
  /// In id, this message translates to:
  /// **'Tekan & Tahan Area Kosong'**
  String get widgetStep2Title;

  /// No description provided for @widgetStep2Desc.
  ///
  /// In id, this message translates to:
  /// **'Tekan dan tahan (long press) pada area kosong di layar utama selama beberapa detik hingga muncul menu pengaturan layar atau pop-up menu.'**
  String get widgetStep2Desc;

  /// No description provided for @widgetStep3Title.
  ///
  /// In id, this message translates to:
  /// **'Pilih & Seret Widget'**
  String get widgetStep3Title;

  /// No description provided for @widgetStep3Desc.
  ///
  /// In id, this message translates to:
  /// **'Ketuk menu \"Widget\" (atau ikon +), gulir untuk mencari \"WiroFin\", lalu seret varian widget yang Anda inginkan ke layar utama.'**
  String get widgetStep3Desc;

  /// No description provided for @widgetTips.
  ///
  /// In id, this message translates to:
  /// **'Tips: Widget WiroFin akan otomatis menyesuaikan warnanya sesuai mode (Personal/Company) saat aplikasi dibuka.'**
  String get widgetTips;

  /// No description provided for @autoTrackTitle.
  ///
  /// In id, this message translates to:
  /// **'Otomatisasi M-Banking & E-Wallet'**
  String get autoTrackTitle;

  /// No description provided for @autoTrackSwitch.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan Auto-Track'**
  String get autoTrackSwitch;

  /// No description provided for @autoTrackSwitchDesc.
  ///
  /// In id, this message translates to:
  /// **'Deteksi nominal transaksi dari notifikasi yang masuk secara otomatis'**
  String get autoTrackSwitchDesc;

  /// No description provided for @autoTrackPermission.
  ///
  /// In id, this message translates to:
  /// **'Izin Akses Notifikasi'**
  String get autoTrackPermission;

  /// No description provided for @autoTrackPermissionActive.
  ///
  /// In id, this message translates to:
  /// **'Izin telah diberikan'**
  String get autoTrackPermissionActive;

  /// No description provided for @autoTrackPermissionInactive.
  ///
  /// In id, this message translates to:
  /// **'Izin belum diaktifkan'**
  String get autoTrackPermissionInactive;

  /// No description provided for @autoTrackPermissionBtn.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan'**
  String get autoTrackPermissionBtn;

  /// No description provided for @autoTrackPrivacyTitle.
  ///
  /// In id, this message translates to:
  /// **'Privacy-First (100% Lokal)'**
  String get autoTrackPrivacyTitle;

  /// No description provided for @autoTrackPrivacyDesc.
  ///
  /// In id, this message translates to:
  /// **'WiroFin memproses data notifikasi hanya di dalam memori lokal ponsel Anda. Tidak ada data transaksi atau informasi pribadi yang dikirim ke server luar.'**
  String get autoTrackPrivacyDesc;

  /// No description provided for @autoTrackSupportedApps.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi yang Didukung:'**
  String get autoTrackSupportedApps;

  /// No description provided for @autoTrackDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Izin Akses Notifikasi'**
  String get autoTrackDialogTitle;

  /// No description provided for @autoTrackDialogContent.
  ///
  /// In id, this message translates to:
  /// **'WiroFin membutuhkan izin untuk membaca notifikasi sistem agar dapat melacak transaksi perbankan Anda secara otomatis.\n\nSemua data diproses 100% secara lokal dan offline di perangkat Anda demi menjaga keamanan data keuangan.'**
  String get autoTrackDialogContent;

  /// No description provided for @autoTrackDialogCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get autoTrackDialogCancel;

  /// No description provided for @autoTrackDialogSettings.
  ///
  /// In id, this message translates to:
  /// **'Buka Pengaturan'**
  String get autoTrackDialogSettings;

  /// No description provided for @autoBackupTitle.
  ///
  /// In id, this message translates to:
  /// **'Auto-Backup & Pemulihan Otomatis'**
  String get autoBackupTitle;

  /// No description provided for @autoBackupSettingTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Auto-Backup'**
  String get autoBackupSettingTitle;

  /// No description provided for @autoBackupSwitch.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan Auto-Backup'**
  String get autoBackupSwitch;

  /// No description provided for @autoBackupSwitchDesc.
  ///
  /// In id, this message translates to:
  /// **'Cadangkan data secara otomatis ketika membuka aplikasi'**
  String get autoBackupSwitchDesc;

  /// No description provided for @autoBackupInterval.
  ///
  /// In id, this message translates to:
  /// **'Interval Pencadangan'**
  String get autoBackupInterval;

  /// No description provided for @autoBackupIntervalDaily.
  ///
  /// In id, this message translates to:
  /// **'Setiap Hari'**
  String get autoBackupIntervalDaily;

  /// No description provided for @autoBackupIntervalWeekly.
  ///
  /// In id, this message translates to:
  /// **'Setiap 7 Hari'**
  String get autoBackupIntervalWeekly;

  /// No description provided for @autoBackupIntervalMonthly.
  ///
  /// In id, this message translates to:
  /// **'Setiap 30 Hari'**
  String get autoBackupIntervalMonthly;

  /// No description provided for @autoBackupMaxFiles.
  ///
  /// In id, this message translates to:
  /// **'Batas Penumpukan Cadangan'**
  String get autoBackupMaxFiles;

  /// No description provided for @autoBackupMaxFilesDesc.
  ///
  /// In id, this message translates to:
  /// **'Jumlah maksimal file cadangan yang disimpan di folder lokal sebelum file tertua dihapus (FIFO).'**
  String get autoBackupMaxFilesDesc;

  /// No description provided for @autoBackupBtn.
  ///
  /// In id, this message translates to:
  /// **'Cadangkan Sekarang'**
  String get autoBackupBtn;

  /// No description provided for @autoBackupSuccess.
  ///
  /// In id, this message translates to:
  /// **'Backup otomatis berhasil dibuat'**
  String get autoBackupSuccess;

  /// No description provided for @autoBackupFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuat backup otomatis'**
  String get autoBackupFailed;

  /// No description provided for @autoBackupNoticeTitle.
  ///
  /// In id, this message translates to:
  /// **'Manajemen File Cadangan'**
  String get autoBackupNoticeTitle;

  /// No description provided for @autoBackupNoticeDesc.
  ///
  /// In id, this message translates to:
  /// **'File cadangan disimpan secara offline di folder khusus \'wirofin_autobackups\'. Sistem akan otomatis menghapus file cadangan terlama jika jumlah file melebihi batas penumpukan.'**
  String get autoBackupNoticeDesc;

  /// No description provided for @autoBackupDisableWarning.
  ///
  /// In id, this message translates to:
  /// **'PERHATIAN: Menonaktifkan auto-backup berarti data Anda tidak akan dicadangkan secara otomatis dan berisiko hilang jika aplikasi terhapus.'**
  String get autoBackupDisableWarning;

  /// No description provided for @autoBackupFileHeading.
  ///
  /// In id, this message translates to:
  /// **'File Cadangan Lokal'**
  String get autoBackupFileHeading;

  /// No description provided for @autoBackupConfirmRestoreTitle.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Restore'**
  String get autoBackupConfirmRestoreTitle;

  /// No description provided for @autoBackupConfirmRestoreWarning.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin memulihkan file cadangan ini? Semua data saat ini akan ditimpa.'**
  String get autoBackupConfirmRestoreWarning;

  /// No description provided for @autoBackupRestoreSuccess.
  ///
  /// In id, this message translates to:
  /// **'Data berhasil dipulihkan!'**
  String get autoBackupRestoreSuccess;

  /// No description provided for @autoBackupNoFiles.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada file cadangan lokal ditemukan'**
  String get autoBackupNoFiles;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
