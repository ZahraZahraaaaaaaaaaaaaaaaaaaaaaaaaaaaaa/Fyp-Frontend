import 'package:flutter/material.dart';

import '../badges/badge_catalog.dart';
import '../theme/app_colors.dart';

class BadgeGalleryCard extends StatefulWidget {
  const BadgeGalleryCard({
    super.key,
    required this.badge,
    required this.unlocked,
  });

  final BadgeDefinition badge;
  final bool unlocked;

  @override
  State<BadgeGalleryCard> createState() => _BadgeGalleryCardState();
}

class _BadgeGalleryCardState extends State<BadgeGalleryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.badge;
    final unlocked = widget.unlocked;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -3 : 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unlocked ? const Color(0xFF111E3F) : const Color(0xFF0A1227),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked ? b.accentColor.withValues(alpha: 0.35) : AppColors.border.withValues(alpha: 0.85),
          ),
          boxShadow: [
            BoxShadow(
              color: unlocked ? b.accentColor.withValues(alpha: _hovered ? 0.25 : 0.16) : Colors.black.withValues(alpha: 0.25),
              blurRadius: _hovered ? 28 : 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _RarityChip(rarity: b.rarity),
                const Spacer(),
                Icon(
                  unlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                  size: 16,
                  color: unlocked ? b.accentColor : AppColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: b.faceGradient),
                  border: Border.all(color: b.accentColor.withValues(alpha: unlocked ? 0.7 : 0.18), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: b.accentColor.withValues(alpha: unlocked ? 0.32 : 0.06),
                      blurRadius: 26,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  b.icon,
                  size: 34,
                  color: unlocked ? const Color(0xFF081020) : AppColors.textMuted.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              b.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              b.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.3),
            ),
            const SizedBox(height: 8),
            Text(
              b.progressText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unlocked ? b.accentColor : AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: unlocked ? b.accentColor.withValues(alpha: 0.16) : AppColors.surface2,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: unlocked ? b.accentColor.withValues(alpha: 0.4) : AppColors.border,
                      ),
                    ),
                    child: Text(
                      unlocked ? 'UNLOCKED' : 'LOCKED',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: unlocked ? b.accentColor : AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${b.points}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RarityChip extends StatelessWidget {
  const _RarityChip({required this.rarity});

  final BadgeRarity rarity;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    switch (rarity) {
      case BadgeRarity.common:
        label = 'COMMON';
        color = const Color(0xFF52E5A3);
        break;
      case BadgeRarity.rare:
        label = 'RARE';
        color = const Color(0xFF8DA4FF);
        break;
      case BadgeRarity.epic:
        label = 'EPIC';
        color = const Color(0xFFF66CA0);
        break;
      case BadgeRarity.legendary:
        label = 'LEGENDARY';
        color = const Color(0xFFFFC54D);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
    );
  }
}

