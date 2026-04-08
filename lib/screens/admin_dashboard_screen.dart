import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
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
                        'Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _AdminTile(
                            title: 'Users',
                            value: '${_overview?['totalUsers'] ?? 0}',
                            icon: Icons.people_outline,
                          ),
                          _AdminTile(
                            title: 'Scenarios',
                            value: '${_overview?['totalScenarios'] ?? 0}',
                            icon: Icons.movie_creation_outlined,
                          ),
                          _AdminTile(
                            title: 'Attempts',
                            value: '${_overview?['totalAttempts'] ?? 0}',
                            icon: Icons.history,
                          ),
                          _AdminTile(
                            title: 'Completion rate',
                            value: '${_overview?['completionRate'] ?? 0}',
                            icon: Icons.check_circle_outline,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.go('/admin/scenarios'),
                        icon: const Icon(Icons.edit_note),
                        label: const Text('Manage scenarios'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final api = context.read<ApiService>();
                          try {
                            final stats = await api.adminScenarioStats();
                            if (!context.mounted) return;
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
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
                                        style: Theme.of(context).textTheme.titleMedium,
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
                ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodySmall),
                    Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
