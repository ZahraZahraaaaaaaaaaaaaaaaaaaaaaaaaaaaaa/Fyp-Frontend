import 'package:flutter/material.dart';

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
    final c = safe ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C);
    final bg = safe ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(safe ? Icons.check_circle : Icons.error_outline, color: c, size: 32),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              safe ? 'Good decision' : 'Risky decision',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: c,
                                  ),
                            ),
                          ),
                          Chip(
                            label: Text('+$pointsEarned pts'),
                            backgroundColor: Colors.blue.shade50,
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      Text(
                        'Feedback',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        feedbackText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
                      ),
                      const SizedBox(height: 20),
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
      ),
    );
  }
}
