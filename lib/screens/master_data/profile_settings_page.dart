import 'package:flutter/material.dart';
import '../../core/services/preference_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/top_toast.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: PreferenceService.instance.userName);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.userProfile ?? 'Profil Pengguna', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.profile ?? 'Profil Pengguna',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.usernameLabel ?? 'Nama Panggilan',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await PreferenceService.instance.setUserName(nameController.text);
                  if (mounted) {
                    TopToast.show(context, AppLocalizations.of(context)?.successSaveProfile ?? 'Profil berhasil disimpan');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)?.saveProfile ?? 'Simpan Profil'),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)?.language ?? 'Bahasa / Language',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<Locale>(
              valueListenable: PreferenceService.instance.localeNotifier,
              builder: (context, locale, child) {
                return SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment<String>(
                      value: 'id',
                      label: Text('🇮🇩 Indonesia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    ButtonSegment<String>(
                      value: 'en',
                      label: Text('🇬🇧 English', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (Set<String> newSelection) {
                    final lang = newSelection.first;
                    PreferenceService.instance.setLanguage(lang);
                    TopToast.show(context, lang == 'id' ? 'Bahasa diubah ke Indonesia' : 'Language changed to English');
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return primaryColor.withOpacity(0.1);
                      }
                      return Colors.white;
                    }),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
