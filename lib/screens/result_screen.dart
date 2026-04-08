import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.scenarioTitle,
    required this.score,
    required this.correct,
    required this.incorrect,
    required this.perfectRun,
    required this.onDone,
  });

  final String scenarioTitle;
  final int score;
  final int correct;
  final int incorrect;
  final bool perfectRun;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scenario complete')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenarioTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (perfectRun)
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.emoji_events, color: Color(0xFFFFA000)),
                        title: Text('Perfect run — no mistakes'),
                      ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.stars_outlined),
                      title: Text('Scenario score: $score'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                      title: Text('Correct decisions: $correct'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.cancel_outlined, color: Colors.red.shade700),
                      title: Text('Incorrect decisions: $incorrect'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onDone,
                        child: const Text('Back to scenarios'),
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
