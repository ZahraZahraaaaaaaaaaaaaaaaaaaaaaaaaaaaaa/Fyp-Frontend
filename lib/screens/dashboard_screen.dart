import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/main_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.user;

    return MainScaffold(
      title: 'Dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${u?.fullName ?? 'Trainee'}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Learn by making decisions inside realistic simulations. Wrong choices show immediate consequences.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth > 900;
                final children = [
                  _StatCard(
                    title: 'Total score',
                    value: '${u?.totalScore ?? 0}',
                    icon: Icons.stars_outlined,
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    title: 'Level',
                    value: '${u?.level ?? 1}',
                    icon: Icons.trending_up,
                    color: AppColors.success,
                  ),
                  _StatCard(
                    title: 'Badges',
                    value: '${u?.earnedBadges.length ?? 0}',
                    icon: Icons.military_tech_outlined,
                    color: AppColors.secondary,
                  ),
                ];
                if (wide) {
                  return Row(
                    children: [
                      for (final w in children) Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: w)),
                    ],
                  );
                }
                return Column(
                  children: [
                    for (final w in children) Padding(padding: const EdgeInsets.only(bottom: 12), child: w),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text('Quick actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go('/scenarios'),
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Start scenarios'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/badges'),
                  icon: const Icon(Icons.workspace_premium_outlined),
                  label: const Text('View achievements'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/analytics'),
                  icon: const Icon(Icons.insights_outlined),
                  label: const Text('View analytics'),
                ),
                if (auth.isAdmin)
                  OutlinedButton.icon(
                    onPressed: () => context.go('/admin'),
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('Admin'),
                  ),
              ],
            ),
            if ((u?.earnedBadges ?? []).isNotEmpty) ...[
              const SizedBox(height: 28),
              Text('Recent badges', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: u!.earnedBadges
                    .map(
                      (b) => Chip(
                        label: Text(b.replaceAll('_', ' ')),
                        avatar: const Icon(Icons.verified, size: 18),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                  Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
