import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

/// Stat tile pattern from `EmployeeDashboard.tsx` (icon box + label + value + delta).
class FigmaStatTile extends StatelessWidget {
  const FigmaStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.delta,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String? delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: DesignTokens.shadowCard(Colors.black),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (delta != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    delta!,
                    style: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: accent, size: 26),
          ),
        ],
      ),
    );
  }
}
