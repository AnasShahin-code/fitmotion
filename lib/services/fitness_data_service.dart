import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart' as user_models;
import '../models/workout_session.dart' as workout_models;
import './supabase_service.dart';

// Fitness Goal Model to match Supabase schema
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

class FitnessDataService {
  static final FitnessDataService _instance = FitnessDataService._internal();
  static FitnessDataService get instance => _instance;
  FitnessDataService._internal();

  final SupabaseService _supabase = SupabaseService.instance;

  // User Profile Operations
  Future<user_models.UserProfile?> getCurrentUserProfile() async {
    try {
      final currentUser = _supabase.client.auth.currentUser;
      if (currentUser == null) return null;

      final response = await _supabase.client
          .from('user_profiles')
          .select()
          .eq('id', currentUser.id)
          .single();

      return user_models.UserProfile.fromMap(response);
    } catch (error) {
      debugPrint('Get current user profile error: $error');
      return null;
    }
  }

  Future<user_models.UserProfile> createUserProfile(
      user_models.UserProfile profile) async {
    try {
      final response = await _supabase.client
          .from('user_profiles')
          .insert(profile.toMap())
          .select()
          .single();

      return user_models.UserProfile.fromMap(response);
    } catch (error) {
      debugPrint('Create user profile error: $error');
      rethrow;
    }
  }

  Future<user_models.UserProfile> updateUserProfile(
      user_models.UserProfile profile) async {
    try {
      final response = await _supabase.client
          .from('user_profiles')
          .update(profile.toMap())
          .eq('id', profile.id)
          .select()
          .single();

      return user_models.UserProfile.fromMap(response);
    } catch (error) {
      debugPrint('Update user profile error: $error');
      rethrow;
    }
  }

