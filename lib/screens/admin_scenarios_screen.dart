import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/scenario_model.dart';
import '../services/api_service.dart';
import '../widgets/main_scaffold.dart';

class AdminScenariosScreen extends StatefulWidget {
  const AdminScenariosScreen({super.key});

  @override
  State<AdminScenariosScreen> createState() => _AdminScenariosScreenState();
}

class _AdminScenariosScreenState extends State<AdminScenariosScreen> {
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

  Future<void> _toggle(ScenarioModel s) async {
    final api = context.read<ApiService>();
    try {
      await api.updateScenario(s.id, {'isActive': !s.isActive});
      await _load();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _delete(ScenarioModel s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete scenario'),
        content: Text('Delete "${s.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    final api = context.read<ApiService>();
    try {
      await api.deleteScenario(s.id);
      await _load();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _editMeta(ScenarioModel s) async {
    final title = TextEditingController(text: s.title);
    final desc = TextEditingController(text: s.description);
    final time = TextEditingController(text: '${s.estimatedTime}');
    var difficulty = s.difficulty;
    var type = s.type;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: const Text('Edit scenario'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
                  TextField(
                    controller: desc,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  TextField(
                    controller: time,
                    decoration: const InputDecoration(labelText: 'Estimated minutes'),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButton<String>(
                    value: difficulty,
                    items: const [
                      DropdownMenuItem(value: 'beginner', child: Text('beginner')),
                      DropdownMenuItem(value: 'intermediate', child: Text('intermediate')),
                      DropdownMenuItem(value: 'advanced', child: Text('advanced')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setLocal(() => difficulty = v);
                    },
                  ),
                  DropdownButton<String>(
                    value: type,
                    items: const [
                      DropdownMenuItem(value: 'phishing', child: Text('phishing')),
                      DropdownMenuItem(value: 'vishing', child: Text('vishing')),
                      DropdownMenuItem(value: 'baiting', child: Text('baiting')),
                      DropdownMenuItem(value: 'impersonation', child: Text('impersonation')),
                      DropdownMenuItem(value: 'invoice_scam', child: Text('invoice_scam')),
                      DropdownMenuItem(value: 'mixed', child: Text('mixed')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setLocal(() => type = v);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
            ],
          );
        },
      ),
    );
    if (ok != true) {
      title.dispose();
      desc.dispose();
      time.dispose();
      return;
    }
    if (!mounted) {
      title.dispose();
      desc.dispose();
      time.dispose();
      return;
    }

    final payload = {
      'title': title.text.trim(),
      'description': desc.text.trim(),
      'estimatedTime': int.tryParse(time.text.trim()) ?? s.estimatedTime,
      'difficulty': difficulty,
      'type': type,
    };
    title.dispose();
    desc.dispose();
    time.dispose();

    final api = context.read<ApiService>();
    try {
      await api.updateScenario(s.id, payload);
      await _load();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Scenario management',
      actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final s = _items[i];
                    return Card(
                      child: ListTile(
                        title: Text(s.title),
                        subtitle: Text('${s.type} • ${s.difficulty} • ${s.steps.length} steps'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              tooltip: 'Active',
                              onPressed: () => _toggle(s),
                              icon: Icon(s.isActive ? Icons.visibility : Icons.visibility_off),
                            ),
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => _editMeta(s),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () => _delete(s),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
