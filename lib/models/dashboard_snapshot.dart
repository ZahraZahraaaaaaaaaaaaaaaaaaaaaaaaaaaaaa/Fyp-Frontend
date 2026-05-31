class DashboardSnapshot {
  DashboardSnapshot({
    required this.totalScore,
    required this.level,
    required this.earnedBadgesCount,
    required this.completedScenariosCount,
    required this.totalScenariosCount,
    required this.remainingScenariosCount,
    this.earnedBadges = const [],
    this.completedScenarios = const [],
  });

  final int totalScore;
  final int level;
  final int earnedBadgesCount;
  final int completedScenariosCount;
  final int totalScenariosCount;
  final int remainingScenariosCount;
  final List<String> earnedBadges;
  final List<String> completedScenarios;

  factory DashboardSnapshot.fromJson(Map<String, dynamic> json) {
    return DashboardSnapshot(
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      earnedBadgesCount: (json['earnedBadgesCount'] as num?)?.toInt() ?? 0,
      completedScenariosCount: (json['completedScenariosCount'] as num?)?.toInt() ?? 0,
      totalScenariosCount: (json['totalScenariosCount'] as num?)?.toInt() ?? 0,
      remainingScenariosCount: (json['remainingScenariosCount'] as num?)?.toInt() ?? 0,
      earnedBadges: (json['earnedBadges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      completedScenarios: (json['completedScenarios'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
