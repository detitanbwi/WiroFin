import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

class AutoTrackSettingsPage extends StatefulWidget {
  const AutoTrackSettingsPage({super.key});

  @override
  State<AutoTrackSettingsPage> createState() => _AutoTrackSettingsPageState();
}

class _AutoTrackSettingsPageState extends State<AutoTrackSettingsPage> with WidgetsBindingObserver {
  static const MethodChannel _channel = MethodChannel('com.wirodev.wirofin/auto_track');
  bool _isEnabled = false;
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('auto_track_enabled') ?? false;
    setState(() {
      _isEnabled = isEnabled;
    });
    await _checkPermission();
  }

  Future<void> _checkPermission() async {
    try {
      final bool hasPerm = await _channel.invokeMethod('checkNotificationPermission') ?? false;
      setState(() {
        _hasPermission = hasPerm;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAutoTrack(bool value) async {
    if (value && !_hasPermission) {
      _showPermissionDialog();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_track_enabled', value);
    setState(() {
      _isEnabled = value;
    });
  }

  Future<void> _openPermissionSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } catch (_) {}
  }

  void _showPermissionDialog() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.security, color: Colors.blue),
            const SizedBox(width: 10),
            Text(loc?.autoTrackDialogTitle ?? 'Izin Akses Notifikasi', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          loc?.autoTrackDialogContent ?? 'WiroFin membutuhkan izin untuk membaca notifikasi sistem agar dapat melacak transaksi perbankan Anda secara otomatis.\n\nSemua data diproses 100% secara lokal dan offline di perangkat Anda demi menjaga keamanan data keuangan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc?.autoTrackDialogCancel ?? 'Batal', style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openPermissionSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(loc?.autoTrackDialogSettings ?? 'Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.autoTrackTitle ?? 'Otomatisasi M-Banking & E-Wallet', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Privacy Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_outlined, color: Colors.green.shade700, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc?.autoTrackPrivacyTitle ?? 'Privacy-First (100% Lokal)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green.shade800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                loc?.autoTrackPrivacyDesc ?? 'WiroFin memproses data notifikasi hanya di dalam memori lokal ponsel Anda. Tidak ada data transaksi atau informasi pribadi yang dikirim ke server luar.',
                                style: TextStyle(fontSize: 13, color: Colors.green.shade700, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Main settings card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    color: Colors.grey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(loc?.autoTrackSwitch ?? 'Aktifkan Auto-Track', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Text(loc?.autoTrackSwitchDesc ?? 'Deteksi nominal transaksi dari notifikasi yang masuk secara otomatis'),
                            value: _isEnabled,
                            onChanged: _toggleAutoTrack,
                            activeColor: Colors.blue,
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(loc?.autoTrackPermission ?? 'Izin Akses Notifikasi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Text(_hasPermission 
                                ? (loc?.autoTrackPermissionActive ?? 'Izin telah diberikan') 
                                : (loc?.autoTrackPermissionInactive ?? 'Izin belum diaktifkan')),
                            trailing: _hasPermission
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : ElevatedButton(
                                    onPressed: _openPermissionSettings,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(loc?.autoTrackPermissionBtn ?? 'Aktifkan'),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Supported list title
                  Text(
                    loc?.autoTrackSupportedApps ?? 'Aplikasi yang Didukung:',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 12),
                  
                  // Grid / Wrap of apps
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildAppTag('BCA Mobile'),
                      _buildAppTag('myBCA'),
                      _buildAppTag('BRImo'),
                      _buildAppTag('Livin\' Mandiri'),
                      _buildAppTag('BNI Mobile'),
                      _buildAppTag('Bank Jago'),
                      _buildAppTag('Allo Bank'),
                      _buildAppTag('BTN Mobile'),
                      _buildAppTag('Jenius'),
                      _buildAppTag('DANA'),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAppTag(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        name,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
      ),
    );
  }
}
