import 'package:flutter/material.dart';

/// Platform-wide tips and challenges — not stored in MongoDB or counted as unread.
class PlatformNotice {
  const PlatformNotice({
    required this.title,
    required this.message,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color accent;
}

class PlatformNotices {
  static const List<PlatformNotice> tipsAndChallenges = [
    PlatformNotice(
      title: 'Security Tip of the Day',
      message: 'Always verify sender domains before clicking email links.',
      icon: Icons.lightbulb_outline,
      accent: Color(0xFF3B82F6),
    ),
    PlatformNotice(
      title: 'Daily Challenge',
      message: 'Complete 2 scenarios today to earn bonus XP.',
      icon: Icons.bolt_outlined,
      accent: Color(0xFF22D3EE),
    ),
    PlatformNotice(
      title: 'Awareness Reminder',
      message: 'Stay alert to social engineering tactics in email, phone, and in person.',
      icon: Icons.visibility_outlined,
      accent: Color(0xFF34C759),
    ),
  ];
}
