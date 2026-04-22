import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../badges/badge_catalog.dart';
import '../models/scenario_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import '../widgets/main_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<ScenarioModel> _scenarios = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadScenarioMeta());
  }

  Future<void> _loadScenarioMeta() async {
    try {
      final api = context.read<ApiService>();
      final raw = await api.scenarios();
      if (!mounted) return;
      setState(() {
        _scenarios = raw.map((e) => ScenarioModel.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (_) {
      // Keep profile screen functional even if metadata fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.user;
    final fullName = u?.fullName ?? 'Demo Trainee';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'D';
    final level = u?.level ?? 1;
    final totalScore = u?.totalScore ?? 0;
    final completed = u?.completedScenarios.length ?? 0;
    final earnedBadgeIds = (u?.earnedBadges ?? const <String>[]);
    final xpCurrent = totalScore;
    final xpTarget = _xpTargetForNextLevel(level);
    final xpProgress = xpTarget <= 0 ? 0.0 : (xpCurrent / xpTarget).clamp(0, 1).toDouble();
    final scenarioById = {for (final s in _scenarios) s.id: s};
    final recentActivities = _buildRecentActivities(
      completedScenarioIds: u?.completedScenarios ?? const [],
      scenarioById: scenarioById,
      earnedBadgeIds: earnedBadgeIds,
      level: level,
      totalScore: totalScore,
    );

    return MainScaffold(
      title: 'Profile',
      sidebarCtaLabel: 'Deploy Mission',
      sidebarCtaRoute: '/scenarios',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeroCard(
              fullName: fullName,
              email: u?.email ?? 'secure.ops@company.com',
              role: u?.role ?? 'operator',
              level: level,
              initial: initial,
              xpCurrent: xpCurrent,
              xpTarget: xpTarget,
              xpProgress: xpProgress,
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, c) {
                final cards = [
                  _ProfileStatCard(
                    icon: Icons.stars_rounded,
                    label: 'Total Score',
                    value: '$totalScore',
                    hint: '+${(totalScore * 0.12).round()} this week',
                    accent: AppColors.success,
                  ),
                  _ProfileStatCard(
                    icon: Icons.task_alt_outlined,
                    label: 'Completed Scenarios',
                    value: '$completed',
                    hint: '${(completed * 5).clamp(0, 99)}% progress path',
                    accent: AppColors.accentTeal,
                  ),
                  _ProfileStatCard(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Earned Badges',
                    value: '${earnedBadgeIds.length}',
                    hint: 'View all certifications',
                    accent: AppColors.warning,
                  ),
                ];
                final cols = c.maxWidth > 1180 ? 3 : 1;
                const gap = 12.0;
                if (cols == 1) {
                  return Column(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        cards[i],
                        if (i != cards.length - 1) const SizedBox(height: gap),
                      ],
                    ],
                  );
                }
                final width = (c.maxWidth - (2 * gap)) / 3;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: cards.map((card) => SizedBox(width: width, child: card)).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            _BadgePreviewSection(
              earnedBadgeIds: earnedBadgeIds,
              onOpenGallery: () => context.go('/badges'),
            ),
            const SizedBox(height: 16),
            _RecentActivitySection(activities: recentActivities),
          ],
        ),
      ),
    );
  }

  int _xpTargetForNextLevel(int level) => (level + 1) * 500;

  List<_ProfileActivity> _buildRecentActivities({
    required List<String> completedScenarioIds,
    required Map<String, ScenarioModel> scenarioById,
    required List<String> earnedBadgeIds,
    required int level,
    required int totalScore,
  }) {
    final activities = <_ProfileActivity>[];
    final completed = completedScenarioIds.reversed.take(2).toList();
    for (final id in completed) {
      final s = scenarioById[id];
      activities.add(
        _ProfileActivity(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          title: 'Completed: ${s?.title ?? 'Training Scenario'}',
          subtitle: 'Earned ${((s?.steps.length ?? 8) * 5)} XP',
          meta: 'Recent completion',
        ),
      );
    }
    if (earnedBadgeIds.isNotEmpty) {
      final latest = earnedBadgeIds.last;
      final b = BadgeCatalog.byId(latest);
      activities.add(
        _ProfileActivity(
          icon: Icons.verified_rounded,
          iconColor: AppColors.primary,
          title: 'New Achievement: ${b?.name ?? latest}',
          subtitle: b?.description ?? 'Badge unlocked',
          meta: 'Milestone reached',
        ),
      );
    }
    activities.add(
      _ProfileActivity(
        icon: Icons.rocket_launch_rounded,
        iconColor: AppColors.accentTeal,
        title: 'Operator level $level active',
        subtitle: 'Current score: $totalScore XP',
        meta: 'Progress update',
      ),
    );
    return activities.take(4).toList();
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.fullName,
    required this.email,
    required this.role,
    required this.level,
    required this.initial,
    required this.xpCurrent,
    required this.xpTarget,
    required this.xpProgress,
  });

  final String fullName;
  final String email;
  final String role;
  final int level;
  final String initial;
  final int xpCurrent;
  final int xpTarget;
  final double xpProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: DesignTokens.shadowCard(Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surface2,
                      AppColors.primary.withValues(alpha: 0.45),
                    ],
                  ),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(fullName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          'Global Security Operations Center',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentTeal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'LVL $level',
                            style: const TextStyle(color: AppColors.accentTeal, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Edit Profile'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Icon(Icons.share_outlined, size: 18),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'CURRENT PROGRESS TO NEXT LEVEL',
            style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: xpProgress,
              minHeight: 8,
              backgroundColor: AppColors.border.withValues(alpha: 0.7),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$xpCurrent / $xpTarget XP',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.hint,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final String hint;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            hint,
            style: TextStyle(
              color: accent == AppColors.success ? AppColors.success : AppColors.textMuted,
              fontSize: 12,
              fontWeight: accent == AppColors.success ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgePreviewSection extends StatelessWidget {
  const _BadgePreviewSection({
    required this.earnedBadgeIds,
    required this.onOpenGallery,
  });

  final List<String> earnedBadgeIds;
  final VoidCallback onOpenGallery;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Achievement Badges', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  SizedBox(height: 4),
                  Text('Recent milestones and security certifications earned', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: onOpenGallery,
                child: const Text('Open badge gallery'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final b in BadgeCatalog.all.take(7))
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: _BadgeMiniCard(
                      badge: b,
                      unlocked: earnedBadgeIds.contains(b.id),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeMiniCard extends StatelessWidget {
  const _BadgeMiniCard({
    required this.badge,
    required this.unlocked,
  });

  final BadgeDefinition badge;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.45,
      child: SizedBox(
        width: 110,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: badge.faceGradient),
                border: Border.all(color: badge.accentColor.withValues(alpha: 0.5)),
              ),
              child: Icon(unlocked ? badge.icon : Icons.lock_outline, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              unlocked ? 'Unlocked' : 'Locked',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({required this.activities});
  final List<_ProfileActivity> activities;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Training Activity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 10),
          if (activities.isEmpty)
            const Text('No recent activity yet. Start a scenario to build your timeline.', style: TextStyle(color: AppColors.textMuted))
          else
            ...activities.map((a) => _ActivityRow(item: a)),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});
  final _ProfileActivity item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: item.iconColor.withValues(alpha: 0.14),
              child: Icon(item.icon, size: 15, color: item.iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(item.subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(item.meta, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ProfileActivity {
  const _ProfileActivity({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.meta,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String meta;
}
