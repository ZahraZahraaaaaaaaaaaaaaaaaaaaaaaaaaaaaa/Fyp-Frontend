import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../badges/badge_catalog.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/badge_medal.dart';
import '../widgets/score_ring.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.scenarioTitle,
    required this.score,
    required this.maxScore,
    required this.normalizedScore,
    required this.correct,
    required this.incorrect,
    required this.perfectRun,
    required this.earnedBadges,
    required this.onDone,
  });

  final String scenarioTitle;
  final int score;
  final int maxScore;
  final int normalizedScore;
  final int correct;
  final int incorrect;
  final bool perfectRun;
  final List<String> earnedBadges;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final total = correct + incorrect;
    final accuracy = total > 0 ? ((correct / total) * 100).round() : 0;
    final headline = perfectRun ? 'Task completed — perfect run' : 'Task completed';
    final feedback = normalizedScore >= 85
        ? 'Excellent judgement. You consistently applied safe verification habits.'
        : normalizedScore >= 65
            ? 'Solid work. Keep applying verification and policy-driven decisions.'
            : 'Good effort. Review the feedback and focus on verifying identity and resisting urgency.';

    return Scaffold(
      appBar: AppBar(title: const Text('Completion')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Congratulations',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(headline, style: const TextStyle(color: AppColors.textMuted, height: 1.3)),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth > 860;
                    final left = AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScoreRing(score: normalizedScore, label: 'Out of 100'),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  scenarioTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _MetricPill(
                                      icon: Icons.stars_outlined,
                                      label: 'Points',
                                      value: '$score${maxScore > 0 ? ' / $maxScore' : ''}',
                                    ),
                                    _MetricPill(
                                      icon: Icons.check_circle_outline,
                                      label: 'Correct',
                                      value: '$correct',
                                      color: AppColors.success,
                                    ),
                                    _MetricPill(
                                      icon: Icons.cancel_outlined,
                                      label: 'Wrong',
                                      value: '$incorrect',
                                      color: AppColors.danger,
                                    ),
                                    _MetricPill(
                                      icon: Icons.percent,
                                      label: 'Accuracy',
                                      value: '$accuracy%',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  feedback,
                                  style: const TextStyle(color: AppColors.textMuted, height: 1.35),
                                ),
                                if (perfectRun) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.emoji_events_outlined, color: AppColors.warning),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Perfect score badge eligible',
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.warning,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );

                    final right = AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Earned achievements',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          if (earnedBadges.isEmpty)
                            const Text('No new badges this run.', style: TextStyle(color: AppColors.textMuted))
                          else
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: earnedBadges.map((id) {
                                final def = BadgeCatalog.byId(id);
                                if (def == null) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface2,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Text(id, style: const TextStyle(color: AppColors.textMuted)),
                                  );
                                }
                                return _EarnedBadgeChip(def: def);
                              }).toList(),
                            ),
                        ],
                      ),
                    );

                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: left),
                          const SizedBox(width: 14),
                          Expanded(flex: 2, child: right),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        left,
                        const SizedBox(height: 12),
                        right,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.dashboard_outlined),
                      label: const Text('Back to dashboard'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.replay_outlined),
                      label: const Text('Replay scenario'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onDone,
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('Continue to scenarios'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _EarnedBadgeChip extends StatelessWidget {
  const _EarnedBadgeChip({required this.def});

  final BadgeDefinition def;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BadgeMedal(
            icon: def.icon,
            faceGradient: def.faceGradient,
            ribbonGradient: def.ribbonGradient,
            size: 40,
          ),
          const SizedBox(width: 10),
          Text(def.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
