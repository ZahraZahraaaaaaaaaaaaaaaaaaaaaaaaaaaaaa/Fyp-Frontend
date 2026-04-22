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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalScenarios = 0;
  List<ScenarioModel> _scenarios = [];
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
      final list = raw.map((e) => ScenarioModel.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() {
        _totalScenarios = list.length;
        _scenarios = list;
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
    final progressPct = _totalScenarios > 0 ? (completed / _totalScenarios).clamp(0, 1).toDouble() : 0.0;
    final pending = (_totalScenarios - completed).clamp(0, _totalScenarios);
    final recommended = _recommendedScenario(u?.completedScenarios ?? const []);
    final earned = u?.earnedBadges ?? const <String>[];
    final rank = _rankLabel(u?.level ?? 1);

    return MainScaffold(
      title: 'Dashboard',
      sidebarCtaLabel: 'Deploy Mission',
      sidebarCtaRoute: '/scenarios',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${u?.fullName ?? 'Agent Smith'}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your sector is currently secure. $pending pending training modules required.',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '$rank OPERATOR',
                        style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, c) {
                final cards = [
                  _SummaryCard(
                    label: 'TOTAL SCORE',
                    value: '${u?.totalScore ?? 0}',
                    hint: _loadingMeta ? 'Loading...' : '+${((u?.totalScore ?? 0) * 0.12).round()} from last briefing',
                    icon: Icons.query_stats_outlined,
                    accent: AppColors.primary,
                  ),
                  _SummaryCard(
                    label: 'CURRENT LEVEL',
                    value: '${u?.level ?? 1}',
                    hint: '${(progressPct * 100).round()}% completion',
                    icon: Icons.stars_rounded,
                    accent: const Color(0xFFAEEA94),
                    progress: progressPct,
                  ),
                  _SummaryCard(
                    label: 'SCENARIOS',
                    value: _loadingMeta ? '…' : '$completed/$_totalScenarios',
                    hint: '$pending modules remaining',
                    icon: Icons.shield_outlined,
                    accent: AppColors.secondary,
                  ),
                  _SummaryCard(
                    label: 'ACHIEVEMENTS',
                    value: '${earned.length}',
                    hint: '${earned.isEmpty ? 0 : (earned.length <= 2 ? earned.length : 2)} new unlocks',
                    icon: Icons.military_tech_outlined,
                    accent: AppColors.warning,
                  ),
                ];
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final card in cards)
                      SizedBox(
                        width: c.maxWidth >= 1200 ? (c.maxWidth - 36) / 4 : (c.maxWidth - 12) / 2,
                        child: card,
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, c) {
                final desktop = c.maxWidth > 980;
                if (desktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _RecommendedMissionCard(
                              scenario: recommended,
                              progress: progressPct,
                              onStart: () => context.go('/scenarios${recommended != null ? '/${recommended.id}/play' : ''}'),
                            ),
                            const SizedBox(height: 14),
                            _LearningPathCard(
                              completed: completed,
                              total: _totalScenarios,
                              activeScenario: recommended?.title ?? 'Advanced Phishing Defense',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _BadgePreviewRail(
                          earnedBadgeIds: earned,
                          onViewTrophyRoom: () => context.go('/badges'),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _RecommendedMissionCard(
                      scenario: recommended,
                      progress: progressPct,
                      onStart: () => context.go('/scenarios'),
                    ),
                    const SizedBox(height: 14),
                    _LearningPathCard(
                      completed: completed,
                      total: _totalScenarios,
                      activeScenario: recommended?.title ?? 'Advanced Phishing Defense',
                    ),
                    const SizedBox(height: 14),
                    _BadgePreviewRail(
                      earnedBadgeIds: earned,
                      onViewTrophyRoom: () => context.go('/badges'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  ScenarioModel? _recommendedScenario(List<String> completedIds) {
    if (_scenarios.isEmpty) return null;
    for (final s in _scenarios) {
      if (!completedIds.contains(s.id)) return s;
    }
    return _scenarios.first;
  }

  String _rankLabel(int level) {
    if (level >= 10) return 'SILVER TIER';
    if (level >= 6) return 'BRONZE TIER';
    return 'BASE TIER';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.accent,
    this.progress,
  });

  final String label;
  final String value;
  final String hint;
  final IconData icon;
  final Color accent;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: DesignTokens.shadowCard(Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.3)),
              const Spacer(),
              Icon(icon, size: 16, color: accent),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          if (progress != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress!.clamp(0, 1),
                minHeight: 4,
                backgroundColor: AppColors.border.withValues(alpha: 0.75),
                color: accent,
              ),
            )
          else
            Text(hint, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _RecommendedMissionCard extends StatelessWidget {
  const _RecommendedMissionCard({
    required this.scenario,
    required this.progress,
    required this.onStart,
  });

  final ScenarioModel? scenario;
  final double progress;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final p = (progress * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.55), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.17),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'URGENT BRIEFING',
              style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Recommended Next Step', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(
            scenario?.title ?? 'Advanced Social Engineering Defense',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            scenario?.description ?? 'Learn to identify sophisticated spear-phishing attempts and deepfake voice synthesis attacks.',
            style: const TextStyle(color: AppColors.textMuted, height: 1.35),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('MODULE PROGRESS', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 0.2)),
              const Spacer(),
              Text('$p% COMPLETE', style: const TextStyle(color: AppColors.accentTeal, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 6,
              backgroundColor: AppColors.border.withValues(alpha: 0.8),
              color: const Color(0xFFAEEA94),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB3C7FF),
              foregroundColor: const Color(0xFF122040),
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Start Mission', style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(width: 10),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningPathCard extends StatelessWidget {
  const _LearningPathCard({
    required this.completed,
    required this.total,
    required this.activeScenario,
  });

  final int completed;
  final int total;
  final String activeScenario;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
              const Text('Overall Learning Path', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('View Roadmap')),
            ],
          ),
          const SizedBox(height: 8),
          _PathRow(
            done: true,
            active: true,
            tag: 'BASIC TRAINING',
            title: 'Security Fundamentals 101',
            meta: completed > 0 ? 'Score: 90' : '',
          ),
          const SizedBox(height: 10),
          _PathRow(
            done: false,
            active: true,
            tag: 'ACTIVE MISSION',
            title: activeScenario,
            meta: 'Estimated: 15 min',
          ),
          const SizedBox(height: 10),
          _PathRow(
            done: false,
            active: false,
            tag: 'UNLOCKS AT NEXT',
            title: total > 0 && completed >= total ? 'Threat Hunting Review' : 'Encryption & Cryptography',
            meta: '',
          ),
        ],
      ),
    );
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({
    required this.done,
    required this.active,
    required this.tag,
    required this.title,
    required this.meta,
  });

  final bool done;
  final bool active;
  final String tag;
  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final dot = done
        ? const Color(0xFFAEEA94)
        : active
            ? const Color(0xFFAFC5FF)
            : AppColors.border;
    return Opacity(
      opacity: active || done ? 1 : 0.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dot.withValues(alpha: 0.16),
              border: Border.all(color: dot.withValues(alpha: 0.75)),
            ),
            child: Icon(done ? Icons.check : Icons.rocket_launch_outlined, size: 14, color: dot),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tag, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  if (meta.isNotEmpty) Text(meta, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgePreviewRail extends StatelessWidget {
  const _BadgePreviewRail({
    required this.earnedBadgeIds,
    required this.onViewTrophyRoom,
  });

  final List<String> earnedBadgeIds;
  final VoidCallback onViewTrophyRoom;

  @override
  Widget build(BuildContext context) {
    final top = BadgeCatalog.all.take(4).toList();
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
            children: const [
              Text('Badges', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
              Spacer(),
              Icon(Icons.grid_view_rounded, size: 16, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 8),
          for (final b in top) ...[
            _MiniBadgeRow(
              badge: b,
              unlocked: earnedBadgeIds.contains(b.id),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          TextButton(onPressed: onViewTrophyRoom, child: const Text('VIEW TROPHY ROOM')),
        ],
      ),
    );
  }
}

class _MiniBadgeRow extends StatelessWidget {
  const _MiniBadgeRow({
    required this.badge,
    required this.unlocked,
  });

  final BadgeDefinition badge;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.45,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: badge.faceGradient),
              border: Border.all(color: badge.accentColor.withValues(alpha: 0.45)),
            ),
            child: Icon(
              badge.icon,
              size: 22,
              color: unlocked ? Colors.white : Colors.white54,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(badge.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                  badge.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
