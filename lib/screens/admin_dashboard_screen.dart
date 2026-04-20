import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/figma_shell_card.dart';
import '../widgets/figma_stat_tile.dart';
import '../widgets/main_scaffold.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _overview;
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
      _overview = await api.adminOverview();
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
      title: 'Admin',
      actions: [
        IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        TextButton(
          onPressed: () => context.go('/admin/scenarios'),
          child: const Text('Scenarios'),
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administration',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Operational overview for users, scenarios, attempts, and completion rate.',
                        style: TextStyle(color: AppColors.textMuted, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, c) {
                          final quad = c.maxWidth > 1000;
                          final tiles = [
                            FigmaStatTile(
                              label: 'Users',
                              value: '${_overview?['totalUsers'] ?? 0}',
                              icon: Icons.people_outline,
                              accent: AppColors.primary,
                            ),
                            FigmaStatTile(
                              label: 'Scenarios',
                              value: '${_overview?['totalScenarios'] ?? 0}',
                              icon: Icons.movie_creation_outlined,
                              accent: AppColors.secondary,
                            ),
                            FigmaStatTile(
                              label: 'Attempts',
                              value: '${_overview?['totalAttempts'] ?? 0}',
                              icon: Icons.history,
                              accent: AppColors.accentTeal,
                            ),
                            FigmaStatTile(
                              label: 'Completion rate',
                              value: '${_overview?['completionRate'] ?? 0}',
                              icon: Icons.check_circle_outline,
                              accent: AppColors.success,
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
                              'Quick actions',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton.icon(
                                  onPressed: () => context.go('/admin/scenarios'),
                                  icon: const Icon(Icons.edit_note),
                                  label: const Text('Manage scenarios'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final api = context.read<ApiService>();
                                    try {
                                      final stats = await api.adminScenarioStats();
                                      if (!context.mounted) return;
                                      showModalBottomSheet<void>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: AppColors.surface,
                                        builder: (c) => DraggableScrollableSheet(
                                          expand: false,
                                          initialChildSize: 0.65,
                                          builder: (_, controller) => Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: ListView(
                                              controller: controller,
                                              children: [
                                                Text(
                                                  'Hardest scenarios (lowest avg correct decisions)',
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                                ),
                                                const SizedBox(height: 12),
                                                ...(stats['hardestScenarios'] as List<dynamic>? ?? const []).map(
                                                  (x) {
                                                    final m = x as Map<String, dynamic>;
                                                    return ListTile(
                                                      title: Text(m['title']?.toString() ?? ''),
                                                      subtitle: Text(m['type']?.toString() ?? ''),
                                                      trailing: Text('avg ${m['averageCorrectDecisions']}'),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    } on ApiException catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.analytics_outlined),
                                  label: const Text('Scenario stats'),
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
