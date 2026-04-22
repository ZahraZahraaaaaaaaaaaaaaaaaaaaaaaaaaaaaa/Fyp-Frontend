import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class BadgeGallerySidebar extends StatelessWidget {
  const BadgeGallerySidebar({
    super.key,
    required this.userName,
    required this.level,
  });

  final String userName;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 236,
      margin: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF070D1D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The Kinetic Archive',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF9CB6FF)),
          ),
          const SizedBox(height: 14),
          const Text('The Archive', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text('ELITE RANK • LEVEL $level', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          _NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, onTap: () => context.go('/home')),
          _NavItem(label: 'Badges', icon: Icons.workspace_premium_outlined, active: true, onTap: () {}),
          _NavItem(label: 'Challenges', icon: Icons.bolt_outlined, onTap: () => context.go('/scenarios')),
          _NavItem(label: 'Rankings', icon: Icons.leaderboard_outlined, onTap: () => context.go('/analytics')),
          _NavItem(label: 'Settings', icon: Icons.settings_outlined, onTap: () => context.go('/profile')),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1E3B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unlock Premium', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text(
                  'Get exclusive seasonal badges and double XP.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withValues(alpha: 0.16) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: active ? Border.all(color: AppColors.primary.withValues(alpha: 0.45)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: active ? AppColors.primary : AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active ? AppColors.text : AppColors.textMuted,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

