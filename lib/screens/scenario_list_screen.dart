import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/scenario_model.dart';
import '../services/api_service.dart';
import '../widgets/app_card.dart';
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

  Color _diffColor(String d) {
    switch (d) {
      case 'beginner':
        return const Color(0xFF2E7D32);
      case 'intermediate':
        return const Color(0xFFF9A825);
      case 'advanced':
        return const Color(0xFFC62828);
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final s = _items[i];
                      return AppCard(
                        onTap: () => context.go('/scenarios/${s.id}/play'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    s.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Chip(
                                  label: Text(s.difficulty),
                                  backgroundColor: _diffColor(s.difficulty).withValues(alpha: 0.15),
                                  side: BorderSide(color: _diffColor(s.difficulty).withValues(alpha: 0.4)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(s.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.category_outlined, size: 16, color: Colors.grey.shade700),
                                const SizedBox(width: 4),
                                Text(s.type.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
                                const SizedBox(width: 16),
                                Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade700),
                                const SizedBox(width: 4),
                                Text('~${s.estimatedTime} min', style: Theme.of(context).textTheme.labelSmall),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
