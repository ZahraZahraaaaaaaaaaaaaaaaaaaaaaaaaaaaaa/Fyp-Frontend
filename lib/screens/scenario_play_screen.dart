import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/scenario_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'feedback_screen.dart';
import 'result_screen.dart';
import 'simulation_screen.dart';

class ScenarioPlayScreen extends StatefulWidget {
  const ScenarioPlayScreen({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  State<ScenarioPlayScreen> createState() => _ScenarioPlayScreenState();
}

class _ScenarioPlayScreenState extends State<ScenarioPlayScreen> {
  ScenarioModel? _scenario;
  String? _attemptId;
  int _currentStepNumber = 1;
  int _score = 0;
  int _correct = 0;
  int _incorrect = 0;
  String? _error;
  bool _loading = true;
  bool _submitting = false;

  ScenarioStep? get _step {
    final s = _scenario;
    if (s == null) return null;
    for (final st in s.steps) {
      if (st.stepNumber == _currentStepNumber) return st;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final api = context.read<ApiService>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sMap = await api.scenario(widget.scenarioId);
      _scenario = ScenarioModel.fromJson(sMap);
      final start = await api.startAttempt(widget.scenarioId);
      final a = start['attempt'] as Map<String, dynamic>;
      _attemptId = a['id']?.toString();
      _currentStepNumber = (a['currentStepNumber'] as num?)?.toInt() ?? 1;
      _score = (a['score'] as num?)?.toInt() ?? 0;
      _correct = (a['correctDecisions'] as num?)?.toInt() ?? 0;
      _incorrect = (a['incorrectDecisions'] as num?)?.toInt() ?? 0;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onPick(int optionIndex) async {
    final api = context.read<ApiService>();
    final step = _step;
    final aid = _attemptId;
    if (step == null || aid == null || _submitting) return;

    setState(() => _submitting = true);
    try {
      final res = await api.submitDecision(aid, step.stepNumber, optionIndex);
      final attempt = res['attempt'] as Map<String, dynamic>;
      _score = (attempt['score'] as num?)?.toInt() ?? _score;
      _correct = (attempt['correctDecisions'] as num?)?.toInt() ?? _correct;
      _incorrect = (attempt['incorrectDecisions'] as num?)?.toInt() ?? _incorrect;
      _currentStepNumber = (attempt['currentStepNumber'] as num?)?.toInt() ?? _currentStepNumber;

      final sim = res['simulation'] as Map<String, dynamic>? ?? {};
      final fb = res['feedback'] as Map<String, dynamic>? ?? {};

      final showSim = sim['showSimulation'] == true;
      if (showSim && mounted) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => SimulationScreen(
              simulationType: (sim['simulationType'] ?? 'phishing_alert').toString(),
              title: (sim['simulationTitle'] ?? 'Security alert').toString(),
              lines: (sim['simulationLines'] as List<dynamic>? ?? const [])
                  .map((e) => e.toString())
                  .toList(),
              onContinue: () => Navigator.of(context).pop(),
            ),
          ),
        );
      }

      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => FeedbackScreen(
            isCorrect: fb['isCorrect'] == true,
            feedbackText: (fb['feedbackText'] ?? '').toString(),
            pointsEarned: (fb['pointsEarned'] as num?)?.toInt() ?? 0,
            onContinue: () => Navigator.of(context).pop(),
          ),
        ),
      );

      final end = fb['isScenarioEnd'] == true;
      if (end && mounted) {
        final complete = await api.completeAttempt(aid);
        if (!mounted) return;
        await context.read<AuthProvider>().refreshProfile();
        final att = complete['attempt'] as Map<String, dynamic>? ?? {};
        final summary = complete['summary'] as Map<String, dynamic>? ?? {};
        if (!mounted) return;
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              scenarioTitle: _scenario?.title ?? 'Scenario',
              score: (att['score'] as num?)?.toInt() ?? _score,
              correct: (summary['correctDecisions'] as num?)?.toInt() ?? _correct,
              incorrect: _incorrect,
              perfectRun: summary['perfectRun'] == true,
              onDone: () {
                context.go('/scenarios');
              },
            ),
          ),
        );
      } else if (mounted) {
        setState(() {});
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scenario')),
        body: Center(child: Text(_error!)),
      );
    }
    final scenario = _scenario!;
    final step = _step;
    final total = scenario.steps.length;
    final idx = scenario.steps.indexWhere((s) => s.stepNumber == step?.stepNumber);
    final progress = total == 0 ? 0.0 : (idx + 1) / total;

    return Scaffold(
      appBar: AppBar(
        title: Text(scenario.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '$_score pts',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(value: progress.clamp(0, 1)),
                const SizedBox(height: 8),
                Text(
                  step?.contextLabel ?? 'Step',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Simulation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: SelectableText(
                      step?.content ?? '',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        height: 1.45,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'What do you do?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  if (step == null)
                    const Text('No step found.')
                  else
                    ...List.generate(step.options.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(16),
                            ),
                            onPressed: _submitting ? null : () => _onPick(i),
                            child: Text(step.options[i].optionText),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
