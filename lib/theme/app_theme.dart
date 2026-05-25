import 'package:flutter/material.dart';
import 'app_colors_extension.dart';

class AppTheme {
  // Teks dan Netral Global
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color borderStandard = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);

  // Status Global
  static const _statusColors = AppColorsExtension(
    incomePrimary: Color(0xFF22C55E),
    incomeDark: Color(0xFF16A34A),
    incomeBg: Color(0xFFDCFCE7),
    expensePrimary: Color(0xFFEF4444),
    expenseDark: Color(0xFFDC2626),
    expenseBg: Color(0xFFFEE2E2),
    warningPrimary: Color(0xFFF59E0B),
    warningBg: Color(0xFFFEF3C7),
  );

  /// 🔵 TEMA MODE PERSONAL
  static ThemeData get personalTheme {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      primaryColor: const Color(0xFF2563EB),
      primaryColorDark: const Color(0xFF1D4ED8),
      useMaterial3: true,
      fontFamily: 'Inter',
      
      // Pemetaan ke ColorScheme standar
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2563EB),
        onPrimary: Colors.white,
        surface: cardSurface,
        onSurface: textMain,
        outline: borderStandard,
      ),

      // Ekstensi warna spesifik Personal
      extensions: [
        _statusColors.copyWith(
          lightPrimary: const Color(0xFFBFDBFE),
          palePrimary: const Color(0xFFDBEAFE),
          veryPalePrimary: const Color(0xFFEFF6FF),
        ),
      ],
      
      // Standarisasi Teks
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textMain),
        bodyMedium: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: textDisabled),
      ),
      
      // Gaya bawaan Komponen agar otomatis menyesuaikan
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  /// 🏢 TEMA MODE PERUSAHAAN (COMPANY)
  static ThemeData get companyTheme {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      primaryColor: const Color(0xFF1E293B),
      primaryColorDark: const Color(0xFF0F172A),
      useMaterial3: true,
      fontFamily: 'Inter',
      
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1E293B), // Hitam Slate
        secondary: Color(0xFFD4AF37), // Emas Utama
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        surface: cardSurface,
        onSurface: textMain,
        outline: borderStandard,
      ),

      // Ekstensi warna spesifik Company
      extensions: [
        _statusColors.copyWith(
          goldPrimary: const Color(0xFFD4AF37),
          goldDark: const Color(0xFFB49020),
          goldPale: const Color(0xFFFDE68A),
          goldVeryPale: const Color(0xFFFEF08A),
          companyInactiveIcon: const Color(0xFF334155),
        ),
      ],
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textMain),
        bodyMedium: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: textDisabled),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37), // Tombol utama berwarna Emas di mode Company
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
