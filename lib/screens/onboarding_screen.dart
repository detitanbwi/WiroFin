import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import '../core/services/preference_service.dart';
import '../services/database_helper.dart';
import '../services/backup_service.dart';
import 'package:intl/intl.dart';
import 'terms_screen.dart';
import '../widgets/top_toast.dart';
import '../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _walletController = TextEditingController(text: 'Tunai');
  int _currentPage = 0;

  static const Map<String, String> supportedApps = {
    'mybca': 'myBCA',
    'bca_mobile': 'BCA Mobile',
    'brimo': 'BRImo (BRI)',
    'livin': 'Livin\' by Mandiri',
    'bni': 'BNI Mobile',
    'jago': 'Bank Jago',
    'allobank': 'Allo Bank',
    'btn': 'BTN Mobile',
    'jenius': 'Jenius',
    'dana': 'DANA',
    'wirofin_sim': 'Simulasi WiroFin (Debug)',
  };

  // State data
  String _userName = '';
  String _walletName = 'Tunai';
  String _initialBalanceStr = '0';
  bool _isLoading = false;
  bool _termsAccepted = false;

  List<dynamic> _installedApps = [];
  bool _loadingInstalledApps = true;
  String? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  Future<void> _loadInstalledApps() async {
    try {
      const channel = MethodChannel('com.wirodev.wirofin/auto_track');
      final List<dynamic>? list = await channel.invokeMethod('getInstalledBankingApps');
      if (list != null) {
        setState(() {
          _installedApps = list;
          _loadingInstalledApps = false;
        });
      } else {
        setState(() => _loadingInstalledApps = false);
      }
    } catch (_) {
      setState(() => _loadingInstalledApps = false);
    }
  }

  List<DropdownMenuItem<String?>> _buildDropdownItems() {
    final List<DropdownMenuItem<String?>> items = [];
    items.add(
      const DropdownMenuItem<String?>(
        value: null,
        child: Row(
          children: [
            Icon(Icons.link_off, color: Colors.grey, size: 20),
            SizedBox(width: 8),
            Text('Tidak Terhubung'),
          ],
        ),
      ),
    );

    final installedKeys = _installedApps.map((a) => a['appKey'] as String).toSet();

    // 1. Add Installed Apps first
    for (var app in _installedApps) {
      items.add(
        DropdownMenuItem<String?>(
          value: app['appKey'] as String,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.memory(
                  app['icon'] as Uint8List,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  app['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.check_circle, color: Colors.green, size: 14),
            ],
          ),
        ),
      );
    }

    // 2. Add uninstalled supported apps
    supportedApps.forEach((key, name) {
      if (!installedKeys.contains(key)) {
        items.add(
          DropdownMenuItem<String?>(
            value: key,
            child: Row(
              children: [
                const Icon(Icons.account_balance_outlined, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(color: Colors.grey.shade600, overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(Belum Terpasang)',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      }
    });

    return items;
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    setState(() => _isLoading = true);
    try {
      // Save user name
      final name = _nameController.text.trim();
      await PreferenceService.instance.setUserName(name.isEmpty ? 'User' : name);
      
      // Save initial wallet
      final int balance = int.tryParse(_initialBalanceStr) ?? 0;
      final walletName = _walletController.text.trim();
      await DatabaseHelper.instance.insertAccount({
        'name': walletName.isEmpty ? 'Tunai' : walletName,
        'type': 'personal',
        'balance': balance,
        'linked_package': _selectedPackage,
      });

      // Mark as not first launch
      await PreferenceService.instance.setFirstLaunch(false);
      
      widget.onFinish();
    } catch (e) {
      TopToast.show(context, 'Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importData() async {
    final success = await BackupService.instance.importData();
    if (success && mounted) {
      await PreferenceService.instance.setFirstLaunch(false);
      widget.onFinish();
    }
  }
  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildChoicePage(),
                  _buildProfilePage(),
                  _buildWidgetIntroPage(),
                  _buildWalletSetupPage(),
                  _buildAutoTrackSetupPage(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: ValueListenableBuilder<Locale>(
                valueListenable: PreferenceService.instance.localeNotifier,
                builder: (context, locale, child) {
                  return SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'id',
                        label: Text('🇮🇩 ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      ButtonSegment<String>(
                        value: 'en',
                        label: Text('🇬🇧 EN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    selected: {locale.languageCode},
                    onSelectionChanged: (Set<String> newSelection) {
                      final lang = newSelection.first;
                      PreferenceService.instance.setLanguage(lang);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.orange.shade100;
                        }
                        return Colors.white;
                      }),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(32),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/onboarding1.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.account_balance_wallet, size: 100, color: Colors.teal.shade600),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              AppLocalizations.of(context)?.onboardingTitle1 ?? 'Kelola Uang Lebih Baik',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context)?.onboardingSubtitle1 ?? 'Pantau pengeluaran, atur kategori, dan simpan data Anda secara offline dengan aman.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 38),
            // Terms and Conditions Checkbox
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    activeColor: Colors.orange,
                    onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TermsScreen()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                          children: [
                            TextSpan(text: AppLocalizations.of(context)?.agreeTerms ?? 'Saya menyetujui '),
                            TextSpan(
                              text: AppLocalizations.of(context)?.termsConditions ?? 'Syarat & Ketentuan',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: AppLocalizations.of(context)?.usageWiroFin ?? ' penggunaan WiroFin.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoicePage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              AppLocalizations.of(context)?.startJourney ?? 'Mulai Perjalanan Anda',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 48),
            _buildActionCard(
              icon: Icons.add_circle_outline,
              title: AppLocalizations.of(context)?.startFresh ?? 'Mulai dari Awal',
              subtitle: AppLocalizations.of(context)?.startFreshDesc ?? 'Buat akun baru dan atur profil Anda.',
              color: Colors.teal,
              onTap: _nextPage,
            ),
            const SizedBox(height: 24),
            _buildActionCard(
              icon: Icons.restore,
              title: AppLocalizations.of(context)?.importOldData ?? 'Import Data Lama',
              subtitle: AppLocalizations.of(context)?.importOldDataDesc ?? 'Pulihkan data dari file backup JSON.',
              color: Colors.orange,
              onTap: _importData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required String subtitle, required MaterialColor color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: color.shade200, width: 2),
          borderRadius: BorderRadius.circular(16),
          color: color.shade50,
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color.shade900)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: color.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_outline, size: 80, color: Colors.blue.shade600),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)?.whatsYourName ?? 'Siapa nama Anda?',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.nameGreetingDesc ?? 'Nama ini akan digunakan untuk menyapa Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _nameController,
              onChanged: (val) => _userName = val,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)?.enterName ?? 'Masukkan nama',
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.4)),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.teal, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 100), // Space for keyboard
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSetupPage() {
    final formatter = NumberFormat('#,###', 'id_ID');
    final formattedBalance = _initialBalanceStr.isEmpty ? '0' : formatter.format(int.parse(_initialBalanceStr));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)?.mainAccount ?? 'Rekening Utama',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.enterInitialBalance ?? 'Masukkan saldo awal Anda saat ini.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (val) => _walletName = val,
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: AppLocalizations.of(context)?.accountNameHint ?? 'Nama Rekening (Misal: BCA / Tunai)',
                            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.4)),
                          ),
                          controller: _walletController,
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Rp $formattedBalance',
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.teal.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: _buildNumpad(),
        ),
      ],
    );
  }

  Widget _buildNumpad() {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: 52,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              if (index == 9) return const SizedBox.shrink(); // Empty slot
              if (index == 11) {
                return IconButton(
                  icon: const Icon(Icons.backspace_outlined, color: Colors.redAccent),
                  onPressed: () {
                    setState(() {
                      if (_initialBalanceStr.isNotEmpty) {
                        _initialBalanceStr = _initialBalanceStr.substring(0, _initialBalanceStr.length - 1);
                        if (_initialBalanceStr.isEmpty) _initialBalanceStr = '0';
                      }
                    });
                  },
                );
              }
              final number = index == 10 ? 0 : index + 1;
              return TextButton(
                onPressed: () {
                  setState(() {
                    if (_initialBalanceStr == '0') {
                      _initialBalanceStr = number.toString();
                    } else if (_initialBalanceStr.length < 12) {
                      _initialBalanceStr += number.toString();
                    }
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  number.toString(),
                  style: const TextStyle(fontSize: 22, color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetIntroPage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text('WiroFin Widget', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(AppLocalizations.of(context)?.widgetStatus ?? 'Live', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Rp 12.500.000', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)?.totalBalanceAvailable ?? 'Total Saldo Tersedia', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text(
              AppLocalizations.of(context)?.instantRecordingWidget ?? 'Pencatatan Instan via Widget',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.widgetDesc ?? 'Pantau performa keuangan dan total saldo Anda langsung dari layar utama HP tanpa repot membuka aplikasi setiap saat.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoTrackSetupPage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bolt, size: 60, color: Colors.orange.shade600),
            ),
            const SizedBox(height: 24),
            const Text(
              'Otomatisasi Catatan Transaksi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'WiroFin dapat memantau notifikasi bank Anda secara 100% lokal & offline untuk mencatat pengeluaran secara otomatis.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 32),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Hubungkan Rekening "${_walletController.text.isEmpty ? 'Tunai' : _walletController.text}" ke Aplikasi:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    _loadingInstalledApps
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String?>(
                            value: _selectedPackage,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Hubungkan Aplikasi (Auto-Track)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: _buildDropdownItems(),
                            onChanged: (val) {
                              setState(() {
                                _selectedPackage = val;
                              });
                            },
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Anda juga bisa melewatinya dengan memilih "Tidak Terhubung" dan mengaturnya nanti di menu Pengaturan Rekening.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button or Indicator
          if (_currentPage > 0)
            TextButton.icon(
              onPressed: _prevPage,
              icon: const Icon(Icons.arrow_back, size: 20),
              label: Text(AppLocalizations.of(context)?.back ?? 'Kembali'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            )
          else
            const SizedBox(width: 100), // Placeholder for symmetry

          // Dots indicator
          Row(
            children: List.generate(6, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 6,
                width: _currentPage == index ? 20 : 6,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.orange : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          // Next/Finish Button
          if (_currentPage != 1)
            ElevatedButton(
              onPressed: (_isLoading || (_currentPage == 0 && !_termsAccepted)) ? null : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      _currentPage == 5 
                        ? (AppLocalizations.of(context)?.finish ?? 'Selesai')
                        : (AppLocalizations.of(context)?.next ?? 'Lanjut'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            )
          else
            const SizedBox(width: 100),
        ],
      ),
    );
  }
}
