class ScenarioOption {
  ScenarioOption({required this.optionText});

  final String optionText;

  factory ScenarioOption.fromJson(Map<String, dynamic> json) {
    return ScenarioOption(optionText: json['optionText'] ?? '');
  }
}

class ScenarioStep {
  ScenarioStep({
    required this.stepNumber,
    required this.content,
    required this.contextLabel,
    required this.isFinalStep,
    required this.options,
  });

  final int stepNumber;
  final String content;
  final String contextLabel;
  final bool isFinalStep;
  final List<ScenarioOption> options;

  factory ScenarioStep.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>? ?? [])
        .map((e) => ScenarioOption.fromJson(e as Map<String, dynamic>))
        .toList();
    return ScenarioStep(
      stepNumber: (json['stepNumber'] as num?)?.toInt() ?? 0,
      content: json['content'] ?? '',
      contextLabel: json['contextLabel'] ?? '',
      isFinalStep: json['isFinalStep'] == true,
      options: opts,
    );
  }
}

class ScenarioModel {
  ScenarioModel({
    required this.id,
    required this.title,
    required this.type,
    required this.difficulty,
    required this.description,
    required this.estimatedTime,
    required this.steps,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String type;
  final String difficulty;
  final String description;
  final int estimatedTime;
  final List<ScenarioStep> steps;
  final bool isActive;

  factory ScenarioModel.fromJson(Map<String, dynamic> json) {
    final steps = (json['steps'] as List<dynamic>? ?? [])
        .map((e) => ScenarioStep.fromJson(e as Map<String, dynamic>))
        .toList();
    return ScenarioModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      difficulty: json['difficulty'] ?? 'beginner',
      description: json['description'] ?? '',
      estimatedTime: (json['estimatedTime'] as num?)?.toInt() ?? 10,
      steps: steps,
      isActive: json['isActive'] != false,
    );
  }
}
