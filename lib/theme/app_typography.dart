import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography aligned with `figma_ui/src/styles/globals.css` (Inter, 16px body).
abstract final class AppTypography {
  static const String family = 'Inter';

  static String? get fontFamily => GoogleFonts.inter().fontFamily;

  static TextTheme textTheme(TextTheme base) => GoogleFonts.interTextTheme(base);

  /// Apply Inter to a one-off [TextStyle] (inherits size/weight/color from [style]).
  static TextStyle style(TextStyle style) => GoogleFonts.inter(textStyle: style);

  /// Simulated email / terminal content only — not for general UI.
  static TextStyle mono(TextStyle style) => GoogleFonts.robotoMono(textStyle: style);
}
