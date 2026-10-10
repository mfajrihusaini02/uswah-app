import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1B5E20);
  static const Color primarySoft = Color(0xFFE8F5E9);
  static const Color primaryLight = Color(0xFF4C8C4A);
  static const Color primaryDark = Color(0xFF003300);

  static const Color secondary = Color(0xFFC9A227);
  static const Color secondarySoft = Color(0xFFFFF8E1);
  static const Color secondaryLight = Color(0xFFF7D774);

  static const Color background = Color(0xFFF7F9F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF1F4F1);

  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color textTertiary = Color(0xFF9E9E9E);

  static const Color divider = Color(0xFFE4E7E4);
  static const Color border = Color(0xFFE0E4E0);

  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  static const Color info = Color(0xFF1976D2);
  static const Color infoSoft = Color(0xFFE3F2FD);
  static const Color warning = Color(0xFFF9A825);

  static const Color cardShadow = Color(0x14000000);
  static const Color cardShadowSoft = Color(0x0A000000);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  static const Color gold = Color(0xFFC9A227);
  static const Color goldSoft = Color(0xFFFDF3D8);

  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color backgroundDark = Color(0xFF121415);
  static const Color surfaceDark = Color(0xFF1D2021);
  static const Color surfaceSoftDark = Color(0xFF282B2D);
  static const Color textPrimaryDark = Color(0xFFEDEEF0);
  static const Color textSecondaryDark = Color(0xFFAFB4B8);
  static const Color textTertiaryDark = Color(0xFF7E8489);
  static const Color dividerDark = Color(0xFF33373A);
  static const Color borderDark = Color(0xFF34383B);
  static const Color primarySoftDark = Color(0xFF1F3A24);
  static const Color secondarySoftDark = Color(0xFF3A3014);

  static const Color primaryBright = Color(0xFF7CC47C);
  static const Color secondaryBright = Color(0xFFE0C05C);
}

extension AppColorsExtension on BuildContext {
  /// Warna aksen utama yang kontras terhadap surface (terang di mode gelap).
  Color get primaryAccent =>
      Theme.of(this).brightness == Brightness.dark
          ? AppColors.primaryBright
          : AppColors.primary;

  Color get secondaryAccent =>
      Theme.of(this).brightness == Brightness.dark
          ? AppColors.secondaryBright
          : AppColors.secondary;
}
