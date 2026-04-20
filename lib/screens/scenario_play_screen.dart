import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/scenario_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';
import '../utils/scenario_red_flags.dart';
import '../widgets/figma_progress_bar.dart';
import '../widgets/figma_shell_card.dart';
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
  int _currentStepIndex = 0;
  List<int> _stepOrder = const [];
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
      _currentStepIndex = (a['currentStepIndex'] as num?)?.toInt() ?? 0;
      _stepOrder = (a['stepOrder'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(growable: false);
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
      _currentStepIndex = (attempt['currentStepIndex'] as num?)?.toInt() ?? _currentStepIndex;
      _stepOrder = (attempt['stepOrder'] as List<dynamic>? ?? _stepOrder)
          .map((e) => (e as num).toInt())
          .toList(growable: false);

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
        final beforeBadges = (context.read<AuthProvider>().user?.earnedBadges ?? const <String>[]).toSet();
        final complete = await api.completeAttempt(aid);
        if (!mounted) return;
        await context.read<AuthProvider>().refreshProfile();
        final afterBadges = (context.read<AuthProvider>().user?.earnedBadges ?? const <String>[]).toSet();
        final newlyEarned = afterBadges.difference(beforeBadges).toList()..sort();
        final att = complete['attempt'] as Map<String, dynamic>? ?? {};
        final summary = complete['summary'] as Map<String, dynamic>? ?? {};
        if (!mounted) return;
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              scenarioTitle: _scenario?.title ?? 'Scenario',
              score: (att['score'] as num?)?.toInt() ?? _score,
              maxScore: (att['maxScore'] as num?)?.toInt() ?? 0,
              normalizedScore: (att['normalizedScore'] as num?)?.toInt() ?? 0,
              correct: (summary['correctDecisions'] as num?)?.toInt() ?? _correct,
              incorrect: _incorrect,
              perfectRun: summary['perfectRun'] == true,
              earnedBadges: newlyEarned,
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
    final total = _stepOrder.isNotEmpty ? _stepOrder.length : scenario.steps.length;
    final progressPct = total == 0 ? 0.0 : ((_currentStepIndex + 1) / total * 100);

    final hints = redFlagsForScenarioType(scenario.type);

    Widget mainColumn() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simulation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: SelectableText(
              step?.content ?? '',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.45,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'What should you do?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      backgroundColor: AppColors.surface2,
                      side: const BorderSide(color: AppColors.border, width: 1.5),
                      foregroundColor: AppColors.text,
                    ),
                    onPressed: _submitting ? null : () => _onPick(i),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.radio_button_unchecked, size: 18, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(step.options[i].optionText)),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      );
    }

    Widget sidebar() {
      return FigmaShellCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Red flags to consider',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final line in hints) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(line, style: const TextStyle(color: AppColors.textMuted, height: 1.35, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Pro tip', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                  SizedBox(height: 6),
                  Text(
                    'When in doubt, verify through a trusted channel (official portal, internal directory, or known callback number) before clicking, transferring, or sharing data.',
                    style: TextStyle(color: AppColors.textMuted, height: 1.35, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/scenarios'),
        ),
        title: Text(scenario.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '$_score pts',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 960;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _metaRow(context, scenario),
                            const SizedBox(height: 12),
                            FigmaShellCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Step ${_currentStepIndex + 1} of $total',
                                        style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                      ),
                                      const Spacer(),
                                      Text(
                                        step?.contextLabel ?? '',
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  FigmaProgressBar(
                                    progress: progressPct,
                                    color: FigmaProgressColor.primary,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            mainColumn(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: sidebar()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _metaRow(context, scenario),
                      const SizedBox(height: 12),
                      FigmaShellCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Step ${_currentStepIndex + 1} of $total',
                                  style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                Text(
                                  step?.contextLabel ?? '',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            FigmaProgressBar(
                              progress: progressPct,
                              color: FigmaProgressColor.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      mainColumn(),
                      const SizedBox(height: 16),
                      sidebar(),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _metaRow(BuildContext context, ScenarioModel scenario) {
    Color diff(String d) {
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

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip(context, scenario.type.toUpperCase(), AppColors.primary),
        _chip(context, scenario.difficulty, diff(scenario.difficulty)),
        _chip(context, '~${scenario.estimatedTime} min', AppColors.textMuted),
      ],
    );
  }

  Widget _chip(BuildContext context, String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}
