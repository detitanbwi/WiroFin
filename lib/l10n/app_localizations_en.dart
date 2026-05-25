// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'WiroFin';

  @override
  String get greetingPrefix => 'Hello';

  @override
  String get personalMode => 'Personal';

  @override
  String get companyMode => 'Company';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get masterData => 'Master Data';

  @override
  String get allTime => 'All Time';

  @override
  String get netBalance => 'Net Balance';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get liveUpdate => 'Live';

  @override
  String get expenseDistribution => 'Expense Distribution';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get seeAll => 'See All';

  @override
  String get exitAppTitle => 'Exit App';

  @override
  String get exitAppMessage => 'Are you sure you want to exit Wirofin?';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get recordTransaction => 'Record Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get amount => 'Amount';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Are you sure you want to delete this?';

  @override
  String get successSave => 'Data successfully saved';

  @override
  String get successDelete => 'Data successfully deleted';

  @override
  String get successUpdate => 'Data successfully updated';

  @override
  String get successSaveTransaction => 'Transaction saved successfully';

  @override
  String get amountEmptyError => 'Amount cannot be empty';

  @override
  String get nlpTitle => 'Smart Recording (NLP)';

  @override
  String get nlpSubtitle =>
      'Type naturally, WiroFin will fill it in automatically';

  @override
  String get nlpExampleHint => 'Example: Bought gas for 50k yesterday...';

  @override
  String get nlpTrySentence => 'Try the following sentence:';

  @override
  String get nlpSample1 => 'Bought coffee at Kopi Kenangan for 28k';

  @override
  String get nlpSample2 => 'Monthly salary received: 5 million';

  @override
  String get nlpSample3 => 'Bought Pertamax fuel for 50k yesterday';

  @override
  String get nlpSample4 => 'Had lunch at warteg for 20000';

  @override
  String get nlpErrorNoAmount => 'Transaction amount not found';

  @override
  String get nlpErrorProcess => 'Failed to process sentence';

  @override
  String get allTransactionsTitle => 'All Transactions';

  @override
  String get showingAll => 'Showing All';

  @override
  String get filterLabel => 'Filter';

  @override
  String get transactionCountLabel => 'Transaction';

  @override
  String get successUpdateTransaction => 'Transaction updated successfully';

  @override
  String get deleteTransactionTitle => 'Delete Transaction';

  @override
  String get confirmDeleteTransaction =>
      'Are you sure you want to delete this transaction?';

  @override
  String get successDeleteTransaction => 'Transaction deleted successfully';

  @override
  String get emptyTransaction => 'No transactions yet';

  @override
  String get aboutWiroFin => 'About WiroFin';

  @override
  String get versionLabel => 'Version';

  @override
  String get developerLabel => 'Developer';

  @override
  String get createdOnLabel => 'Created On';

  @override
  String get licenseLabel => 'License';

  @override
  String get freeToUseLabel => 'Free to Use';

  @override
  String get legalLabel => 'Legal';

  @override
  String get websiteLabel => 'Website';

  @override
  String get userProfile => 'User Profile';

  @override
  String get bankAccountManagement => 'Bank Account Management';

  @override
  String get transactionCategory => 'Transaction Category';

  @override
  String get dataBackupRestore => 'Data Backup (Backup & Restore)';

  @override
  String get profile => 'Profile';

  @override
  String get usernameLabel => 'Username';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get successSaveProfile => 'Profile Saved Successfully';

  @override
  String get language => 'Language';

  @override
  String get languageSwitch => 'Indonesia / English';

  @override
  String get addBankAccount => 'Add Bank Account';

  @override
  String get editBankAccount => 'Edit Bank Account';

  @override
  String get bankAccountName => 'Bank Account Name';

  @override
  String get initialBalance => 'Initial Balance';

  @override
  String get deleteDataTitle => 'Delete Data';

  @override
  String get confirmDeleteAccount =>
      'Are you sure you want to delete this bank account?';

  @override
  String get successSaveAccount => 'Account saved successfully';

  @override
  String get successDeleteAccount => 'Account deleted successfully';

  @override
  String get emptyAccount => 'No bank account data yet';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get transactionType => 'Transaction Type';

  @override
  String get confirmDeleteCategory =>
      'Are you sure you want to delete this category?';

  @override
  String get successSaveCategory => 'Category saved successfully';

  @override
  String get successDeleteCategory => 'Category deleted successfully';

  @override
  String get emptyCategory => 'No category data yet';

  @override
  String get defaultCategoryError =>
      'Default category \"Other\" cannot be deleted.';

  @override
  String get defaultLabel => 'Default';

  @override
  String get backupRestoreTitle => 'Backup & Restore Data';

  @override
  String get backupRestoreDesc =>
      'Save your data to a local file so it can be restored later';

  @override
  String get exportJson => 'Export Data to JSON';

  @override
  String get importJson => 'Import Data from JSON';

  @override
  String get successExport => 'Data Successfully exported to ';

  @override
  String get confirmRestoreTitle => 'Confirm Restore';

  @override
  String get confirmRestoreWarning =>
      'WARNING: Importing data will delete all current data and replace it with the contents of the backup file. Continue?';

  @override
  String get continueLabel => 'Continue';

  @override
  String get successImport => 'Data imported successfully!';

  @override
  String get voiceRecord => 'Voice/Text Recording';

  @override
  String get onboardingTitle1 => 'Manage Money Better';

  @override
  String get onboardingSubtitle1 =>
      'Track expenses, manage categories, and store your data securely offline.';

  @override
  String get agreeTerms => 'I agree to the ';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get usageWiroFin => ' of WiroFin.';

  @override
  String get startJourney => 'Start Your Journey';

  @override
  String get startFresh => 'Start Fresh';

  @override
  String get startFreshDesc => 'Create a new account and set up your profile.';

  @override
  String get importOldData => 'Import Existing Data';

  @override
  String get importOldDataDesc => 'Restore your data from a JSON backup file.';

  @override
  String get whatsYourName => 'What is your name?';

  @override
  String get nameGreetingDesc => 'This name will be used to greet you.';

  @override
  String get enterName => 'Enter your name';

  @override
  String get mainAccount => 'Main Account';

  @override
  String get enterInitialBalance => 'Enter your current initial balance.';

  @override
  String get accountNameHint => 'Account Name (e.g., BCA / Cash)';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get updateAvailableTitle => 'Update Available!';

  @override
  String get updateAvailableMessage =>
      'A new version of WiroFin is available on the Play Store. Please update to continue using the application.';

  @override
  String get updateNow => 'Update Now';

  @override
  String get widgetStatus => 'Live';

  @override
  String get totalBalanceAvailable => 'Total Balance Available';

  @override
  String get instantRecordingWidget => 'Instant Recording via Widget';

  @override
  String get widgetDesc =>
      'Monitor your financial performance and total balance directly from your phone\'s home screen without the hassle of opening the app every time.';

  @override
  String get termsConditionsTitle => 'Terms & Condition';

  @override
  String get termsConditionsSubtitle => 'WiroFin Terms and Conditions of Use';

  @override
  String get termsLastUpdated => 'Last updated: May 11, 2026';

  @override
  String get termsSec1Title => '1. Acceptance of Terms';

  @override
  String get termsSec1Content =>
      'By downloading or using the WifoFin app, you automatically agree to all the terms and conditions written here. If you do not agree, please stop using the app immediately.';

  @override
  String get termsSec2Title => '2. App Usage';

  @override
  String get termsSec2Content =>
      'This app is provided to help you with personal and business financial logging. You are fully responsible for the accuracy of the data you enter.';

  @override
  String get termsSec3Title => '3. Limitation of Liability';

  @override
  String get termsSec3Content =>
      'WIROFIN IS PROVIDED \"AS IS\" WITHOUT ANY WARRANTY. ANY LOSSES FROM USING THIS APPLICATION ARE ENTIRELY THE USER\'S RESPONSIBILITY. WE ARE NOT LIABLE FOR DATA LOSS, CALCULATION ERRORS, OR ANY FINANCIAL IMPACT ARISING FROM THE USE OF THIS APP.';

  @override
  String get termsSec4Title => '4. Data Security';

  @override
  String get termsSec4Content =>
      'In offline mode, your data is stored locally on your device. You are responsible for backing up your own data.';

  @override
  String get termsSec5Title => '5. Changes to Service';

  @override
  String get termsSec5Content =>
      'We reserve the right to modify or terminate the app service at any time without prior notice.';

  @override
  String get widgetGuideTitle => 'Widget Installation Guide';

  @override
  String get widgetHomeScreenTitle => 'WiroFin Home Screen Widget';

  @override
  String get widgetHomeScreenDesc =>
      'Keep monitoring your financial health without having to open the app.';

  @override
  String get threeEasySteps => '3 Easy Installation Steps';

  @override
  String get widgetStep1Title => 'Go to the Phone\'s Home Screen';

  @override
  String get widgetStep1Desc =>
      'Close or minimize the WifoFin app and navigate to the home screen on your Android or iOS device.';

  @override
  String get widgetStep2Title => 'Press & Hold Empty Area';

  @override
  String get widgetStep2Desc =>
      'Press and hold on hold and empty area on the home screen for a few seconds until the screen settings menu or pop-up menu appears.';

  @override
  String get widgetStep3Title => 'Choose & Drag Widget';

  @override
  String get widgetStep3Desc =>
      'Tap the \"Widget\" menu (or + icon), scroll to find \"WiroFin\", then drag the vairan widget you want to the home screen.';

  @override
  String get widgetTips =>
      'Tips: The WiroFin widget will automatically adjust its color according to the mode (Personal/Company) when the application is opened.';
}
