class FitnessGoal {
  final String id;
  final String? userId;
  final String goalType;
  final double targetValue;
  final double currentValue;
  final DateTime? targetDate;
  final bool isAchieved;
  final DateTime createdAt;
  final DateTime updatedAt;

  FitnessGoal({
    required this.id,
    this.userId,
    required this.goalType,
    required this.targetValue,
    required this.currentValue,
    this.targetDate,
    required this.isAchieved,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'goal_type': goalType,
      'target_value': targetValue,
      'current_value': currentValue,
      'target_date': targetDate?.toIso8601String().split('T')[0],
      'is_achieved': isAchieved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static FitnessGoal fromMap(Map<String, dynamic> map) {
    return FitnessGoal(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      goalType: map['goal_type'] as String,
      targetValue: (map['target_value'] as num).toDouble(),
      currentValue: (map['current_value'] as num).toDouble(),
      targetDate: map['target_date'] != null
          ? DateTime.parse(map['target_date'] as String)
          : null,
      isAchieved: map['is_achieved'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  FitnessGoal copyWith({
    String? id,
    String? userId,
    String? goalType,
    double? targetValue,
    double? currentValue,
    DateTime? targetDate,
    bool? isAchieved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FitnessGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalType: goalType ?? this.goalType,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      targetDate: targetDate ?? this.targetDate,
      isAchieved: isAchieved ?? this.isAchieved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate progress percentage
  double get progressPercentage {
    if (targetValue == 0) return 0;
    return ((currentValue / targetValue) * 100).clamp(0, 100);
  }

  // Check if goal is nearly achieved (90% or more)
  bool get isNearlyAchieved {
    return progressPercentage >= 90;
  }

  // Days remaining until target date
  int? get daysRemaining {
    if (targetDate == null) return null;
    final now = DateTime.now();
    final difference = targetDate!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  // Get goal type display name
  String get goalTypeDisplayName {
    switch (goalType.toLowerCase()) {
      case 'weight_loss':
        return 'Weight Loss';
      case 'muscle_gain':
        return 'Muscle Gain';
      case 'workout_streak':
        return 'Workout Streak';
      case 'distance_running':
        return 'Running Distance';
      case 'strength_target':
        return 'Strength Target';
      default:
        return goalType.replaceAll('_', ' ').toUpperCase();
    }
  }

  // Get goal progress status
  String get statusText {
    if (isAchieved) return 'Achieved';
    if (isNearlyAchieved) return 'Almost there!';
    if (progressPercentage >= 50) return 'Making progress';
    return 'Getting started';
  }

  // Get appropriate unit for goal type
  String get unit {
    switch (goalType.toLowerCase()) {
      case 'weight_loss':
      case 'muscle_gain':
        return 'kg';
      case 'workout_streak':
        return 'days';
      case 'distance_running':
        return 'km';
      case 'strength_target':
        return 'kg';
      default:
        return '';
    }
  }

  @override
  String toString() {
    return 'FitnessGoal(id: $id, goalType: $goalType, targetValue: $targetValue, currentValue: $currentValue, progressPercentage: ${progressPercentage.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FitnessGoal &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
