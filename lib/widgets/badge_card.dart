import 'package:flutter/material.dart';

import '../badges/badge_catalog.dart';
import '../theme/app_colors.dart';
import 'app_card.dart';
import 'badge_medal.dart';

class BadgeCard extends StatelessWidget {
  const BadgeCard({
    super.key,
    required this.badge,
    required this.unlocked,
  });

  final BadgeDefinition badge;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BadgeMedal(
            icon: badge.icon,
            faceGradient: badge.faceGradient,
            ribbonGradient: badge.ribbonGradient,
            locked: !unlocked,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        badge.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: unlocked ? AppColors.success.withValues(alpha: 0.14) : AppColors.surface2,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: unlocked ? AppColors.success.withValues(alpha: 0.35) : AppColors.border),
                      ),
                      child: Text(
                        unlocked ? 'Unlocked' : 'Locked',
                        style: TextStyle(
                          fontSize: 12,
                          color: unlocked ? AppColors.success : AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(badge.description, style: const TextStyle(color: AppColors.textMuted, height: 1.35)),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.flag_outlined, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        badge.condition,
                        style: const TextStyle(color: AppColors.textMuted, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

