import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/config/app_config.dart';

import 'master_data/profile_settings_page.dart';
import 'master_data/account_management_page.dart';
import 'master_data/category_settings_page.dart';
import 'master_data/backup_restore_page.dart';
import 'master_data/widget_guide_page.dart';
import 'master_data/auto_track_settings_page.dart';
import 'master_data/debug_tools_page.dart';

class MasterDataScreen extends StatelessWidget {
  final String activeMode;
  const MasterDataScreen({super.key, required this.activeMode});

  @override
  Widget build(BuildContext context) {
    final isPersonal = activeMode == 'personal';
    // Gunakan warna sesuai instruksi MoM
    final bgColor = isPersonal ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9);
    final leadingIconColor = isPersonal ? const Color(0xFF2563EB) : const Color(0xFFD4AF37);
    final trailingIconColor = const Color(0xFF334155);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.masterData ?? 'Master Data',
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuTile(
            context,
            icon: Icons.person_outline,
            title: AppLocalizations.of(context)?.userProfile ?? 'Profil Pengguna',
            iconColor: leadingIconColor,
            trailingColor: trailingIconColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSettingsPage())),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: AppLocalizations.of(context)?.bankAccountManagement ?? 'Pengelolaan Rekening',
            iconColor: leadingIconColor,
            trailingColor: trailingIconColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AccountManagementPage(activeMode: activeMode))),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.category_outlined,
            title: AppLocalizations.of(context)?.transactionCategory ?? 'Kategori Transaksi',
            iconColor: leadingIconColor,
            trailingColor: trailingIconColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategorySettingsPage(activeMode: activeMode))),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.backup_outlined,
            title: AppLocalizations.of(context)?.dataBackupRestore ?? 'Cadangan Data (Backup & Restore)',
            iconColor: leadingIconColor,
            trailingColor: trailingIconColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupRestorePage())),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.help_outline,
            title: AppLocalizations.of(context)?.widgetGuideTitle ?? 'Panduan Widget',
            iconColor: leadingIconColor,
            trailingColor: trailingIconColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WidgetGuidePage())),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.notifications_active_outlined,
            title: AppLocalizations.of(context)?.autoTrackTitle ?? 'Otomatisasi M-Banking & E-Wallet',
            iconColor: leadingIconColor,
            trailingColor: trailingIconColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AutoTrackSettingsPage())),
          ),
          if (AppConfig.instance.enableDebugTools) ...[
            const SizedBox(height: 12),
            _buildMenuTile(
              context,
              icon: Icons.bug_report_outlined,
              title: 'Uji Coba & Reset Status (Mode Testing)',
              iconColor: const Color(0xFF8B5CF6),
              trailingColor: trailingIconColor,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DebugToolsPage())),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, {
    required IconData icon, 
    required String title, 
    required Color iconColor, 
    required Color trailingColor, 
    required VoidCallback onTap
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        highlightColor: iconColor.withOpacity(0.05),
        splashColor: iconColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
              ),
              Icon(Icons.chevron_right, color: trailingColor),
            ],
          ),
        ),
      ),
    );
  }
}
