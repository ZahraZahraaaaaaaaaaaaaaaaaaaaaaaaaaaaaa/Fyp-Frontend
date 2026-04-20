import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

/// Visual match for `figma_ui/src/components/ProgressBar.tsx` (dark theme).
class FigmaProgressBar extends StatelessWidget {
  const FigmaProgressBar({
    super.key,
    required this.progress,
    this.label,
    this.showPercentage = false,
    this.color = FigmaProgressColor.primary,
    this.height = FigmaProgressHeight.md,
  });

  final double progress; // 0–100
  final String? label;
  final bool showPercentage;
  final FigmaProgressColor color;
  final FigmaProgressHeight height;

  Color get _fill {
    switch (color) {
      case FigmaProgressColor.primary:
        return AppColors.primary;
      case FigmaProgressColor.success:
        return AppColors.success;
      case FigmaProgressColor.warning:
        return AppColors.warning;
      case FigmaProgressColor.error:
        return AppColors.danger;
    }
  }

  double get _h {
    switch (height) {
      case FigmaProgressHeight.sm:
        return 8;
      case FigmaProgressHeight.md:
        return 10;
      case FigmaProgressHeight.lg:
        return 14;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0, 100) / 100.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                if (label != null)
                  Expanded(
                    child: Text(
                      label!,
                      style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ),
                if (showPercentage)
                  Text(
                    '${progress.round()}%',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: _h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.border.withValues(alpha: 0.45)),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: p,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _fill,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: DesignTokens.shadowCardHover(_fill),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum FigmaProgressColor { primary, success, warning, error }

enum FigmaProgressHeight { sm, md, lg }
