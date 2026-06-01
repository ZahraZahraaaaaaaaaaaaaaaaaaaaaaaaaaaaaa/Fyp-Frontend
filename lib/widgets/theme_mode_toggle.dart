import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';

/// Premium pill toggle: sun (light) / moon (dark) with sliding thumb.
class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDark;

    return Semantics(
      label: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      button: true,
      child: GestureDetector(
        onTap: theme.toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          width: 68,
          height: 34,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.toggleTrack,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadowBase.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Icon(
                      Icons.wb_sunny_outlined,
                      size: 15,
                      color: isDark ? AppColors.textMuted.withValues(alpha: 0.55) : AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: Icon(
                      Icons.dark_mode_outlined,
                      size: 15,
                      color: isDark ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOutCubic,
                alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [AppColors.primary, AppColors.primaryDark]
                          : [AppColors.accentTeal, AppColors.primary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.wb_sunny_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
