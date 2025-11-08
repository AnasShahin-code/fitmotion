class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role;

  // Fitness-specific profile data
  final int? age;
  final String? gender;
  final double? weightKg;
  final double? heightCm;
  final String? activityLevel;
  final String units;

  // Fitness goals and preferences
  final int? dailyCalorieGoal;
  final int weeklyWorkoutGoal;
  final int preferredWorkoutDuration; // minutes

  // App preferences
  final bool notificationsEnabled;
  final bool isActive;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.age,
    this.gender,
    this.weightKg,
    this.heightCm,
    this.activityLevel,
    this.units = 'metric',
    this.dailyCalorieGoal,
    this.weeklyWorkoutGoal = 3,
    this.preferredWorkoutDuration = 30,
    this.notificationsEnabled = true,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'age': age,
      'gender': gender,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'activity_level': activityLevel,
      'units': units,
      'daily_calorie_goal': dailyCalorieGoal,
      'weekly_workout_goal': weeklyWorkoutGoal,
      'preferred_workout_duration': preferredWorkoutDuration,
      'notifications_enabled': notificationsEnabled,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String,
      role: map['role'] as String,
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      weightKg: map['weight_kg']?.toDouble(),
      heightCm: map['height_cm']?.toDouble(),
      activityLevel: map['activity_level'] as String?,
      units: map['units'] as String? ?? 'metric',
      dailyCalorieGoal: map['daily_calorie_goal'] as int?,
      weeklyWorkoutGoal: map['weekly_workout_goal'] as int? ?? 3,
      preferredWorkoutDuration: map['preferred_workout_duration'] as int? ?? 30,
      notificationsEnabled: map['notifications_enabled'] as bool? ?? true,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    int? age,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? activityLevel,
    String? units,
    int? dailyCalorieGoal,
    int? weeklyWorkoutGoal,
    int? preferredWorkoutDuration,
    bool? notificationsEnabled,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      activityLevel: activityLevel ?? this.activityLevel,
      units: units ?? this.units,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      weeklyWorkoutGoal: weeklyWorkoutGoal ?? this.weeklyWorkoutGoal,
      preferredWorkoutDuration:
          preferredWorkoutDuration ?? this.preferredWorkoutDuration,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate BMI if weight and height are available
  double? get bmi {
    if (weightKg != null && heightCm != null && heightCm! > 0) {
      final heightM = heightCm! / 100;
      return weightKg! / (heightM * heightM);
    }
    return null;
  }

  // Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return 'Unknown';
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  // Calculate daily calorie needs based on activity level (rough estimate)
  int? get estimatedDailyCalories {
    if (age == null || weightKg == null || heightCm == null || gender == null) {
      return null;
    }

    // Harris-Benedict Equation
    double bmr;
    if (gender!.toLowerCase() == 'male') {
      bmr =
          88.362 + (13.397 * weightKg!) + (4.799 * heightCm!) - (5.677 * age!);
    } else {
      bmr =
          447.593 + (9.247 * weightKg!) + (3.098 * heightCm!) - (4.330 * age!);
    }

    // Activity level multipliers
    double multiplier = switch (activityLevel?.toLowerCase()) {
      'sedentary' => 1.2,
      'lightly_active' => 1.375,
      'moderately_active' => 1.55,
      'very_active' => 1.725,
      'extremely_active' => 1.9,
      _ => 1.55, // Default to moderately active
    };

    return (bmr * multiplier).round();
  }
}

// Workout Session Model
class WorkoutSession {
  final String id;
  final String userId;
  final String workoutType;
  final int durationMinutes;
  final int? caloriesBurned;
  final String? notes;
  final DateTime sessionDate;
  final DateTime createdAt;

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.workoutType,
    required this.durationMinutes,
    this.caloriesBurned,
    this.notes,
    required this.sessionDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'workout_type': workoutType,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'notes': notes,
      'session_date': sessionDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }

  static WorkoutSession fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      workoutType: map['workout_type'] as String,
      durationMinutes: map['duration_minutes'] as int,
      caloriesBurned: map['calories_burned'] as int?,
      notes: map['notes'] as String?,
      sessionDate: DateTime.parse(map['session_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

// Fitness Goals Model
class FitnessGoal {
  final String id;
  final String userId;
  final String goalType;
  final double targetValue;
  final double currentValue;
  final DateTime? targetDate;
  final bool isAchieved;
  final DateTime createdAt;
  final DateTime updatedAt;

  FitnessGoal({
    required this.id,
    required this.userId,
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
      userId: map['user_id'] as String,
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
}
