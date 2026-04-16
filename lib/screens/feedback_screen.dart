import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_card.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({
    super.key,
    required this.isCorrect,
    required this.feedbackText,
    required this.pointsEarned,
    required this.onContinue,
  });

  final bool isCorrect;
  final String feedbackText;
  final int pointsEarned;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final safe = isCorrect;
    final c = safe ? AppColors.success : AppColors.danger;
    final bg = AppColors.bg;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: c.withValues(alpha: 0.12),
                            border: Border.all(color: c.withValues(alpha: 0.35)),
                          ),
                          child: Icon(safe ? Icons.verified_outlined : Icons.warning_amber_rounded, color: c),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            safe ? 'Safe decision' : 'Unsafe decision',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            pointsEarned > 0 ? '+$pointsEarned pts' : '+0 pts',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 14),
                    Text(
                      'Feedback',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      feedbackText,
                      style: const TextStyle(height: 1.45, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onContinue,
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
