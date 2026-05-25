import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'terms_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.aboutWiroFin ?? 'Tentang WiroFin', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // App Logo / Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_wallet, size: 80, color: primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              'WiroFin',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1E293B)),
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    '${AppLocalizations.of(context)?.versionLabel ?? 'Versi'} ${snapshot.data!.version}',
                    style: const TextStyle(color: Colors.grey),
                  );
                }
                return Text('${AppLocalizations.of(context)?.versionLabel ?? 'Versi'} ...', style: const TextStyle(color: Colors.grey));
              },
            ),
            const SizedBox(height: 40),
            
            // Info Sections
            _buildInfoTile(
              context,
              icon: Icons.business,
              title: AppLocalizations.of(context)?.developerLabel ?? 'Pengembang',
              content: 'Wirodayan Digital',
            ),
            _buildInfoTile(
              context,
              icon: Icons.language,
              title: AppLocalizations.of(context)?.websiteLabel ?? 'Website',
              content: 'wirodev.com',
              onTap: () async {
                final url = Uri.parse('https://wirodev.com');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
            _buildInfoTile(
              context,
              icon: Icons.calendar_today,
              title: AppLocalizations.of(context)?.createdOnLabel ?? 'Dibuat Pada',
              content: '2026',
            ),
            _buildInfoTile(
              context,
              icon: Icons.verified_user,
              title: AppLocalizations.of(context)?.licenseLabel ?? 'Lisensi',
              content: AppLocalizations.of(context)?.freeToUseLabel ?? 'Free to Use',
            ),
            _buildInfoTile(
              context,
              icon: Icons.description,
              title: AppLocalizations.of(context)?.legalLabel ?? 'Hukum',
              content: AppLocalizations.of(context)?.termsConditions ?? 'Syarat & Ketentuan',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsScreen()),
                );
              },
            ),
            
            const SizedBox(height: 60),
            const Text(
              '© 2026 Wirodayan Digital',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, {required IconData icon, required String title, required String content, VoidCallback? onTap}) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(content, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        trailing: onTap != null ? const Icon(Icons.open_in_new, size: 16, color: Colors.grey) : null,
      ),
    );
  }
}