  // Workout Session Operations
  Future<List<workout_models.WorkoutSession>> getWorkoutSessions({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
    String? workoutType,
  }) async {
    try {
      final currentUser = _supabase.client.auth.currentUser;
      if (currentUser == null) return [];

      var query = _supabase.client
          .from('workout_sessions')
          .select()
          .eq('user_id', currentUser.id);

      if (startDate != null) {
        query = query.gte(
            'session_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query =
            query.lte('session_date', endDate.toIso8601String().split('T')[0]);
      }

      if (workoutType != null) {
        query = query.eq('workout_type', workoutType);
      }

      final response = await query
          .order('session_date', ascending: false)
          .limit(limit ?? 50);

      return response
          .map((item) => workout_models.WorkoutSession.fromMap(item))
          .toList();
    } catch (error) {
      debugPrint('Get workout sessions error: $error');
      return [];
    }
  }

  Future<workout_models.WorkoutSession> createWorkoutSession(
      workout_models.WorkoutSession session) async {
    try {
      final response = await _supabase.client
          .from('workout_sessions')
          .insert(session.toMap())
          .select()
          .single();

      return workout_models.WorkoutSession.fromMap(response);
    } catch (error) {
      debugPrint('Create workout session error: $error');
      rethrow;
    }
  }

  Future<workout_models.WorkoutSession> updateWorkoutSession(
      workout_models.WorkoutSession session) async {
    try {
      final response = await _supabase.client
          .from('user_profiles')
          .update(session.toMap())
          .eq('id', session.id)
          .select()
          .single();

      return workout_models.WorkoutSession.fromMap(response);
    } catch (error) {
      debugPrint('Update workout session error: $error');
      rethrow;
    }
  }

  Future<void> deleteWorkoutSession(String sessionId) async {
    try {
      await _supabase.client
          .from('workout_sessions')
          .delete()
          .eq('id', sessionId);
    } catch (error) {
      debugPrint('Delete workout session error: $error');
      rethrow;
    }
  }

  // Fitness Goals Operations
  Future<List<FitnessGoal>> getFitnessGoals() async {
    try {
      final currentUser = _supabase.client.auth.currentUser;
      if (currentUser == null) return [];

      final response = await _supabase.client
          .from('fitness_goals')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      return response.map((item) => FitnessGoal.fromMap(item)).toList();
    } catch (error) {
      debugPrint('Get fitness goals error: $error');
      return [];
    }
  }

  Future<FitnessGoal> createFitnessGoal(FitnessGoal goal) async {
    try {
      final response = await _supabase.client
          .from('fitness_goals')
          .insert(goal.toMap())
          .select()
          .single();

      return FitnessGoal.fromMap(response);
    } catch (error) {
      debugPrint('Create fitness goal error: $error');
      rethrow;
    }
  }

  Future<FitnessGoal> updateFitnessGoal(FitnessGoal goal) async {
    try {
      final response = await _supabase.client
          .from('fitness_goals')
          .update(goal.toMap())
          .eq('id', goal.id)
          .select()
          .single();

      return FitnessGoal.fromMap(response);
    } catch (error) {
      debugPrint('Update fitness goal error: $error');
      rethrow;
    }
  }

  Future<void> deleteFitnessGoal(String goalId) async {
    try {
      await _supabase.client.from('fitness_goals').delete().eq('id', goalId);
    } catch (error) {
      debugPrint('Delete fitness goal error: $error');
      rethrow;
    }
  }

  // Statistics and Analytics
  Future<Map<String, dynamic>> getWorkoutStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final currentUser = _supabase.client.auth.currentUser;
      if (currentUser == null) {
        return {
          'totalWorkouts': 0,
          'totalMinutes': 0,
          'totalCalories': 0,
          'averageDuration': 0,
        };
      }

      var query = _supabase.client
          .from('workout_sessions')
          .select('duration_minutes, calories_burned')
          .eq('user_id', currentUser.id);

      if (startDate != null) {
        query = query.gte(
            'session_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query =
            query.lte('session_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query;

      if (response.isEmpty) {
        return {
          'totalWorkouts': 0,
          'totalMinutes': 0,
          'totalCalories': 0,
          'averageDuration': 0,
        };
      }

      int totalWorkouts = response.length;
      int totalMinutes = 0;
      int totalCalories = 0;

      for (final session in response) {
        totalMinutes += (session['duration_minutes'] as int? ?? 0);
        totalCalories += (session['calories_burned'] as int? ?? 0);
      }

      return {
        'totalWorkouts': totalWorkouts,
        'totalMinutes': totalMinutes,
        'totalCalories': totalCalories,
        'averageDuration':
            totalWorkouts > 0 ? (totalMinutes / totalWorkouts).round() : 0,
      };
    } catch (error) {
      debugPrint('Get workout stats error: $error');
      return {
        'totalWorkouts': 0,
        'totalMinutes': 0,
        'totalCalories': 0,
        'averageDuration': 0,
      };
    }
  }

  Future<int> getCurrentStreak() async {
    try {
      final currentUser = _supabase.client.auth.currentUser;
      if (currentUser == null) return 0;

      final response = await _supabase.client
          .from('workout_sessions')
          .select('session_date')
          .eq('user_id', currentUser.id)
          .order('session_date', ascending: false)
          .limit(30); // Check last 30 days

      if (response.isEmpty) return 0;

      // Calculate streak based on consecutive workout days
      int streak = 0;
      DateTime today = DateTime.now();
      DateTime currentDate = DateTime(today.year, today.month, today.day);

      Set<String> workoutDates =
          response.map((session) => session['session_date'] as String).toSet();

      // Check if worked out today or yesterday to start streak
      String todayStr = currentDate.toIso8601String().split('T')[0];
      String yesterdayStr = currentDate
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .split('T')[0];

      if (!workoutDates.contains(todayStr) &&
          !workoutDates.contains(yesterdayStr)) {
        return 0;
      }

      // Start from yesterday if no workout today, otherwise start from today
      if (!workoutDates.contains(todayStr)) {
        currentDate = currentDate.subtract(const Duration(days: 1));
      }

      // Count consecutive workout days
      while (
          workoutDates.contains(currentDate.toIso8601String().split('T')[0])) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      }

      return streak;
    } catch (error) {
      debugPrint('Get current streak error: $error');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutTrends({
    required String period, // 'weekly' or 'monthly'
    int? weeks,
  }) async {
    try {
      final currentUser = _supabase.client.auth.currentUser;
      if (currentUser == null) return [];

      DateTime endDate = DateTime.now();
      DateTime startDate;

      if (period == 'weekly') {
        startDate = endDate.subtract(Duration(days: (weeks ?? 4) * 7));
      } else {
        startDate =
            DateTime(endDate.year, endDate.month - (weeks ?? 3), endDate.day);
      }

      final response = await _supabase.client
          .from('workout_sessions')
          .select('session_date, duration_minutes, calories_burned')
          .eq('user_id', currentUser.id)
          .gte('session_date', startDate.toIso8601String().split('T')[0])
          .lte('session_date', endDate.toIso8601String().split('T')[0])
          .order('session_date', ascending: true);

      // Group by period and calculate totals
      Map<String, Map<String, int>> groupedData = {};

      for (final session in response) {
        final sessionDate = DateTime.parse(session['session_date']);
        String periodKey;

        if (period == 'weekly') {
          // Group by week
          int weekOfYear =
              ((sessionDate.difference(startDate).inDays) / 7).floor();
          periodKey = 'Week ${weekOfYear + 1}';
        } else {
          // Group by month
          periodKey = '${sessionDate.month}/${sessionDate.year}';
        }

        if (!groupedData.containsKey(periodKey)) {
          groupedData[periodKey] = {
            'workouts': 0,
            'minutes': 0,
            'calories': 0,
          };
        }

        groupedData[periodKey]!['workouts'] =
            groupedData[periodKey]!['workouts']! + 1;
        groupedData[periodKey]!['minutes'] =
            groupedData[periodKey]!['minutes']! +
                (session['duration_minutes'] as int? ?? 0);
        groupedData[periodKey]!['calories'] =
            groupedData[periodKey]!['calories']! +
                (session['calories_burned'] as int? ?? 0);
      }

      return groupedData.entries
          .map((entry) => {
                'label': entry.key,
                'workouts': entry.value['workouts'],
                'minutes': entry.value['minutes'],
                'calories': entry.value['calories'],
              })
          .toList();
    } catch (error) {
      debugPrint('Get workout trends error: $error');
      return [];
    }
  }

  // Real-time subscriptions
  Future<void> subscribeToWorkoutSessions(
      Function(Map<String, dynamic>) onData) async {
    try {
      final currentUser = _supabase.client.auth.currentUser;
      if (currentUser == null) return;

      final channel = _supabase.client.channel('public:workout_sessions');

      channel
          .onPostgresChanges(
            event: PostgresChangeEvent
                .all, // or .insert/.update/.delete for specific events
            schema: 'public',
            table: 'workout_sessions',
            callback: (payload) {
              // payload.newRecord is where new row data comes
              if ((payload.newRecord['user_id'] ?? '') == currentUser.id) {
                onData(payload.newRecord);
              }
            },
          )
          .subscribe();
    } catch (error) {
      debugPrint('Subscribe to workout sessions error: $error');
    }
  }

  Future<void> subscribeToFitnessGoals(
      Function(Map<String, dynamic>) onData) async {
    try {
      final currentUser = _supabase.client.auth.currentUser;
      if (currentUser == null) return;

      final channel = _supabase.client.channel('public:fitness_goals');
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'fitness_goals',
            callback: (payload) {
              if ((payload.newRecord['user_id'] ?? '') == currentUser.id) {
                onData(payload.newRecord);
              }
            },
          )
          .subscribe();
    } catch (error) {
      debugPrint('Subscribe to fitness goals error: $error');
    }
  }

  // Health check
  Future<bool> isConnected() async {
    return await _supabase.isConnected();
  }

  // Demo/Mock data for when not connected to Supabase
  Future<List<Map<String, dynamic>>> getMockWorkouts() async {
    return [
      {
        'id': 'mock_1',
        'name': 'HIIT Cardio Blast',
        'type': 'HIIT Cardio',
        'duration': 30,
        'calories': 320,
        'lastCompleted': 'Yesterday',
        'difficulty': 'Intermediate',
        'image': 'https://images.unsplash.com/photo-1609096458733-95b38583ac4e',
        'semanticLabel':
            'High intensity interval training workout with jumping exercises',
      },
      {
        'id': 'mock_2',
        'name': 'Strength Training',
        'type': 'Strength Training',
        'duration': 45,
        'calories': 280,
        'lastCompleted': '2 days ago',
        'difficulty': 'Advanced',
        'image': 'https://images.unsplash.com/photo-1590487988357-5233b152a9b7',
        'semanticLabel': 'Weight training session with dumbbells and barbells',
      },
      {
        'id': 'mock_3',
        'name': 'Morning Yoga',
        'type': 'Yoga',
        'duration': 20,
        'calories': 150,
        'lastCompleted': 'This morning',
        'difficulty': 'Beginner',
        'image': 'https://images.unsplash.com/photo-1713201673819-122ab540f947',
        'semanticLabel': 'Peaceful yoga session on a mat in morning sunlight',
      },
    ];
  }

  Future<Map<String, dynamic>> getMockStats() async {
    return {
      'totalWorkouts': 5,
      'totalMinutes': 180,
      'totalCalories': 1250,
      'currentStreak': 3,
      'averageDuration': 36,
    };
  }
}
