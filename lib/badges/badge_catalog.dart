import 'package:flutter/material.dart';

enum BadgeRarity { common, rare, epic, legendary }

enum BadgeCategory { foundational, scenario, performance, mastery }

class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    required this.icon,
    required this.faceGradient,
    required this.ribbonGradient,
    required this.category,
    required this.rarity,
    required this.progressText,
    required this.points,
    required this.accentColor,
  });

  final String id;
  final String name;
  final String description;
  final String condition;
  final IconData icon;
  final List<Color> faceGradient;
  final List<Color> ribbonGradient;
  final BadgeCategory category;
  final BadgeRarity rarity;
  final String progressText;
  final int points;
  final Color accentColor;
}

class BadgeCatalog {
  static const String firstScenario = 'first_scenario_completed';
  static const String awarenessStarter = 'awareness_starter';
  static const String phishingDetector = 'phishing_detector';
  static const String vishingAware = 'vishing_aware';
  static const String baitingBlocker = 'baiting_blocker';
  static const String impersonationDefender = 'impersonation_defender';
  static const String perfectScore = 'perfect_score';
  static const String safeStreak = 'safe_decision_streak';
  static const String scenarioMaster = 'scenario_master';
  static const String securityChampion = 'security_champion';

  static const List<BadgeDefinition> all = [
    BadgeDefinition(
      id: awarenessStarter,
      name: 'Awareness Starter',
      description: 'You began building safe decision habits.',
      condition: 'Complete any scenario.',
      icon: Icons.shield_outlined,
      faceGradient: [Color(0xFF1B2A4A), Color(0xFF2B6CFF)],
      ribbonGradient: [Color(0xFF0EA5E9), Color(0xFF22D3EE)],
      category: BadgeCategory.foundational,
      rarity: BadgeRarity.common,
      progressText: 'Complete introduction module',
      points: 180,
      accentColor: Color(0xFF52E5A3),
    ),
    BadgeDefinition(
      id: firstScenario,
      name: 'First Scenario Completed',
      description: 'You finished your first simulation.',
      condition: 'Complete your first scenario.',
      icon: Icons.verified_outlined,
      faceGradient: [Color(0xFF172554), Color(0xFF2B6CFF)],
      ribbonGradient: [Color(0xFF2B6CFF), Color(0xFF60A5FA)],
      category: BadgeCategory.foundational,
      rarity: BadgeRarity.common,
      progressText: '1/1 scenario success',
      points: 220,
      accentColor: Color(0xFF8DA4FF),
    ),
    BadgeDefinition(
      id: phishingDetector,
      name: 'Phishing Detector',
      description: 'You recognized common phishing indicators.',
      condition: 'Complete a phishing scenario.',
      icon: Icons.mark_email_read_outlined,
      faceGradient: [Color(0xFF0F2C3E), Color(0xFF22D3EE)],
      ribbonGradient: [Color(0xFF1D4ED8), Color(0xFF22D3EE)],
      category: BadgeCategory.scenario,
      rarity: BadgeRarity.rare,
      progressText: 'Flag 5 phishing emails',
      points: 380,
      accentColor: Color(0xFFFFB946),
    ),
    BadgeDefinition(
      id: vishingAware,
      name: 'Vishing Aware',
      description: 'You handled phone-based social engineering safely.',
      condition: 'Complete a vishing scenario.',
      icon: Icons.phone_in_talk_outlined,
      faceGradient: [Color(0xFF102A43), Color(0xFF38BDF8)],
      ribbonGradient: [Color(0xFF06B6D4), Color(0xFF2B6CFF)],
      category: BadgeCategory.scenario,
      rarity: BadgeRarity.rare,
      progressText: 'Required module level 3',
      points: 360,
      accentColor: Color(0xFF2A3E67),
    ),
    BadgeDefinition(
      id: baitingBlocker,
      name: 'Baiting Blocker',
      description: 'You resisted risky curiosity-driven actions.',
      condition: 'Complete a baiting scenario.',
      icon: Icons.usb_outlined,
      faceGradient: [Color(0xFF1F2937), Color(0xFF22C55E)],
      ribbonGradient: [Color(0xFF16A34A), Color(0xFF22D3EE)],
      category: BadgeCategory.scenario,
      rarity: BadgeRarity.rare,
      progressText: 'Security path level 2',
      points: 340,
      accentColor: Color(0xFF2A3E67),
    ),
    BadgeDefinition(
      id: impersonationDefender,
      name: 'Impersonation Defender',
      description: 'You verified identity and resisted authority pressure.',
      condition: 'Complete an impersonation scenario.',
      icon: Icons.admin_panel_settings_outlined,
      faceGradient: [Color(0xFF1F2937), Color(0xFFFFB020)],
      ribbonGradient: [Color(0xFF2B6CFF), Color(0xFFFFB020)],
      category: BadgeCategory.scenario,
      rarity: BadgeRarity.rare,
      progressText: 'Deny unauthorized entry',
      points: 420,
      accentColor: Color(0xFF67EDB0),
    ),
    BadgeDefinition(
      id: safeStreak,
      name: 'Safe Decision Streak',
      description: 'You maintained a run of consistently safe decisions.',
      condition: 'Reach a 5-correct decision streak.',
      icon: Icons.local_fire_department_outlined,
      faceGradient: [Color(0xFF111827), Color(0xFF22D3EE)],
      ribbonGradient: [Color(0xFF2B6CFF), Color(0xFF22D3EE)],
      category: BadgeCategory.performance,
      rarity: BadgeRarity.epic,
      progressText: '7-day hot streak',
      points: 520,
      accentColor: Color(0xFFF66CA0),
    ),
    BadgeDefinition(
      id: perfectScore,
      name: 'Perfect Score',
      description: 'You completed a scenario with zero unsafe choices.',
      condition: 'Finish a scenario with no wrong decisions.',
      icon: Icons.emoji_events_outlined,
      faceGradient: [Color(0xFF0B1220), Color(0xFFFFB020)],
      ribbonGradient: [Color(0xFFFFB020), Color(0xFF22D3EE)],
      category: BadgeCategory.performance,
      rarity: BadgeRarity.epic,
      progressText: '100/100 evaluation',
      points: 600,
      accentColor: Color(0xFFFFC54D),
    ),
    BadgeDefinition(
      id: scenarioMaster,
      name: 'Scenario Master',
      description: 'You built broad awareness across multiple simulations.',
      condition: 'Complete 5 scenarios.',
      icon: Icons.auto_awesome_outlined,
      faceGradient: [Color(0xFF0B1220), Color(0xFF60A5FA)],
      ribbonGradient: [Color(0xFF2B6CFF), Color(0xFF22D3EE)],
      category: BadgeCategory.mastery,
      rarity: BadgeRarity.legendary,
      progressText: 'Complete all scenarios',
      points: 760,
      accentColor: Color(0xFF2A3E67),
    ),
    BadgeDefinition(
      id: securityChampion,
      name: 'Security Champion',
      description: 'High performance plus consistent training progress.',
      condition: 'Score 90+ on a scenario and reach 250+ total score.',
      icon: Icons.workspace_premium_outlined,
      faceGradient: [Color(0xFF0B1220), Color(0xFF9CA3AF)],
      ribbonGradient: [Color(0xFF2B6CFF), Color(0xFF9CA3AF)],
      category: BadgeCategory.mastery,
      rarity: BadgeRarity.legendary,
      progressText: 'Archive global rank: top 12%',
      points: 900,
      accentColor: Color(0xFF2A3E67),
    ),
  ];

  static BadgeDefinition? byId(String id) {
    for (final b in all) {
      if (b.id == id) return b;
    }
    return null;
  }
}

