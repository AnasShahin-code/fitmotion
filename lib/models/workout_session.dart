class WorkoutSession {
  final String id;
  final String? userId;
  final String workoutType;
  final int durationMinutes;
  final int? caloriesBurned;
  final String? notes;
  final DateTime sessionDate;
  final DateTime createdAt;

  WorkoutSession({
    required this.id,
    this.userId,
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
      'session_date': sessionDate.toIso8601String().split('T')[0], // Date only
      'created_at': createdAt.toIso8601String(),
    };
  }

  static WorkoutSession fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      workoutType: map['workout_type'] as String,
      durationMinutes: map['duration_minutes'] as int,
      caloriesBurned: map['calories_burned'] as int?,
      notes: map['notes'] as String?,
      sessionDate: DateTime.parse(map['session_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  WorkoutSession copyWith({
    String? id,
    String? userId,
    String? workoutType,
    int? durationMinutes,
    int? caloriesBurned,
    String? notes,
    DateTime? sessionDate,
    DateTime? createdAt,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workoutType: workoutType ?? this.workoutType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
      sessionDate: sessionDate ?? this.sessionDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }

  String get workoutTypeDisplayName {
    switch (workoutType.toLowerCase()) {
      case 'hiit cardio':
        return 'HIIT Cardio';
      case 'strength training':
        return 'Strength Training';
      case 'yoga':
        return 'Yoga';
      case 'running':
        return 'Running';
      case 'cycling':
        return 'Cycling';
      case 'swimming':
        return 'Swimming';
      default:
        return workoutType;
    }
  }

  String get intensityLevel {
    if (durationMinutes <= 20) return 'Light';
    if (durationMinutes <= 40) return 'Moderate';
    if (durationMinutes <= 60) return 'Intense';
    return 'Extreme';
  }

  double? get caloriesPerMinute {
    if (caloriesBurned == null || durationMinutes == 0) return null;
    return caloriesBurned! / durationMinutes;
  }

  String get category {
    final type = workoutType.toLowerCase();
    if (type.contains('cardio') ||
        type.contains('hiit') ||
        type.contains('running') ||
        type.contains('cycling')) {
      return 'Cardio';
    } else if (type.contains('strength') ||
        type.contains('weight') ||
        type.contains('lifting')) {
      return 'Strength';
    } else if (type.contains('yoga') ||
        type.contains('pilates') ||
        type.contains('stretch')) {
      return 'Flexibility';
    } else if (type.contains('sports')) {
      return 'Sports';
    } else {
      return 'Other';
    }
  }

  String get formattedSessionDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay =
        DateTime(sessionDate.year, sessionDate.month, sessionDate.day);

    final difference = today.difference(sessionDay).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      // Return formatted date
      return '${sessionDate.day}/${sessionDate.month}/${sessionDate.year}';
    }
  }

  String get workoutIcon {
    final type = workoutType.toLowerCase();
    if (type.contains('cardio') || type.contains('hiit')) {
      return 'favorite';
    } else if (type.contains('strength') || type.contains('weight')) {
      return 'fitness_center';
    } else if (type.contains('yoga') || type.contains('pilates')) {
      return 'self_improvement';
    } else if (type.contains('running')) {
      return 'directions_run';
    } else if (type.contains('cycling')) {
      return 'directions_bike';
    } else if (type.contains('swimming')) {
      return 'pool';
    } else {
      return 'sports_gymnastics';
    }
  }

  @override
  String toString() {
    return 'WorkoutSession(id: $id, workoutType: $workoutType, duration: $durationMinutes min, calories: $caloriesBurned, date: ${sessionDate.toIso8601String().split('T')[0]})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
