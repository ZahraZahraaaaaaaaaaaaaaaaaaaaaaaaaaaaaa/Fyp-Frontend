import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NotificationStyle {
  static IconData iconForType(String type) {
    switch (type) {
      case 'badge_earned':
        return Icons.emoji_events_outlined;
      case 'achievement_unlocked':
        return Icons.military_tech_outlined;
      case 'scenario_completed':
        return Icons.check_circle_outline;
      case 'level_up':
        return Icons.star_outline;
      case 'reminder':
        return Icons.school_outlined;
      case 'welcome':
        return Icons.shield_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  static Color accentForType(String type) {
    switch (type) {
      case 'badge_earned':
        return const Color(0xFFF9C846);
      case 'achievement_unlocked':
        return const Color(0xFF8B5CF6);
      case 'scenario_completed':
        return AppColors.success;
      case 'level_up':
        return AppColors.accentTeal;
      case 'reminder':
        return AppColors.secondary;
      case 'welcome':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  static bool isDynamicToastType(String type) {
    return type == 'badge_earned' ||
        type == 'scenario_completed' ||
        type == 'level_up' ||
        type == 'achievement_unlocked';
  }
}
