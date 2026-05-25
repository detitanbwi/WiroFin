import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'widgets/top_toast.dart';
import 'widgets/nlp_input_dialog.dart';
import 'screens/transaction_list_screen.dart';
import 'screens/master_data_screen.dart';
import 'widgets/transaction_bottom_sheet.dart';
import 'widgets/expense_statistics_card.dart';
import 'services/database_helper.dart';
import 'services/sync_service.dart';
import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'domain/repositories/expense_repository.dart';
import 'core/services/preference_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/about_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme/theme_notifier.dart';
import 'services/widget_service.dart';
import 'package:home_widget/home_widget.dart';



import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:http/http.dart' as http;



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceService.instance.init();
  runApp(const WiroFinApp());
}

class WiroFinApp extends StatefulWidget {
  const WiroFinApp({super.key});

  @override
  State<WiroFinApp> createState() => _WiroFinAppState();
}

class _WiroFinAppState extends State<WiroFinApp> {
  bool _isFirstLaunch = PreferenceService.instance.isFirstLaunch;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: PreferenceService.instance.localeNotifier,
      builder: (context, locale, child) {
        return ListenableBuilder(
          listenable: ThemeNotifier.instance,
          builder: (context, child) {
            return MaterialApp(
              title: 'WiroFin',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('id'),
                Locale('en'),
              ],
              locale: locale,
              theme: ThemeNotifier.instance.currentTheme,
              home: _isFirstLaunch
                  ? OnboardingScreen(
                      onFinish: () {
                        setState(() {
                          _isFirstLaunch = false;
                        });
                      },
                    )
                  : const DashboardScreen(),
            );
          },
        );
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String _activeMode;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _categoryData = [];
  List<Map<String, dynamic>> _trendData = [];
  bool _isLoading = true;
  String _userName = 'User';
  DateTime? _startDate;
  DateTime? _endDate;
  int _totalInitialBalance = 0;

  @override
  void initState() {
    super.initState();
    _activeMode = PreferenceService.instance.activeMode;
    _userName = PreferenceService.instance.userName;
    _loadTransactions();
    _initWidgetListener();
    // Refresh UI otomatis saat sinkronisasi background selesai
    if (!AppConfig.instance.isOfflineMode) {
      SyncService.instance.onSyncComplete = _loadTransactions;
      SyncService.instance.init();
    }
    _checkUpdate().then((hasUpdate) {
      if (!hasUpdate) {
        _checkWhatsNew();
      }
    });
  }

  Future<void> _checkWhatsNew() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final lastSeenVersion = PreferenceService.instance.lastSeenVersion;

