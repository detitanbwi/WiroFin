import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  // --- Warna Kustom Mode Personal ---
  final Color? lightPrimary;
  final Color? palePrimary;
  final Color? veryPalePrimary;

  // --- Warna Kustom Mode Perusahaan (Gold & Inactive) ---
  final Color? goldPrimary;
  final Color? goldDark;
  final Color? goldPale;
  final Color? goldVeryPale;
  final Color? companyInactiveIcon;

  // --- Warna Status Global ---
  final Color? incomePrimary;
  final Color? incomeDark;
  final Color? incomeBg;
  
  final Color? expensePrimary;
  final Color? expenseDark;
  final Color? expenseBg;

  final Color? warningPrimary;
  final Color? warningBg;

  const AppColorsExtension({
    this.lightPrimary,
    this.palePrimary,
    this.veryPalePrimary,
    this.goldPrimary,
    this.goldDark,
    this.goldPale,
    this.goldVeryPale,
    this.companyInactiveIcon,
    this.incomePrimary,
    this.incomeDark,
    this.incomeBg,
    this.expensePrimary,
    this.expenseDark,
    this.expenseBg,
    this.warningPrimary,
    this.warningBg,
  });

  @override
  AppColorsExtension copyWith({
    Color? lightPrimary,
    Color? palePrimary,
    Color? veryPalePrimary,
    Color? goldPrimary,
    Color? goldDark,
    Color? goldPale,
    Color? goldVeryPale,
    Color? companyInactiveIcon,
    Color? incomePrimary,
    Color? incomeDark,
    Color? incomeBg,
    Color? expensePrimary,
    Color? expenseDark,
    Color? expenseBg,
    Color? warningPrimary,
    Color? warningBg,
  }) {
    return AppColorsExtension(
      lightPrimary: lightPrimary ?? this.lightPrimary,
      palePrimary: palePrimary ?? this.palePrimary,
      veryPalePrimary: veryPalePrimary ?? this.veryPalePrimary,
      goldPrimary: goldPrimary ?? this.goldPrimary,
      goldDark: goldDark ?? this.goldDark,
      goldPale: goldPale ?? this.goldPale,
      goldVeryPale: goldVeryPale ?? this.goldVeryPale,
      companyInactiveIcon: companyInactiveIcon ?? this.companyInactiveIcon,
      incomePrimary: incomePrimary ?? this.incomePrimary,
      incomeDark: incomeDark ?? this.incomeDark,
      incomeBg: incomeBg ?? this.incomeBg,
      expensePrimary: expensePrimary ?? this.expensePrimary,
      expenseDark: expenseDark ?? this.expenseDark,
      expenseBg: expenseBg ?? this.expenseBg,
      warningPrimary: warningPrimary ?? this.warningPrimary,
      warningBg: warningBg ?? this.warningBg,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      lightPrimary: Color.lerp(lightPrimary, other.lightPrimary, t),
      palePrimary: Color.lerp(palePrimary, other.palePrimary, t),
      veryPalePrimary: Color.lerp(veryPalePrimary, other.veryPalePrimary, t),
      goldPrimary: Color.lerp(goldPrimary, other.goldPrimary, t),
      goldDark: Color.lerp(goldDark, other.goldDark, t),
      goldPale: Color.lerp(goldPale, other.goldPale, t),
      goldVeryPale: Color.lerp(goldVeryPale, other.goldVeryPale, t),
      companyInactiveIcon: Color.lerp(companyInactiveIcon, other.companyInactiveIcon, t),
      incomePrimary: Color.lerp(incomePrimary, other.incomePrimary, t),
      incomeDark: Color.lerp(incomeDark, other.incomeDark, t),
      incomeBg: Color.lerp(incomeBg, other.incomeBg, t),
      expensePrimary: Color.lerp(expensePrimary, other.expensePrimary, t),
      expenseDark: Color.lerp(expenseDark, other.expenseDark, t),
      expenseBg: Color.lerp(expenseBg, other.expenseBg, t),
      warningPrimary: Color.lerp(warningPrimary, other.warningPrimary, t),
      warningBg: Color.lerp(warningBg, other.warningBg, t),
    );
  }
}
