import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import '../widgets/main_scaffold.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? _data;
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
      _data = await api.analytics();
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
    return MainScaffold(
      title: 'Analytics',
      actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final d = _data!;
    final acc = (d['accuracy'] as num?)?.toDouble() ?? 0;
    final rec = d['recommendation'] as Map<String, dynamic>? ?? {};
    final strengths = (d['strengths'] as List<dynamic>? ?? const []);
    final weaknesses = (d['weaknesses'] as List<dynamic>? ?? const []);
    final totalDecisions = (d['totalDecisions'] as num?)?.toInt() ?? 0;
    final totalCorrect = (d['totalCorrectDecisions'] as num?)?.toInt() ?? 0;
    final completedScenarios = (d['completedScenarios'] as num?)?.toInt() ?? 0;
    final suggested = (rec['suggested'] ?? 'beginner').toString();
    final recReason = (rec['reason'] ?? 'Continue focused practice to unlock better recommendations.').toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My results & analytics',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Track performance across completed attempts — accuracy, strengths, and focus areas.',
            style: TextStyle(color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, c) {
              final tiles = [
                _MetricCard(
                  label: 'Accuracy',
                  value: '${(acc * 100).toStringAsFixed(1)}%',
                  hint: 'Completed attempts',
                  accent: const Color(0xFF42D392),
                ),
                _MetricCard(
                  label: 'Scenarios done',
                  value: '$completedScenarios',
                  hint: 'Unique completions',
                  accent: AppColors.secondary,
                ),
                _MetricCard(
                  label: 'Decisions',
                  value: '$totalCorrect/$totalDecisions',
                  hint: 'Correct / total',
                  accent: const Color(0xFFFFB454),
                ),
                _MetricCard(
                  label: 'Suggested level',
                  value: suggested.toUpperCase(),
                  hint: 'Focus on fundamentals',
                  accent: AppColors.accentTeal,
                ),
              ];
              final columns = c.maxWidth >= 1200
                  ? 4
                  : c.maxWidth >= 820
                      ? 2
                      : 1;
              const gap = 10.0;
              final width = (c.maxWidth - ((columns - 1) * gap)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final tile in tiles) SizedBox(width: width, child: tile),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              final stacked = c.maxWidth < 980;
              final weakCard = _WeaknessesCard(weaknesses: weaknesses);
              final recCard = _RecommendationCard(
                recReason: recReason,
                suggested: suggested,
                acc: acc,
              );
              if (stacked) {
                return Column(
                  children: [
                    weakCard,
                    const SizedBox(height: 10),
                    recCard,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: weakCard),
                  const SizedBox(width: 10),
                  Expanded(child: recCard),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _StrengthsCard(strengths: strengths),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: DesignTokens.shadowCard(Colors.black),
      ),
      child: child,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.hint,
    required this.accent,
  });

  final String label;
  final String value;
  final String hint;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: accent, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(hint, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _WeaknessesCard extends StatelessWidget {
  const _WeaknessesCard({required this.weaknesses});

  final List<dynamic> weaknesses;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weaknesses', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 12),
          if (weaknesses.isEmpty)
            const Text('No major weaknesses detected yet.', style: TextStyle(color: AppColors.textMuted))
          else
            ...weaknesses.take(4).map((s) {
              final m = s as Map<String, dynamic>;
              final type = m['type']?.toString() ?? 'Unknown';
              final pct = (((m['accuracy'] as num?)?.toDouble() ?? 0) * 100).clamp(0, 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(width: 90, child: Text(type, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (pct / 100),
                          minHeight: 4,
                          backgroundColor: AppColors.border.withValues(alpha: 0.8),
                          color: const Color(0xFFFF8A4A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(color: Color(0xFFFF8A4A), fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.recReason,
    required this.suggested,
    required this.acc,
  });

  final String recReason;
  final String suggested;
  final double acc;

  @override
  Widget build(BuildContext context) {
    final remainingToTarget = acc >= 0.7 ? 0 : ((0.7 - acc) * 10).ceil().clamp(1, 4);
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Adaptive recommendation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus on ${suggested.toLowerCase()} fundamentals',
                  style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Suggested: ${suggested.toLowerCase()} content',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            recReason,
            style: const TextStyle(color: AppColors.textMuted, height: 1.35),
          ),
          if (remainingToTarget > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Complete about $remainingToTarget more scenarios to unlock higher-tier recommendations.',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _StrengthsCard extends StatelessWidget {
  const _StrengthsCard({required this.strengths});
  final List<dynamic> strengths;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Strengths', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 10),
          if (strengths.isEmpty)
            const Text('Strengths appear after more completions.', style: TextStyle(color: AppColors.textMuted))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: strengths.map((s) {
                final m = s as Map<String, dynamic>;
                final type = (m['type']?.toString() ?? 'General');
                final pct = (((m['accuracy'] as num?)?.toDouble() ?? 0) * 100).toStringAsFixed(0);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('$type  $pct%', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
