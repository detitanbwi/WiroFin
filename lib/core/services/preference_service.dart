import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/theme_notifier.dart';

class PreferenceService {
  static final PreferenceService instance = PreferenceService._();
  PreferenceService._();

  SharedPreferences? _prefs;
  final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(const Locale('id'));

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final lang = _prefs?.getString('language_code') ?? 'id';
    localeNotifier.value = Locale(lang);
  }

  bool get isFirstLaunch {
    return _prefs?.getBool('is_first_launch') ?? true;
  }

  Future<void> setFirstLaunch(bool value) async {
    await _prefs?.setBool('is_first_launch', value);
  }

  String get userName {
    return _prefs?.getString('user_name') ?? 'User';
  }

  Future<void> setUserName(String name) async {
    await _prefs?.setString('user_name', name);
  }

  String get languageCode {
    return _prefs?.getString('language_code') ?? 'id';
  }

  Future<void> setLanguage(String langCode) async {
    await _prefs?.setString('language_code', langCode);
    localeNotifier.value = Locale(langCode);
  }

  String get activeMode {
    return _prefs?.getString('active_mode') ?? 'personal';
  }

  Future<void> setActiveMode(String mode) async {
    await _prefs?.setString('active_mode', mode);
  }

  String get lastSeenVersion => _prefs?.getString('last_seen_version') ?? '';
  Future<void> setLastSeenVersion(String ver) async => await _prefs?.setString('last_seen_version', ver);

  bool get isWidgetCardDismissed => _prefs?.getBool('widget_card_dismissed') ?? false;
  Future<void> setWidgetCardDismissed(bool val) async => await _prefs?.setBool('widget_card_dismissed', val);

  bool get hasCreatedFirstTransaction => _prefs?.getBool('has_created_first_tx') ?? false;
  Future<void> setHasCreatedFirstTransaction(bool val) async => await _prefs?.setBool('has_created_first_tx', val);

  String get forcedRemoteVersion => _prefs?.getString('forced_remote_version') ?? '';
  Future<void> setForcedRemoteVersion(String ver) async => await _prefs?.setString('forced_remote_version', ver);

  Map<String, dynamic> exportPreferences() {
    return {
      'user_name': userName,
      'language_code': languageCode,
      'active_mode': activeMode,
      'is_first_launch': isFirstLaunch,
      'last_seen_version': lastSeenVersion,
      'widget_card_dismissed': isWidgetCardDismissed,
      'has_created_first_tx': hasCreatedFirstTransaction,
      'forced_remote_version': forcedRemoteVersion,
    };
  }

  Future<void> importPreferences(Map<String, dynamic> data) async {
    if (data['user_name'] != null) {
      await setUserName(data['user_name'].toString());
    }
    if (data['language_code'] != null) {
      await setLanguage(data['language_code'].toString());
    }
    if (data['active_mode'] != null) {
      final mode = data['active_mode'].toString();
      await setActiveMode(mode);
      ThemeNotifier.instance.toggleMode(mode);
    }
    if (data['is_first_launch'] != null) {
      final isFirst = data['is_first_launch'] is bool 
          ? data['is_first_launch'] as bool 
          : (data['is_first_launch'].toString() == 'true');
      await setFirstLaunch(isFirst);
    }
    if (data['last_seen_version'] != null) {
      await setLastSeenVersion(data['last_seen_version'].toString());
    }
    if (data['widget_card_dismissed'] != null) {
      final isDim = data['widget_card_dismissed'] is bool
          ? data['widget_card_dismissed'] as bool
          : (data['widget_card_dismissed'].toString() == 'true');
      await setWidgetCardDismissed(isDim);
    }
    if (data['has_created_first_tx'] != null) {
      final hasTx = data['has_created_first_tx'] is bool
          ? data['has_created_first_tx'] as bool
          : (data['has_created_first_tx'].toString() == 'true');
      await setHasCreatedFirstTransaction(hasTx);
    }
    if (data['forced_remote_version'] != null) {
      await setForcedRemoteVersion(data['forced_remote_version'].toString());
    }
  }
}

