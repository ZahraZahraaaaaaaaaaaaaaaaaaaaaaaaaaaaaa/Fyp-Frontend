import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
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
          Text('Performance', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Accuracy (completed attempts)'),
                  trailing: Text('${(acc * 100).toStringAsFixed(1)}%'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Completed scenarios'),
                  trailing: Text('${d['completedScenarios']}'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Total correct decisions'),
                  trailing: Text('${d['totalCorrectDecisions']} / ${d['totalDecisions']}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Adaptive recommendation', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: Text((rec['suggested'] ?? 'beginner').toString().toUpperCase()),
              subtitle: Text((rec['reason'] ?? '').toString()),
            ),
          ),
          const SizedBox(height: 20),
          Text('Strengths', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (strengths.isEmpty)
            const Text('Play more scenarios to see strengths by attack type.')
          else
            ...strengths.map((s) {
              final m = s as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.verified_outlined, color: Color(0xFF2E7D32)),
                title: Text(m['type']?.toString() ?? ''),
                trailing: Text('${(((m['accuracy'] as num?)?.toDouble() ?? 0) * 100).toStringAsFixed(0)}%'),
              );
            }),
          const SizedBox(height: 16),
          Text('Weaknesses', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (weaknesses.isEmpty)
            const Text('No major weaknesses detected yet.')
          else
            ...weaknesses.map((s) {
              final m = s as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.warning_amber_outlined, color: Color(0xFFC62828)),
                title: Text(m['type']?.toString() ?? ''),
                trailing: Text('${(((m['accuracy'] as num?)?.toDouble() ?? 0) * 100).toStringAsFixed(0)}%'),
              );
            }),
        ],
      ),
    );
  }
}
