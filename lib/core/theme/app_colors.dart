import 'package:flutter/material.dart';

class AppColors {
  // ── Primary – Teal ──────────────────────────────────────────────────
  static const Color teal50  = Color(0xFFE6F7F4);
  static const Color teal100 = Color(0xFFB3E8DF);
  static const Color teal200 = Color(0xFF7DD4C8);
  static const Color teal400 = Color(0xFF2EB89A);
  static const Color teal600 = Color(0xFF1A8C73);
  static const Color teal900 = Color(0xFF0D4A3D);

  // ── Coral ───────────────────────────────────────────────────────────
  static const Color coral50  = Color(0xFFFEF0ED);
  static const Color coral100 = Color(0xFFFCD0C6);
  static const Color coral400 = Color(0xFFF0714F);
  static const Color coral600 = Color(0xFFC44E30);
  static const Color coral900 = Color(0xFF6B240F);

  // ── Amber ───────────────────────────────────────────────────────────
  static const Color amber50  = Color(0xFFFEF8EC);
  static const Color amber100 = Color(0xFFFCE6B2);
  static const Color amber400 = Color(0xFFF0AA2A);
  static const Color amber600 = Color(0xFFC47F10);
  static const Color amber900 = Color(0xFF6B4106);

  // ── Slate ───────────────────────────────────────────────────────────
  static const Color slate50  = Color(0xFFF6F8FA);
  static const Color slate100 = Color(0xFFEEF1F5);
  static const Color slate200 = Color(0xFFDDE3EB);
  static const Color slate400 = Color(0xFF8896AA);
  static const Color slate600 = Color(0xFF5A6780);
  static const Color slate900 = Color(0xFF1E2A3A);

  // ── Purple ──────────────────────────────────────────────────────────
  static const Color purple50  = Color(0xFFF2EFFE);
  static const Color purple100 = Color(0xFFD8D3F8);
  static const Color purple400 = Color(0xFF7C6FE0);
  static const Color purple600 = Color(0xFF5548B8);
  static const Color purple900 = Color(0xFF2A2260);

  // ── Green ───────────────────────────────────────────────────────────
  static const Color green50  = Color(0xFFEDF7F1);
  static const Color green100 = Color(0xFFB8E4C6);
  static const Color green400 = Color(0xFF34A85A);
  static const Color green600 = Color(0xFF1F7A3E);

  // ── Blue ────────────────────────────────────────────────────────────
  static const Color blue50  = Color(0xFFEBF4FF);
  static const Color blue100 = Color(0xFFBDD9F9);
  static const Color blue400 = Color(0xFF3B8BD4);
  static const Color blue600 = Color(0xFF1A63A8);

  // ── Light semantic ──────────────────────────────────────────────────
  static const Color background    = Color(0xFFFAFBFC);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color border        = Color(0xFFE2E8F0);
  static const Color textPrimary   = slate900;
  static const Color textSecondary = slate600;
  static const Color textHint      = slate400;

  // ── Dark semantic ───────────────────────────────────────────────────
  static const Color backgroundDk    = Color(0xFF0F1923);
  static const Color surfaceDk       = Color(0xFF1A2535);
  static const Color borderDk        = Color(0xFF26374F);
  static const Color textPrimaryDk   = Color(0xFFE4EEF8);
  static const Color textSecondaryDk = Color(0xFF7A99B8);
  static const Color textHintDk      = Color(0xFF3E5570);

  // ── Dark tinted accents (slightly muted for dark backgrounds) ───────
  static const Color teal50Dk   = Color(0xFF0D2E28);
  static const Color amber50Dk  = Color(0xFF2A1F08);
  static const Color coral50Dk  = Color(0xFF2A1210);
  static const Color purple50Dk = Color(0xFF1A1535);
  static const Color blue50Dk   = Color(0xFF0D1E30);
  static const Color green50Dk  = Color(0xFF0D2018);
  static const Color slate50Dk  = Color(0xFF1A2535);
  static const Color slate100Dk = Color(0xFF1E2D3F);
}

/// Quick access to theme-aware colours via `context.col*`.
extension AppColorsX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get colBackground => isDark ? AppColors.backgroundDk : AppColors.background;
  Color get colSurface     => isDark ? AppColors.surfaceDk    : AppColors.surface;
  Color get colBorder      => isDark ? AppColors.borderDk     : AppColors.border;
  Color get colText        => isDark ? AppColors.textPrimaryDk   : AppColors.textPrimary;
  Color get colTextSec     => isDark ? AppColors.textSecondaryDk : AppColors.textSecondary;
  Color get colTextHint    => isDark ? AppColors.textHintDk    : AppColors.textHint;

  Color colTint(Color light, Color dark) => isDark ? dark : light;
}
