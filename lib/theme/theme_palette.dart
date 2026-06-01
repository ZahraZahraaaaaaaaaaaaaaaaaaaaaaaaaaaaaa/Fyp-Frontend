import 'package:flutter/material.dart';

/// Semantic colors that change between light and dark mode.
class ThemePalette {
  const ThemePalette({
    required this.isDark,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.topBar,
    required this.sidebar,
    required this.authGradientStart,
    required this.authGradientEnd,
    required this.cardShadowBase,
    required this.toastSurface,
    required this.toggleTrack,
    required this.lockedCardStart,
    required this.lockedCardEnd,
  });

  final bool isDark;
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color topBar;
  final Color sidebar;
  final Color authGradientStart;
  final Color authGradientEnd;
  final Color cardShadowBase;
  final Color toastSurface;
  final Color toggleTrack;
  final Color lockedCardStart;
  final Color lockedCardEnd;

  static const ThemePalette dark = ThemePalette(
    isDark: true,
    bg: Color(0xFF070B14),
    surface: Color(0xFF0D1426),
    surface2: Color(0xFF101C35),
    border: Color(0xFF1D2A47),
    text: Color(0xFFE7ECF7),
    textMuted: Color(0xFFAAB6D3),
    topBar: Color(0xFF060F22),
    sidebar: Color(0xFF060D1D),
    authGradientStart: Color(0xFF070B14),
    authGradientEnd: Color(0xFF0A1328),
    cardShadowBase: Colors.black,
    toastSurface: Color(0xFF0D1426),
    toggleTrack: Color(0xFF101C35),
    lockedCardStart: Color(0xFF1A2236),
    lockedCardEnd: Color(0xFF0D1426),
  );

  static const ThemePalette light = ThemePalette(
    isDark: false,
    bg: Color(0xFFF4F7FC),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF0F4FA),
    border: Color(0xFFD8E2F0),
    text: Color(0xFF1A2338),
    textMuted: Color(0xFF5C6B88),
    topBar: Color(0xFFFFFFFF),
    sidebar: Color(0xFFFFFFFF),
    authGradientStart: Color(0xFFF8FAFD),
    authGradientEnd: Color(0xFFE8EFF9),
    cardShadowBase: Color(0xFF1A2338),
    toastSurface: Color(0xFFFFFFFF),
    toggleTrack: Color(0xFFE8EFF9),
    lockedCardStart: Color(0xFFE8EDF5),
    lockedCardEnd: Color(0xFFF5F8FC),
  );
}
