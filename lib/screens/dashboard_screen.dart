import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../badges/badge_catalog.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import '../widgets/figma_progress_bar.dart';
import '../widgets/figma_shell_card.dart';
import '../widgets/figma_stat_tile.dart';
import '../widgets/main_scaffold.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalScenarios = 0;
  Map<String, dynamic>? _rec;
  bool _loadingMeta = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMeta());
  }

  Future<void> _loadMeta() async {
    final api = context.read<ApiService>();
    try {
      final raw = await api.scenarios();
      final list = raw;
      final analytics = await api.analytics();
      if (!mounted) return;
      setState(() {
        _totalScenarios = list.length;
        _rec = analytics['recommendation'] as Map<String, dynamic>?;
        _loadingMeta = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMeta = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.user;
    final completed = u?.completedScenarios.length ?? 0;
    final progressPct = _totalScenarios > 0 ? (completed / _totalScenarios * 100).clamp(0, 100).toDouble() : 0.0;

    return MainScaffold(
      title: 'Dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${u?.fullName ?? 'Trainee'}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Here is your security awareness progress — practice realistic simulations and learn from immediate feedback.',
              style: TextStyle(color: AppColors.textMuted, height: 1.45),
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, c) {
                final quad = c.maxWidth > 1100;
                final stats = [
                  FigmaStatTile(
                    label: 'Total score',
                    value: '${u?.totalScore ?? 0}',
                    icon: Icons.stars_outlined,
                    accent: AppColors.primary,
                    delta: '5 pts per correct decision',
                  ),
                  FigmaStatTile(
                    label: 'Level',
                    value: '${u?.level ?? 1}',
                    icon: Icons.trending_up,
                    accent: AppColors.success,
                    delta: 'From cumulative score',
                  ),
                  FigmaStatTile(
                    label: 'Scenarios completed',
                    value: _loadingMeta ? '…' : '$completed${_totalScenarios > 0 ? '/$_totalScenarios' : ''}',
                    icon: Icons.flag_outlined,
                    accent: AppColors.secondary,
                    delta: _totalScenarios > 0 ? '${progressPct.round()}% of catalog' : null,
                  ),
                  FigmaStatTile(
                    label: 'Achievements',
                    value: '${u?.earnedBadges.length ?? 0}',
                    icon: Icons.workspace_premium_outlined,
                    accent: AppColors.accentTeal,
                    delta: 'Badge gallery',
                  ),
                ];
                if (quad) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < stats.length; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i < stats.length - 1 ? 12 : 0),
                            child: stats[i],
                          ),
                        ),
                    ],
                  );
                }
                return Column(
                  children: [
                    for (final s in stats) Padding(padding: const EdgeInsets.only(bottom: 12), child: s),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth > 960;
                final left = FigmaShellCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Training progress',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 14),
                      FigmaProgressBar(
                        progress: progressPct,
                        label: 'Scenario completion',
                        showPercentage: true,
                        color: FigmaProgressColor.primary,
                      ),
                    ],
                  ),
                );
                final right = FigmaShellCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievements',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      ...BadgeCatalog.all.take(4).map((b) {
                        final earned = (u?.earnedBadges ?? const <String>[]).contains(b.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: earned ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface2,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  earned ? Icons.verified_outlined : Icons.lock_outline,
                                  color: earned ? AppColors.primary : AppColors.textMuted,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      Text(
                                        b.description,
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.3),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.go('/badges'),
                          child: const Text('View all'),
                        ),
                      ),
                    ],
                  ),
                );
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: left),
                      const SizedBox(width: 16),
                      Expanded(child: right),
                    ],
                  );
                }
                return Column(children: [left, const SizedBox(height: 16), right]);
              },
            ),
            const SizedBox(height: 18),
            FigmaShellCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended next step',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (_rec?['suggested'] ?? 'beginner').toString().toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (_rec?['reason'] ?? 'Complete more scenarios to unlock tailored recommendations.').toString(),
                    style: const TextStyle(color: AppColors.textMuted, height: 1.35),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () => context.go('/scenarios'),
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Start scenarios'),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
