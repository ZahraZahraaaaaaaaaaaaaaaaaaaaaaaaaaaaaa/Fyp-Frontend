import 'package:flutter/material.dart';

import 'theme_palette.dart';

/// Brand accents (shared across themes) + semantic colors from [palette].
class AppColors {
  static ThemePalette _palette = ThemePalette.dark;

  static ThemePalette get palette => _palette;

  static set palette(ThemePalette value) {
    _palette = value;
  }

  static bool get isDark => _palette.isDark;

  static Color get bg => _palette.bg;
  static Color get surface => _palette.surface;
  static Color get surface2 => _palette.surface2;
  static Color get border => _palette.border;
  static Color get text => _palette.text;
  static Color get textMuted => _palette.textMuted;
  static Color get topBar => _palette.topBar;
  static Color get sidebar => _palette.sidebar;
  static Color get authGradientStart => _palette.authGradientStart;
  static Color get authGradientEnd => _palette.authGradientEnd;
  static Color get cardShadowBase => _palette.cardShadowBase;
  static Color get toastSurface => _palette.toastSurface;
  static Color get toggleTrack => _palette.toggleTrack;
  static Color get lockedCardStart => _palette.lockedCardStart;
  static Color get lockedCardEnd => _palette.lockedCardEnd;

  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryDark = Color(0xFF2563EB);
  static const Color accentTeal = Color(0xFF22D3EE);

  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFF9C846);
  static const Color danger = Color(0xFFEF4444);
}
