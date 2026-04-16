import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../badges/badge_catalog.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/badge_card.dart';
import '../widgets/main_scaffold.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final earned = (auth.user?.earnedBadges ?? const <String>[]).toSet();

    return MainScaffold(
      title: 'Achievements',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Badge Gallery',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Earn achievements by completing simulations and maintaining safe decision habits.',
            style: TextStyle(color: AppColors.textMuted, height: 1.35),
          ),
          const SizedBox(height: 18),
          for (final b in BadgeCatalog.all) ...[
            BadgeCard(badge: b, unlocked: earned.contains(b.id)),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

