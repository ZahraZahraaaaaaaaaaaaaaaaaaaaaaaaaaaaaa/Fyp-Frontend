import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/scenario_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import '../widgets/main_scaffold.dart';

class ScenarioListScreen extends StatefulWidget {
  const ScenarioListScreen({super.key});

  @override
  State<ScenarioListScreen> createState() => _ScenarioListScreenState();
}

class _ScenarioListScreenState extends State<ScenarioListScreen> {
  List<ScenarioModel> _items = [];
  String? _error;
  bool _loading = true;
  String _activeCategory = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final raw = await api.scenarios();
      _items = raw.map((e) => ScenarioModel.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userLevel = auth.user?.level ?? 1;
    final completedIds = auth.user?.completedScenarios.toSet() ?? {};
    final completedCount = _items.where((s) => completedIds.contains(s.id)).length;
    final total = _items.length;
    final progressPct = total > 0 ? completedCount / total : 0.0;
    final categories = _buildCategories(_items);
    final visible = _filteredItems(_items, _activeCategory);

    return MainScaffold(
      title: 'Scenarios',
      sidebarCtaLabel: 'Start Daily Drill',
      sidebarCtaRoute: '/scenarios',
      actions: [
        IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        sliver: SliverToBoxAdapter(
                          child: _ScenariosHeader(
                            completedCount: completedCount,
                            total: total,
                            progressPct: progressPct,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                        sliver: SliverToBoxAdapter(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final c in categories)
                                _CategoryTab(
                                  label: c.label,
                                  active: _activeCategory == c.id,
                                  onTap: () => setState(() => _activeCategory = c.id),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        sliver: SliverToBoxAdapter(
                          child: LayoutBuilder(
                            builder: (context, c) {
                              final cols = c.maxWidth >= 1300
                                  ? 3
                                  : c.maxWidth >= 900
                                      ? 2
                                      : 1;
                              const gap = 14.0;
                              final cardW = (c.maxWidth - ((cols - 1) * gap)) / cols;
                              return Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: [
                                  for (final s in visible)
                                    SizedBox(
                                      width: cardW,
                                      child: _ScenarioGridCard(
                                        scenario: s,
                                        done: completedIds.contains(s.id),
                                        locked: _isLocked(s, userLevel),
                                        userLevel: userLevel,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                        sliver: SliverToBoxAdapter(
                          child: _DailyChallengeBanner(
                            completedTodayHint: completedCount >= 2 ? 'Mission streak active.' : 'Complete 2 scenarios today to maintain your streak.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  bool _isLocked(ScenarioModel s, int userLevel) {
    if (!s.isActive) return true;
    return userLevel < _requiredLevelFor(s);
  }

  int _requiredLevelFor(ScenarioModel s) {
    switch (s.difficulty.toLowerCase()) {
      case 'advanced':
        return 5;
      case 'intermediate':
        return 3;
      default:
        return 1;
    }
  }

  List<_ScenarioCategory> _buildCategories(List<ScenarioModel> items) {
    final set = <String>{};
    for (final item in items) {
      final normalized = item.type.trim().toLowerCase();
      if (normalized.isNotEmpty) set.add(normalized);
    }
    final sorted = set.toList()..sort();
    return [
      const _ScenarioCategory(id: 'all', label: 'All Modules'),
      ...sorted.map((e) => _ScenarioCategory(id: e, label: _prettyType(e))),
    ];
  }

  List<ScenarioModel> _filteredItems(List<ScenarioModel> items, String category) {
    if (category == 'all') return items;
    final out = items.where((s) => s.type.trim().toLowerCase() == category).toList();
    return out.isEmpty ? items : out;
  }

  static String _prettyType(String type) {
    if (type.isEmpty) return 'General';
    return type
        .split(RegExp(r'[\s_-]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

}

abstract final class ScenarioListStyle {
  static Color difficultyColor(String d) {
    switch (d) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.danger;
      default:
        return AppColors.textMuted;
    }
  }

  static IconData typeIcon(String t) {
    switch (t) {
      case 'phishing':
        return Icons.mail_outline;
      case 'vishing':
        return Icons.phone_in_talk_outlined;
      case 'baiting':
        return Icons.usb_outlined;
      case 'impersonation':
        return Icons.badge_outlined;
      default:
        return Icons.sim_card_outlined;
    }
  }

  static Widget pill(String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ScenarioCategory {
  const _ScenarioCategory({required this.id, required this.label});
  final String id;
  final String label;
}

class _ScenariosHeader extends StatelessWidget {
  const _ScenariosHeader({
    required this.completedCount,
    required this.total,
    required this.progressPct,
  });

  final int completedCount;
  final int total;
  final double progressPct;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 900;
        final progress = Container(
          constraints: BoxConstraints(minWidth: compact ? double.infinity : 250, maxWidth: compact ? double.infinity : 280),
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
                  const Text('YOUR PROGRESS', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('$completedCount of $total completed', style: const TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progressPct.clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: AppColors.border.withValues(alpha: 0.8),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Training Scenarios', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text(
                'Sharpen your security instincts with immersive, realistic simulations and decision-based learning.',
                style: TextStyle(color: AppColors.textMuted, height: 1.35),
              ),
              const SizedBox(height: 14),
              progress,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Training Scenarios', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text(
                    'Sharpen your security instincts with immersive, realistic simulations.\nMaster threat detection through active practice.',
                    style: TextStyle(color: AppColors.textMuted, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            progress,
          ],
        );
      },
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ScenarioGridCard extends StatefulWidget {
  const _ScenarioGridCard({
    required this.scenario,
    required this.done,
    required this.locked,
    required this.userLevel,
  });

  final ScenarioModel scenario;
  final bool done;
  final bool locked;
  final int userLevel;

  @override
  State<_ScenarioGridCard> createState() => _ScenarioGridCardState();
}

class _ScenarioGridCardState extends State<_ScenarioGridCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.scenario;
    final dc = ScenarioListStyle.difficultyColor(s.difficulty);
    final requiredLevel = _requiredLevelFor(s);
    final xp = (s.steps.length * 5).clamp(20, 120);
    final locked = widget.locked;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hover ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border),
          boxShadow: _hover ? DesignTokens.shadowCardHover(AppColors.primary) : DesignTokens.shadowCard(Colors.black),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 96,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: locked
                      ? [const Color(0xFF1A2236), const Color(0xFF0D1426)]
                      : [AppColors.surface2, AppColors.primary.withValues(alpha: 0.28)],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: locked ? AppColors.surface : AppColors.primary.withValues(alpha: 0.17),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: locked ? AppColors.border : AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Icon(
                      locked ? Icons.lock_outline : ScenarioListStyle.typeIcon(s.type),
                      size: 20,
                      color: locked ? AppColors.textMuted : AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text('~ ${s.estimatedTime} min', style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ScenarioListStyle.pill(_prettyType(s.type), AppColors.primary),
                      ScenarioListStyle.pill(_prettyType(s.difficulty), dc),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textMuted, height: 1.35, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: AppColors.border.withValues(alpha: 0.7)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.bolt, size: 14, color: AppColors.accentTeal),
                            const SizedBox(width: 4),
                            Text('$xp XP', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                            const SizedBox(width: 10),
                            Icon(widget.done ? Icons.check_circle : Icons.flag_outlined, size: 14, color: widget.done ? AppColors.success : AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(widget.done ? 'Completed' : 'Pending', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: locked ? null : () => context.go('/scenarios/${s.id}/play'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(84, 34),
                          backgroundColor: const Color(0xFF1A73E8),
                          disabledBackgroundColor: AppColors.surface2,
                        ),
                        child: Text(locked ? 'Locked' : (widget.done ? 'Replay' : 'Start')),
                      ),
                    ],
                  ),
                  if (locked) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Unlock at level $requiredLevel (current: ${widget.userLevel})',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _requiredLevelFor(ScenarioModel s) {
    switch (s.difficulty.toLowerCase()) {
      case 'advanced':
        return 5;
      case 'intermediate':
        return 3;
      default:
        return 1;
    }
  }

  String _prettyType(String type) {
    if (type.isEmpty) return 'General';
    return type
        .split(RegExp(r'[\s_-]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class _DailyChallengeBanner extends StatelessWidget {
  const _DailyChallengeBanner({required this.completedTodayHint});
  final String completedTodayHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A4CC2), Color(0xFF0B7FA5)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Streak Challenge',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  completedTodayHint,
                  style: const TextStyle(color: Color(0xFFD6E6FF), height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF15408C),
              minimumSize: const Size(150, 44),
            ),
            child: const Text('Claim Daily Bonus'),
          ),
        ],
      ),
    );
  }
}
