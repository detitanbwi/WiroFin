import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class WidgetGuidePage extends StatelessWidget {
  const WidgetGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.widgetGuideTitle ?? 'Panduan Pasang Widget', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
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
              child: Column(
                children: [
                  const Icon(Icons.widgets, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)?.widgetHomeScreenTitle ?? 'Widget Home Screen WiroFin',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.widgetHomeScreenDesc ?? 'Pantau terus kesehatan finansial Anda tanpa harus membuka aplikasi.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)?.threeEasySteps ?? '3 Langkah Mudah Pemasangan',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            _buildStepCard(
              stepNumber: '1',
              title: AppLocalizations.of(context)?.widgetStep1Title ?? 'Pergi ke Layar Utama HP',
              description: AppLocalizations.of(context)?.widgetStep1Desc ?? 'Tutup atau minimalkan aplikasi WiroFin dan navigasikan ke layar utama (Home Screen) di HP Android atau iOS Anda.',
              icon: Icons.home_outlined,
            ),
            const SizedBox(height: 16),
            _buildStepCard(
              stepNumber: '2',
              title: AppLocalizations.of(context)?.widgetStep2Title ?? 'Tekan & Tahan Area Kosong',
              description: AppLocalizations.of(context)?.widgetStep2Desc ?? 'Tekan dan tahan (long press) pada area kosong di layar utama selama beberapa detik hingga muncul menu pengaturan layar atau pop-up menu.',
              icon: Icons.touch_app_outlined,
            ),
            const SizedBox(height: 16),
            _buildStepCard(
              stepNumber: '3',
              title: AppLocalizations.of(context)?.widgetStep3Title ?? 'Pilih & Seret Widget',
              description: AppLocalizations.of(context)?.widgetStep3Desc ?? 'Ketuk menu "Widget" (atau ikon +), gulir untuk mencari "WiroFin", lalu seret varian widget yang Anda inginkan ke layar utama.',
              icon: Icons.drag_indicator,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber.shade800),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)?.widgetTips ?? 'Tips: Widget WiroFin akan otomatis menyesuaikan warnanya sesuai mode (Personal/Company) saat aplikasi dibuka.',
                      style: TextStyle(fontSize: 13, color: Colors.amber.shade900, height: 1.4),
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

  Widget _buildStepCard({required String stepNumber, required String title, required String description, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(stepNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Text(description, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4)),
              ],
            ),
          ),
          Icon(icon, color: Colors.grey.shade400, size: 28),
        ],
      ),
    );
  }
}
