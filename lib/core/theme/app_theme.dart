import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static const _fontFamily = '.AppleSystemUIFont';
  static const _fallback = 'sans-serif';

  static String get _ff => _fontFamily;

  // ── Light ────────────────────────────────────────────────────────────
  static ThemeData get light => _build(
    brightness: Brightness.light,
    scheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: AppColors.teal400,
      primary: AppColors.teal400,
      secondary: AppColors.amber400,
      error: AppColors.coral400,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBg: AppColors.background,
    cardColor: AppColors.surface,
    dividerColor: AppColors.border,
    navBg: AppColors.surface,
    titleColor: AppColors.teal900,
    hintColor: AppColors.textHint,
    inputFill: AppColors.slate50,
  );

  // ── Dark ─────────────────────────────────────────────────────────────
  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    scheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: AppColors.teal400,
      primary: AppColors.teal400,
      secondary: AppColors.amber400,
      error: AppColors.coral400,
      surface: AppColors.surfaceDk,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: AppColors.textPrimaryDk,
    ),
    scaffoldBg: AppColors.backgroundDk,
    cardColor: AppColors.surfaceDk,
    dividerColor: AppColors.borderDk,
    navBg: AppColors.surfaceDk,
    titleColor: AppColors.teal200,
    hintColor: AppColors.textHintDk,
    inputFill: AppColors.surfaceDk,
  );

  // ── Builder ───────────────────────────────────────────────────────────
  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffoldBg,
    required Color cardColor,
    required Color dividerColor,
    required Color navBg,
    required Color titleColor,
    required Color hintColor,
    required Color inputFill,
  }) {
    final isDark = brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDk : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDk : AppColors.textSecondary;
    final border = isDark ? AppColors.borderDk : AppColors.border;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: cardColor,
      dividerColor: dividerColor,
      fontFamily: _ff,
      fontFamilyFallback: const [_fallback],
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w700, color: titleColor,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w700, color: titleColor,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, color: titleColor,
          letterSpacing: -0.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13.5, fontWeight: FontWeight.w400, color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: hintColor,
        ),
        labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: navBg,
        foregroundColor: titleColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: dividerColor,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: titleColor,
          letterSpacing: -0.2,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navBg,
        indicatorColor: isDark ? AppColors.teal900 : AppColors.teal50,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal400,
          foregroundColor: Colors.white,
          // Must be finite width: Size.fromHeight uses w=Infinity and breaks
          // ElevatedButton inside Row / flex (ListView → Focus domain row).
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.teal400,
          minimumSize: const Size(48, 50),
          side: const BorderSide(color: AppColors.teal400),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.teal400,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.teal400, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.coral400),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: hintColor),
        labelStyle: TextStyle(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.slate100Dk : AppColors.slate100,
        selectedColor: isDark ? AppColors.teal900 : AppColors.teal50,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isDark ? const Color(0xFF2A3A4F) : AppColors.slate900,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.teal400,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