    if (lastSeenVersion.isEmpty && !PreferenceService.instance.isFirstLaunch) {
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 600));
        _showWhatsNewModal();
        await PreferenceService.instance.setLastSeenVersion(currentVersion);
      }
    } else if (lastSeenVersion.isNotEmpty && lastSeenVersion != currentVersion && !PreferenceService.instance.isFirstLaunch) {
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 600));
        _showWhatsNewModal();
        await PreferenceService.instance.setLastSeenVersion(currentVersion);
      }
    } else if (lastSeenVersion.isEmpty && PreferenceService.instance.isFirstLaunch) {
      await PreferenceService.instance.setLastSeenVersion(currentVersion);
    }
  }

  void _showWhatsNewModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 6)),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.widgets_outlined, size: 56, color: Colors.white),
                          SizedBox(height: 12),
                          Text(
                            'WiroFin Widget',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Baru! Pantau keuangan langsung dari layar HP Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kini Anda dapat memasang widget WiroFin di beranda HP untuk melihat saldo dan mencatat transaksi secara instan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Tutup', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const WidgetGuidePage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cara Pasang', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _checkUpdate() async {
    try {
      // 1. Cek koneksi internet terlebih dahulu (hanya ketika ada internet)
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.isEmpty || connectivityResult.contains(ConnectivityResult.none)) {
        debugPrint('Tidak ada koneksi internet, melewati pengecekan update.');
        return false;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final localVersion = packageInfo.version;

      // Cek apakah ada simulasi paksa versi baru dari mode testing
      final forcedRemoteVer = PreferenceService.instance.forcedRemoteVersion;
      if (forcedRemoteVer.isNotEmpty && _isVersionGreater(forcedRemoteVer, localVersion)) {
        if (mounted) {
          _showUpdateDialog();
        }
        return true;
      }

      bool updateTriggered = false;

      // 2. Coba gunakan InAppUpdate resmi dari Google Play Core API
      try {
        final updateInfo = await InAppUpdate.checkForUpdate();
        if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
          if (updateInfo.immediateUpdateAllowed) {
            await InAppUpdate.performImmediateUpdate();
            updateTriggered = true;
          } else if (updateInfo.flexibleUpdateAllowed) {
            await InAppUpdate.startFlexibleUpdate();
            await InAppUpdate.completeFlexibleUpdate();
            updateTriggered = true;
          }
        }
      } catch (e) {
        debugPrint('InAppUpdate native check failed (mungkin sideload/debug): $e');
      }

      if (updateTriggered) return true;

      // 3. Fallback manual check: periksa halaman Play Store dan tampilkan popup custom
      try {
        final res = await http.get(Uri.parse('https://play.google.com/store/apps/details?id=com.wirodev.wirofin')).timeout(const Duration(seconds: 7));
        if (res.statusCode == 200) {
          final packageInfo = await PackageInfo.fromPlatform();
          final localVersion = packageInfo.version;

          String? remoteVersion;
          // Cari pola versi semacam "1.2.0" di dalam body HTML Play Store
          final regExp = RegExp(r'"(\d+\.\d+\.\d+)"');
          final matches = regExp.allMatches(res.body);
          for (final match in matches) {
            final ver = match.group(1);
            if (ver != null && _isValidVersion(ver)) {
              if (_isVersionGreater(ver, localVersion)) {
                remoteVersion = ver;
                break;
              }
            }
          }

          if (remoteVersion != null && _isVersionGreater(remoteVersion, localVersion)) {
            if (mounted) {
              _showUpdateDialog();
            }
            return true;
          }
        }
      } catch (e) {
        debugPrint('Fallback scraping check failed: $e');
      }
    } catch (e) {
      debugPrint('Error in _checkUpdate: $e');
    }
    return false;
  }

  bool _isValidVersion(String ver) {
    final parts = ver.split('.');
    if (parts.length != 3) return false;
    for (final p in parts) {
      if (int.tryParse(p) == null) return false;
    }
    return true;
  }

  bool _isVersionGreater(String remote, String local) {
    try {
      List<int> remoteParts = remote.split('.').map(int.parse).toList();
      List<int> localParts = local.split('.').map(int.parse).toList();
      for (int i = 0; i < 3; i++) {
        if (remoteParts[i] > localParts[i]) return true;
        if (remoteParts[i] < localParts[i]) return false;
      }
    } catch (_) {}
    return false;
  }

  void _showUpdateDialog() {
    final isDemo = AppConfig.instance.enableDebugTools && PreferenceService.instance.forcedRemoteVersion.isNotEmpty;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {},
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppLocalizations.of(context)?.updateAvailableTitle ?? 'Update Tersedia!', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            AppLocalizations.of(context)?.updateAvailableMessage ?? 'Versi terbaru WiroFin sudah tersedia di Play Store. Silakan update untuk melanjutkan menggunakan aplikasi.',
          ),
          actions: [
            if (isDemo)
              TextButton(
                onPressed: () async {
                  await PreferenceService.instance.setForcedRemoteVersion('');
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  _checkWhatsNew();
                },
                child: const Text('Tutup Simulasi', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: Text(AppLocalizations.of(context)?.exit ?? 'Keluar', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () async {
                final url = Uri.parse('https://play.google.com/store/apps/details?id=com.wirodev.wirofin');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(AppLocalizations.of(context)?.updateNow ?? 'Update Sekarang', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _initWidgetListener() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then((Uri? uri) {
      if (uri != null && uri.host == 'add_transaction') {
        _triggerNlpFromWidget();
      }
    });

    HomeWidget.widgetClicked.listen((Uri? uri) {
      if (uri != null && uri.host == 'add_transaction') {
        _triggerNlpFromWidget();
      }
    });
  }

  void _triggerNlpFromWidget() async {
    final res = await NlpInputDialog.show(context, activeMode: _activeMode);
    if (res != null && mounted) {
      _openTransactionSheet(initialTransaction: {
        'amount': res.amount,
        'description': res.description,
        'category_id': res.categoryId,
        'transaction_type': res.transactionType,
        'date': res.date.toIso8601String(),
      });
    }
  }

  Future<void> _loadTransactions({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    final data = await getIt<ExpenseRepository>().getExpenses(
      type: _activeMode,
      startDate: _startDate,
      endDate: _endDate,
    );
    final catData = await DatabaseHelper.instance.getCategoryExpenses(
      _activeMode,
      transactionType: 'expense',
      startDate: _startDate,
      endDate: _endDate,
    );
    final trendData = await DatabaseHelper.instance.getDailyExpensesTrend(
      _activeMode,
      transactionType: 'expense',
      startDate: _startDate,
      endDate: _endDate,
    );
    final accounts = await DatabaseHelper.instance.getAccounts(_activeMode);
    final totalInitBalance = accounts.fold<int>(0, (sum, acc) => sum + ((acc['balance'] as num?)?.toInt() ?? 0));

    setState(() {
      _transactions = List<Map<String, dynamic>>.from(data).map((item) {
        return {
          ...item,
          'date': DateTime.parse(item['date']),
        };
      }).toList();
      _categoryData = catData;
      _trendData = trendData;
      _totalInitialBalance = totalInitBalance;
      _isLoading = false;
    });

    WidgetService.syncDataToWidget(_activeMode);
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF00367D),
              onPrimary: Colors.white,
              onSurface: const Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadTransactions(silent: true);
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadTransactions(silent: true);
  }

  void _openTransactionSheet({Map<String, dynamic>? initialTransaction}) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 24,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TransactionBottomSheet(
          activeMode: _activeMode,
          initialTransaction: initialTransaction,
        ),
      ),
    );

    if (result != null) {
      await getIt<ExpenseRepository>().saveExpense({
        'amount': result['amount'],
        'description': result['description'],
        'category_id': result['category_id'],
        'account_id': result['account_id'],
        'date': DateTime.now().toIso8601String(),
        'type': result['type'],
        'transaction_type': result['transaction_type'] ?? 'expense',
      });
      await _loadTransactions();
      if (mounted) {
        if (!PreferenceService.instance.hasCreatedFirstTransaction) {
          await PreferenceService.instance.setHasCreatedFirstTransaction(true);
          if (mounted) {
            TopToast.show(context, 'Suka kemudahan ini? Tekan lama layar HP Anda untuk memasang widget WiroFin!', duration: const Duration(seconds: 5));
          }
        } else {
          TopToast.show(context, AppLocalizations.of(context)?.successSaveTransaction ?? 'Transaksi berhasil tersimpan');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Filter transactions based on active mode
    final filteredTransactions = _transactions.where((t) => t['type'] == _activeMode).toList();
    
    // Calculate total income, expense, and net balance
    final totalIncome = filteredTransactions
        .where((t) => t['transaction_type'] == 'income')
        .fold<int>(0, (sum, item) => sum + (item['amount'] as int));
    final totalExpense = filteredTransactions
        .where((t) => (t['transaction_type'] ?? 'expense') == 'expense')
        .fold<int>(0, (sum, item) => sum + (item['amount'] as int));
    final netBalance = _totalInitialBalance + totalIncome - totalExpense;
    
    final formatter = NumberFormat('#,###', 'id_ID');
    final Color themeColor = _activeMode == 'personal' ? Colors.orange.shade600 : Colors.teal.shade600;
    final loc = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.grey.shade300,
      ),
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          final bool shouldPop = await _showExitConfirmation(context) ?? false;
          if (shouldPop) {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColorDark,
                      Theme.of(context).primaryColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SafeArea(
                child: ListView(
                  children: [
                    // Header & Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${loc.greetingPrefix}, $_userName',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Text(
                                'Expense Tracker',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.settings, color: Colors.white70),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MasterDataScreen(activeMode: _activeMode),
                                    ),
                                  ).then((_) {
                                    setState(() {
                                      _userName = PreferenceService.instance.userName;
                                    });
                                    _loadTransactions();
                                  });
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  child: const Icon(Icons.info_outline, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Custom Toggle
                      Container(
                        height: 50,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                        ),
                        child: Stack(
                          children: [
                            // Animated Background Pill
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: _activeMode == 'personal' ? Alignment.centerLeft : Alignment.centerRight,
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _activeMode = 'personal');
                                      PreferenceService.instance.setActiveMode('personal');
                                      ThemeNotifier.instance.toggleMode('personal');
                                      _loadTransactions(silent: true);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Center(
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 300),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                          color: _activeMode == 'personal' ? Colors.orange.shade700 : Colors.white70,
                                          fontSize: 12,
                                        ),
                                        child: Text(loc.personalMode.toUpperCase()),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _activeMode = 'company');
                                      PreferenceService.instance.setActiveMode('company');
                                      ThemeNotifier.instance.toggleMode('company');
                                      _loadTransactions(silent: true);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Center(
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 300),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                          color: _activeMode == 'company' ? Colors.teal.shade700 : Colors.white70,
                                          fontSize: 12,
                                        ),
                                        child: Text(loc.companyMode.toUpperCase()),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Date Filter Row
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _showDateRangePicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                                    const SizedBox(width: 12),
                                    Text(
                                      _startDate == null 
                                        ? loc.allTime 
                                        : '${DateFormat('dd MMM').format(_startDate!)} - ${DateFormat('dd MMM').format(_endDate!)}',
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_startDate != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: _clearDateFilter,
                              tooltip: loc.cancel,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Dismissible Info Card
                if (!PreferenceService.instance.isWidgetCardDismissed)
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _activeMode == 'personal' ? const Color(0xFFDBEAFE) : const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _activeMode == 'personal' ? Colors.blue.shade200 : Colors.teal.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.widgets, color: _activeMode == 'personal' ? Colors.blue.shade700 : Colors.teal.shade700, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ingin catat transaksi lebih cepat?',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: _activeMode == 'personal' ? Colors.blue.shade900 : Colors.teal.shade900, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pasang Widget WiroFin di layar depan.',
                                  style: TextStyle(color: _activeMode == 'personal' ? Colors.blue.shade800 : Colors.teal.shade800, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: _activeMode == 'personal' ? Colors.blue.shade700 : Colors.teal.shade700, size: 20),
                            onPressed: () async {
                              await PreferenceService.instance.setWidgetCardDismissed(true);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                // Balance Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(
                            color: themeColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.netBalance.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    loc.liveUpdate,
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${netBalance < 0 ? '-' : ''}Rp ${formatter.format(netBalance.abs())}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 1,
                              width: double.infinity,
                              color: Colors.white12,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.arrow_downward, size: 12, color: Colors.greenAccent),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            loc.income.toUpperCase(),
                                            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '+Rp ${formatter.format(totalIncome)}',
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 35, color: Colors.white12),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.arrow_upward, size: 12, color: Colors.redAccent),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            loc.expense.toUpperCase(),
                                            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '-Rp ${formatter.format(totalExpense)}',
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Statistics
                if (_categoryData.isNotEmpty || _trendData.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ExpenseStatisticsCard(
                      categoryData: _categoryData,
                      trendData: _trendData,
                      themeColor: themeColor,
                      title: loc.expenseDistribution,
                    ),
                  ),

                const SizedBox(height: 24),

                // Transaction List
                Container(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              loc.transactionHistory,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TransactionListScreen(
                                      transactions: _transactions,
                                      activeMode: _activeMode,
                                      onRefresh: _loadTransactions,
                                    ),
                                  ),
                                ).then((_) => _loadTransactions());
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  loc.seeAll,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: themeColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (filteredTransactions.isEmpty) 
                        Padding(
                          padding: const EdgeInsets.all(64.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  loc.emptyTransaction,
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          itemCount: filteredTransactions.length > 5 ? 5 : filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final item = filteredTransactions[index];
                            final isIncome = item['transaction_type'] == 'income';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                      color: isIncome ? Colors.green.shade600 : Colors.red.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['category'] ?? 'Kategori...',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                            ),
                                            if (!AppConfig.instance.isOfflineMode) ...[
                                              if (item['sync_status'] == 'syncing')
                                                const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                                                )
                                              else if (item['sync_status'] == 'pending')
                                                Icon(Icons.cloud_queue, size: 14, color: Colors.grey.shade400),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          (item['description'] == null || item['description'].isEmpty) 
                                            ? (item['account'] ?? 'Pilih Akun...') 
                                            : item['description'],
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isIncome ? '+' : '-'} Rp ${formatter.format(item['amount'])}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isIncome ? Colors.green.shade600 : Colors.red.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // padding for FAB so it doesn't overlap content
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'nlp_fab',
            onPressed: () async {
              final res = await NlpInputDialog.show(context, activeMode: _activeMode);
              if (res != null) {
                _openTransactionSheet(initialTransaction: {
                  'amount': res.amount,
                  'description': res.description,
                  'category_id': res.categoryId,
                  'transaction_type': res.transactionType,
                  'date': res.date.toIso8601String(),
                });
              }
            },
            backgroundColor: Colors.deepPurple.shade600,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.auto_awesome, color: Colors.white),
            label: const Text('NLP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'add_fab',
            onPressed: _openTransactionSheet,
            backgroundColor: themeColor,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        final loc = AppLocalizations.of(context)!;
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.exit_to_app, size: 40, color: Colors.orange.shade600),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.exitAppTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.exitAppMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            loc.cancel,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            loc.exit,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
