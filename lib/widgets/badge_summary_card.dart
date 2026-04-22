import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BadgeSummaryCard extends StatelessWidget {
  const BadgeSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    this.progress,
    this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final double? progress;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1D3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (progress != null)
            _ProgressRing(progress: progress!.clamp(0, 1), accent: accent)
          else
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon ?? Icons.auto_awesome, color: accent, size: 20),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1,
            strokeWidth: 5,
            color: AppColors.border.withValues(alpha: 0.9),
          ),
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 5,
            color: accent,
          ),
          Center(
            child: Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

