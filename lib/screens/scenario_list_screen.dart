import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/scenario_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import '../widgets/figma_progress_bar.dart';
import '../widgets/figma_shell_card.dart';
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
    final completedIds = auth.user?.completedScenarios.toSet() ?? {};
    final completedCount = _items.where((s) => completedIds.contains(s.id)).length;
    final total = _items.length;
    final progressPct = total > 0 ? completedCount / total * 100 : 0.0;

    return MainScaffold(
      title: 'Scenarios',
      actions: [
        IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 900;
                      return CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Training scenarios',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Complete scenarios to improve your security awareness. Replay any time — question order changes each attempt.',
                                    style: TextStyle(color: AppColors.textMuted, height: 1.4),
                                  ),
                                  const SizedBox(height: 18),
                                  FigmaShellCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Your progress',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(999),
                                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                                              ),
                                              child: Text(
                                                '$completedCount of $total completed',
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        FigmaProgressBar(
                                          progress: progressPct,
                                          color: FigmaProgressColor.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, wide ? 24 : 16),
                            sliver: SliverToBoxAdapter(
                              child: LayoutBuilder(
                                builder: (context, c) {
                                  const gap = 14.0;
                                  if (!wide) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        for (var i = 0; i < _items.length; i++)
                                          Padding(
                                            padding: EdgeInsets.only(bottom: i < _items.length - 1 ? gap : 0),
                                            child: _ScenarioListCard(
                                              scenario: _items[i],
                                              done: completedIds.contains(_items[i].id),
                                            ),
                                          ),
                                      ],
                                    );
                                  }
                                  final w = (c.maxWidth - gap) / 2;
                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: [
                                      for (final s in _items)
                                        SizedBox(
                                          width: w,
                                          child: _ScenarioListCard(
                                            scenario: s,
                                            done: completedIds.contains(s.id),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

}

/// Shared styling for scenario list cards (also used by `_ScenarioListCard`).
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

class _ScenarioListCard extends StatelessWidget {
  const _ScenarioListCard({required this.scenario, required this.done});

  final ScenarioModel scenario;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final dc = ScenarioListStyle.difficultyColor(scenario.difficulty);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        onTap: () => context.go('/scenarios/${scenario.id}/play'),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(color: AppColors.border),
            boxShadow: DesignTokens.shadowCard(Colors.black),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: done ? AppColors.success.withValues(alpha: 0.12) : AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      border: Border.all(
                        color: done ? AppColors.success.withValues(alpha: 0.35) : AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Icon(
                      ScenarioListStyle.typeIcon(scenario.type),
                      color: done ? AppColors.success : AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      scenario.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    done ? Icons.check_circle_outline : Icons.schedule_outlined,
                    color: done ? AppColors.success : AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                scenario.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textMuted, height: 1.35, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ScenarioListStyle.pill(scenario.difficulty, dc),
                        ScenarioListStyle.pill(scenario.type.toUpperCase(), AppColors.textMuted),
                        ScenarioListStyle.pill('~${scenario.estimatedTime} min', AppColors.textMuted),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => context.go('/scenarios/${scenario.id}/play'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 34),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(done ? 'Replay' : 'Start'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
