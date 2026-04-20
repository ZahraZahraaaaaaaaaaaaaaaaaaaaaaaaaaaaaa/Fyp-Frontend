import 'package:flutter/material.dart';

/// Spacing, radii, and shadows aligned with `figma_ui/src/styles/globals.css`
/// and Figma components (Card, Button, ProgressBar).
abstract final class DesignTokens {
  static const double radiusSm = 6;
  static const double radiusMd = 10;
  static const double radiusLg = 16;

  static const double componentHeight = 44;

  /// globals.css --shadow-card
  static List<BoxShadow> shadowCard(Color base) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> shadowCardHover(Color accent) => [
        BoxShadow(
          color: accent.withValues(alpha: 0.12),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ];
}
