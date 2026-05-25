import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier instance = ThemeNotifier._();
  ThemeNotifier._();

  String _currentMode = 'personal';

  String get currentMode => _currentMode;

  ThemeData get currentTheme => _currentMode == 'personal' 
      ? AppTheme.personalTheme 
      : AppTheme.companyTheme;

  void toggleMode(String mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      notifyListeners();
    }
  }
}
