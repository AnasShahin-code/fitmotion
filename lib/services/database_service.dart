import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/workout_session.dart';
import '../models/user_profile.dart' hide WorkoutSession;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'fitmotion.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDb,
        onUpgrade: _upgradeDb,
      );
    } catch (e) {
      debugPrint('Database initialization error: $e');
      rethrow;
    }
  }

  Future<void> _createDb(Database db, int version) async {
    try {
      // Create workout_sessions table
      await db.execute('''
        CREATE TABLE workout_sessions (
          id TEXT PRIMARY KEY,
          userId TEXT,
          type TEXT NOT NULL,
          startAt TEXT NOT NULL,
          endAt TEXT NOT NULL,
          duration INTEGER NOT NULL,
          steps INTEGER NOT NULL,
          distanceM REAL NOT NULL,
          avgPace REAL NOT NULL,
          caloriesKcal REAL NOT NULL,
          routePolyline TEXT,
          source TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');

      // Create user_profiles table
      await db.execute('''
        CREATE TABLE user_profiles (
          id TEXT PRIMARY KEY,
          weightKg REAL NOT NULL,
          heightCm REAL NOT NULL,
          age INTEGER NOT NULL,
          gender TEXT NOT NULL,
          units TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');

      // Create settings table
      await db.execute('''
        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');

      debugPrint('Database tables created successfully');
    } catch (e) {
      debugPrint('Database creation error: $e');
      rethrow;
    }
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    debugPrint('Database upgraded from $oldVersion to $newVersion');
  }

  // WorkoutSession operations
  Future<String> insertWorkoutSession(WorkoutSession session) async {
    try {
      final db = await database;
      await db.insert(
        'workout_sessions',
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Workout session inserted: ${session.id}');
      return session.id;
    } catch (e) {
      debugPrint('Insert workout session error: $e');
      rethrow;
    }
  }

  Future<List<WorkoutSession>> getWorkoutSessions({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    try {
      final db = await database;
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (startDate != null) {
        whereClause = 'startAt >= ?';
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'endAt <= ?';
        whereArgs.add(endDate.toIso8601String());
      }

      if (type != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'type = ?';
        whereArgs.add(type);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'workout_sessions',
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'startAt DESC',
        limit: limit,
      );

      return List.generate(maps.length, (i) => WorkoutSession.fromMap(maps[i]));
    } catch (e) {
      debugPrint('Get workout sessions error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getWorkoutStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await database;
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (startDate != null) {
        whereClause = 'startAt >= ?';
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'endAt <= ?';
        whereArgs.add(endDate.toIso8601String());
      }

      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as totalWorkouts,
          SUM(duration) as totalMinutes,
          SUM(caloriesKcal) as totalCalories,
          SUM(steps) as totalSteps,
          SUM(distanceM) as totalDistance,
          AVG(avgPace) as avgPace
        FROM workout_sessions
        ${whereClause.isEmpty ? '' : 'WHERE $whereClause'}
      ''', whereArgs.isEmpty ? null : whereArgs);

      if (result.isEmpty) {
        return {
          'totalWorkouts': 0,
          'totalMinutes': 0,
          'totalCalories': 0.0,
          'totalSteps': 0,
          'totalDistance': 0.0,
          'avgPace': 0.0,
        };
      }

      final row = result.first;
      return {
        'totalWorkouts': row['totalWorkouts'] ?? 0,
        'totalMinutes': row['totalMinutes'] ?? 0,
        'totalCalories': row['totalCalories'] ?? 0.0,
        'totalSteps': row['totalSteps'] ?? 0,
        'totalDistance': row['totalDistance'] ?? 0.0,
        'avgPace': row['avgPace'] ?? 0.0,
      };
    } catch (e) {
      debugPrint('Get workout stats error: $e');
      return {
        'totalWorkouts': 0,
        'totalMinutes': 0,
        'totalCalories': 0.0,
        'totalSteps': 0,
        'totalDistance': 0.0,
        'avgPace': 0.0,
      };
    }
  }

  // UserProfile operations
  Future<String> saveUserProfile(UserProfile profile) async {
    try {
      final db = await database;
      await db.insert(
        'user_profiles',
        profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('User profile saved: ${profile.id}');
      return profile.id;
    } catch (e) {
      debugPrint('Save user profile error: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getUserProfile() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'user_profiles',
        orderBy: 'updatedAt DESC',
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return UserProfile.fromMap(maps.first);
    } catch (e) {
      debugPrint('Get user profile error: $e');
      return null;
    }
  }

  // Settings operations
  Future<void> setSetting(String key, String value) async {
    try {
      final db = await database;
      await db.insert(
        'settings',
        {
          'key': key,
          'value': value,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Setting saved: $key = $value');
    } catch (e) {
      debugPrint('Set setting error: $e');
    }
  }

  Future<String?> getSetting(String key, {String? defaultValue}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );

      if (result.isEmpty) return defaultValue;
      return result.first['value'];
    } catch (e) {
      debugPrint('Get setting error: $e');
      return defaultValue;
    }
  }

  Future<void> deleteAllData() async {
    try {
      final db = await database;
      await db.delete('workout_sessions');
      await db.delete('user_profiles');
      await db.delete('settings');
      debugPrint('All data deleted successfully');
    } catch (e) {
      debugPrint('Delete all data error: $e');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}