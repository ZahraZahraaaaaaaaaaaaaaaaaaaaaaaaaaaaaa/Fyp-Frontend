import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/main_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.user;

    return MainScaffold(
      title: 'Profile',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 28,
                child: Text(
                  (u?.fullName ?? 'U').isNotEmpty ? (u!.fullName[0].toUpperCase()) : 'U',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(u?.fullName ?? '', style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(u?.email ?? ''),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.stars_outlined),
                    title: const Text('Total score'),
                    trailing: Text('${u?.totalScore ?? 0}'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.trending_up),
                    title: const Text('Level'),
                    trailing: Text('${u?.level ?? 1}'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Role'),
                    trailing: Text(u?.role ?? 'user'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Badges', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if ((u?.earnedBadges ?? []).isEmpty)
              const Text('Complete scenarios to earn badges.', style: TextStyle(color: AppColors.textMuted))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: u!.earnedBadges
                    .map((b) => Chip(label: Text(b.replaceAll('_', ' '))))
                    .toList(),
              ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => context.go('/badges'),
              icon: const Icon(Icons.workspace_premium_outlined),
              label: const Text('Open badge gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
