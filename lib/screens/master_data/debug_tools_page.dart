import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/preference_service.dart';
import '../../widgets/top_toast.dart';
import 'widget_guide_page.dart';

class DebugToolsPage extends StatefulWidget {
  const DebugToolsPage({super.key});

  @override
  State<DebugToolsPage> createState() => _DebugToolsPageState();
}

class _DebugToolsPageState extends State<DebugToolsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Uji Coba & Reset Status', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Gunakan menu ini saat mode pengujian (testing/debugging) untuk mensimulasikan pembaruan versi atau mengulang notifikasi widget tanpa harus mengubah kode aplikasi.',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade900, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildDebugOption(
            icon: Icons.cloud_download_outlined,
            title: 'Simulasikan Popup Update Play Store (In-App Update)',
            subtitle: 'Munculkan seketika dialog simulasi saat terdeteksi versi baru di Google Play Store (meminta pengguna memperbarui aplikasi).',
            buttonText: 'Uji Play Store Update',
            buttonColor: Colors.purple.shade700,
            onTap: () {
              _simulatePlayStoreUpdateDialog(context);
            },
          ),
          const SizedBox(height: 16),
          _buildDebugOption(
            icon: Icons.widgets_outlined,
            title: 'Tampilkan Langsung Popup What\'s New',
            subtitle: 'Munculkan seketika pop-up dialog bergaya glassmorphism yang menginformasikan fitur baru widget WiroFin.',
            buttonText: 'Uji What\'s New',
            buttonColor: Colors.indigo.shade700,
            onTap: () {
              _simulateWhatsNewModal(context);
            },
          ),
          const SizedBox(height: 16),
          _buildDebugOption(
            icon: Icons.system_update_alt_outlined,
            title: 'Simulasikan Pembaruan Versi (Internal & Play Store)',
            subtitle: 'Reset versi tersimpan ke "dummy-v0.0.0" dan set versi Play Store ke "99.0.0" agar saat restart, sistem memicu popup versi baru otomatis.',
            buttonText: 'Reset Versi',
            buttonColor: Colors.blue.shade700,
            onTap: () async {
              await PreferenceService.instance.setLastSeenVersion('dummy-v0.0.0');
              await PreferenceService.instance.setForcedRemoteVersion('99.0.0');
              if (mounted) {
                TopToast.show(context, 'Versi berhasil direset! Restart aplikasi untuk memicu popup otomatis.');
              }
            },
          ),
          const SizedBox(height: 16),
          _buildDebugOption(
            icon: Icons.restore_page_outlined,
            title: 'Tampilkan Ulang Banner Widget di Dashboard',
            subtitle: 'Mengaktifkan kembali banner informasi widget berwarna biru/hijau di bagian atas halaman Dashboard.',
            buttonText: 'Tampilkan Banner',
            buttonColor: Colors.teal.shade700,
            onTap: () async {
              await PreferenceService.instance.setWidgetCardDismissed(false);
              if (mounted) {
                TopToast.show(context, 'Banner widget di Dashboard kembali diaktifkan!');
              }
            },
          ),
          const SizedBox(height: 16),
          _buildDebugOption(
            icon: Icons.notifications_active_outlined,
            title: 'Reset Pemicu Toast Transaksi Pertama',
            subtitle: 'Atur ulang status transaksi pertama. Buat 1 transaksi baru di Dashboard untuk melihat notifikasi ajakan pasang widget.',
            buttonText: 'Reset Transaksi',
            buttonColor: Colors.orange.shade700,
            onTap: () async {
              await PreferenceService.instance.setHasCreatedFirstTransaction(false);
              if (mounted) {
                TopToast.show(context, 'Status pemicu transaksi pertama direset!');
              }
            },
          ),
          const SizedBox(height: 16),
          _buildDebugOption(
            icon: Icons.refresh,
            title: 'Reset Semua Status Onboarding & Edukasi',
            subtitle: 'Kembalikan semua pengaturan edukasi dan pengenalan aplikasi ke kondisi awal (fresh install).',
            buttonText: 'Reset Semua',
            buttonColor: Colors.red.shade700,
            onTap: () async {
              await PreferenceService.instance.setFirstLaunch(true);
              await PreferenceService.instance.setLastSeenVersion('');
              await PreferenceService.instance.setForcedRemoteVersion('');
              await PreferenceService.instance.setWidgetCardDismissed(false);
              await PreferenceService.instance.setHasCreatedFirstTransaction(false);
              if (mounted) {
                TopToast.show(context, 'Seluruh status edukasi & onboarding berhasil direset ke awal!');
              }
            },
          ),
          const SizedBox(height: 16),
          _buildDebugOption(
            icon: Icons.notification_important_outlined,
            title: 'Kirim Notifikasi Uji Coba (Debug Notification)',
            subtitle: 'Kirim notifikasi lokal secara instan untuk menguji apakah sistem notifikasi WiroFin bekerja dengan baik.',
            buttonText: 'Kirim Notifikasi',
            buttonColor: Colors.pink.shade700,
            onTap: () async {
              final pushStatus = await Permission.notification.request();
              if (pushStatus.isDenied || pushStatus.isPermanentlyDenied) {
                if (mounted) {
                  TopToast.show(context, 'Izin notifikasi ditolak oleh pengguna.', isError: true);
                }
                return;
              }
              const channel = MethodChannel('com.wirodev.wirofin/auto_track');
              try {
                await channel.invokeMethod('showLocalNotification', {
                  'title': 'WiroFin Uji Coba',
                  'message': 'Ini adalah notifikasi uji coba dari menu debug.',
                });
                if (mounted) {
                  TopToast.show(context, 'Notifikasi uji coba dikirim!');
                }
              } catch (e) {
                if (mounted) {
                  TopToast.show(context, 'Gagal mengirim notifikasi: $e', isError: true);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _simulatePlayStoreUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {},
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppLocalizations.of(context)?.updateAvailableTitle ?? 'Update Tersedia!', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            AppLocalizations.of(context)?.updateAvailableMessage ?? 'Versi terbaru WiroFin sudah tersedia di Play Store. Silakan update untuk melanjutkan menggunakan aplikasi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)?.exit ?? 'Tutup Simulasi', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                TopToast.show(context, 'Membuka link Google Play Store...');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
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

  void _simulateWhatsNewModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
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
                            BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
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
                      const Text(
                        'Kini Anda dapat memasang widget WiroFin di beranda HP untuk melihat saldo dan mencatat transaksi secara instan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
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
                                Navigator.pop(ctx);
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
          ),
        );
      },
    );
  }

  Widget _buildDebugOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: buttonColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: buttonColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
