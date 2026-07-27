import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../badges/badge_catalog.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/badge_gallery_card.dart';
import '../widgets/badge_summary_card.dart';
import '../widgets/main_scaffold.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  // Real cross-user rank from GET /api/analytics/me. Null until it loads (or
  // if the request fails), in which case we fall back to a locally-estimated
  // value so the screen still renders something reasonable.
  int? _realTopPercentile;
  int? _totalUsers;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRank());
  }

  Future<void> _loadRank() async {
    try {
      final api = context.read<ApiService>();
      final data = await api.analytics();
      final rank = data['globalRank'] as Map<String, dynamic>?;
      if (!mounted || rank == null) return;
      setState(() {
        _realTopPercentile = rank['topPercentile'] as int?;
        _totalUsers = rank['totalUsers'] as int?;
      });
    } catch (_) {
      // Keep the badges screen functional even if analytics is unreachable;
      // the estimated fallback below still renders.
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final earned = (auth.user?.earnedBadges ?? const <String>[]).toSet();
    final totalBadges = BadgeCatalog.all.length;
    final completion = totalBadges == 0 ? 0.0 : earned.length / totalBadges;
    final achievementPoints = BadgeCatalog.all
        .where((b) => earned.contains(b.id))
        .fold<int>(0, (sum, b) => sum + b.points);
    final estimatedPercentile = (12 + ((1 - completion) * 28)).round().clamp(1, 99);
    final percentile = _realTopPercentile ?? estimatedPercentile;
    final percentileSubtitle = _realTopPercentile != null
        ? 'Rank among $_totalUsers registered user${_totalUsers == 1 ? '' : 's'}'
        : 'Estimated — rank snapshot';

    final content = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.authGradientStart, AppColors.authGradientEnd],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Badge Gallery',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Showcase your digital defense prowess. Complete security modules and',
              style: TextStyle(color: AppColors.textMuted, height: 1.35),
            ),
            Text(
              'maintain perfect streaks to earn high-tier elite badges.',
              style: TextStyle(color: AppColors.textMuted, height: 1.35),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth >= 900;
                final cards = [
                  BadgeSummaryCard(
                    title: 'COMPLETION STATUS',
                    value: '${earned.length} / $totalBadges',
                    subtitle: 'Elite rank attainable in ${totalBadges - earned.length} more badges',
                    accent: const Color(0xFF38D39F),
                    progress: completion,
                  ),
                  BadgeSummaryCard(
                    title: 'Achievement Points',
                    value: '$achievementPoints',
                    subtitle: 'Current score',
                    accent: const Color(0xFFFFB946),
                    icon: Icons.stars_rounded,
                  ),
                  BadgeSummaryCard(
                    title: 'Global Percentile',
                    value: 'Top $percentile%',
                    subtitle: percentileSubtitle,
                    accent: const Color(0xFF8DA4FF),
                    icon: Icons.trending_up_rounded,
                  ),
                ];
                if (!wide) {
                  return Column(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        cards[i],
                        if (i < cards.length - 1) const SizedBox(height: 10),
                      ],
                    ],
                  );
                }
                return Row(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      Expanded(child: cards[i]),
                      if (i < cards.length - 1) const SizedBox(width: 12),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, c) {
                int cols = 2;
                if (c.maxWidth >= 1180) cols = 4;
                if (c.maxWidth >= 840 && c.maxWidth < 1180) cols = 3;
                if (c.maxWidth < 640) cols = 2;
                final gap = 12.0;
                final cardW = (c.maxWidth - ((cols - 1) * gap)) / cols;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final b in BadgeCatalog.all)
                      SizedBox(
                        width: cardW,
                        height: 300,
                        child: BadgeGalleryCard(
                          badge: b,
                          unlocked: earned.contains(b.id),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );

    return MainScaffold(
      title: 'Achievements',
      child: content,
    );
  }
}
