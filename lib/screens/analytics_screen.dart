import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import '../widgets/figma_shell_card.dart';
import '../widgets/figma_stat_tile.dart';
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My results & analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Track your performance across completed attempts — accuracy, strengths, and focus areas.',
            style: TextStyle(color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, c) {
              final quad = c.maxWidth > 1000;
              final tiles = [
                FigmaStatTile(
                  label: 'Accuracy',
                  value: '${(acc * 100).toStringAsFixed(1)}%',
                  icon: Icons.track_changes_outlined,
                  accent: AppColors.primary,
                  delta: 'Completed attempts',
                ),
                FigmaStatTile(
                  label: 'Scenarios completed',
                  value: '${d['completedScenarios']}',
                  icon: Icons.flag_outlined,
                  accent: AppColors.success,
                  delta: 'Unique completions',
                ),
                FigmaStatTile(
                  label: 'Decisions',
                  value: '${d['totalCorrectDecisions']} / ${d['totalDecisions']}',
                  icon: Icons.rule_folder_outlined,
                  accent: AppColors.secondary,
                  delta: 'Correct / total',
                ),
                FigmaStatTile(
                  label: 'Suggested difficulty',
                  value: (rec['suggested'] ?? 'beginner').toString().toUpperCase(),
                  icon: Icons.auto_graph_outlined,
                  accent: AppColors.accentTeal,
                  delta: (rec['reason'] ?? '').toString(),
                ),
              ];
              if (quad) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < tiles.length; i++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < tiles.length - 1 ? 12 : 0),
                          child: tiles[i],
                        ),
                      ),
                  ],
                );
              }
              return Column(
                children: [for (final t in tiles) Padding(padding: const EdgeInsets.only(bottom: 12), child: t)],
              );
            },
          ),
          const SizedBox(height: 18),
          FigmaShellCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adaptive recommendation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  (rec['reason'] ?? '').toString(),
                  style: const TextStyle(color: AppColors.textMuted, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Strengths', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (strengths.isEmpty)
            const Text('Play more scenarios to see strengths by attack type.', style: TextStyle(color: AppColors.textMuted))
          else
            ...strengths.map((s) {
              final m = s as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_outlined, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(child: Text(m['type']?.toString() ?? '')),
                      Text(
                        '${(((m['accuracy'] as num?)?.toDouble() ?? 0) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),
          Text('Weaknesses', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (weaknesses.isEmpty)
            const Text('No major weaknesses detected yet.', style: TextStyle(color: AppColors.textMuted))
          else
            ...weaknesses.map((s) {
              final m = s as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_outlined, color: AppColors.danger),
                      const SizedBox(width: 12),
                      Expanded(child: Text(m['type']?.toString() ?? '')),
                      Text(
                        '${(((m['accuracy'] as num?)?.toDouble() ?? 0) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
