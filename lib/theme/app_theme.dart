import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'theme_palette.dart';

ThemeData buildAppTheme({required bool isDark}) {
  AppColors.palette = isDark ? ThemePalette.dark : ThemePalette.light;

  final base = ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    cardColor: AppColors.surface,
    dividerColor: AppColors.border,
    textTheme: base.textTheme.copyWith(
      bodyMedium: base.textTheme.bodyMedium?.copyWith(color: AppColors.text),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(color: AppColors.text),
      labelLarge: base.textTheme.labelLarge?.copyWith(color: AppColors.textMuted),
      titleLarge: base.textTheme.titleLarge?.copyWith(color: AppColors.text),
      titleMedium: base.textTheme.titleMedium?.copyWith(color: AppColors.text),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: false,
    ),
    drawerTheme: DrawerThemeData(backgroundColor: AppColors.surface),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: TextStyle(color: AppColors.textMuted),
      labelStyle: TextStyle(color: AppColors.textMuted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surface2,
      contentTextStyle: TextStyle(color: AppColors.text),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.surface2,
      side: BorderSide(color: AppColors.border),
      labelStyle: TextStyle(color: AppColors.text),
    ),
    dialogTheme: DialogThemeData(backgroundColor: AppColors.surface),
    iconTheme: IconThemeData(color: AppColors.textMuted),
  );
}
