class UserModel {
  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.totalScore,
    required this.level,
    required this.earnedBadges,
    this.completedScenarios = const [],
  });

  final String id;
  final String fullName;
  final String email;
  final String role;
  final int totalScore;
  final int level;
  final List<String> earnedBadges;
  final List<String> completedScenarios;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
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
