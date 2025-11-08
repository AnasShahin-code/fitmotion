import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/database_service.dart';
import '../../services/demo_mode_service.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/advanced_analytics_widget.dart';
import './widgets/enhanced_primary_stats_widget.dart';
import './widgets/goal_setting_widget.dart';
import './widgets/interactive_chart_widget.dart';
import './widgets/statistics_header_widget.dart';
import './widgets/streak_counter_widget.dart';
import './widgets/workout_category_chart_widget.dart';

class ProgressStatisticsScreen extends StatefulWidget {
  const ProgressStatisticsScreen({super.key});

  @override
  State<ProgressStatisticsScreen> createState() =>
      _ProgressStatisticsScreenState();
}

class _ProgressStatisticsScreenState extends State<ProgressStatisticsScreen>
    with TickerProviderStateMixin {
  String selectedPeriod = 'Weekly';
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  final DatabaseService _db = DatabaseService();
  final DemoModeService _demoMode = DemoModeService();

  // Real data
  Map<String, dynamic> primaryStats = {};
  List<Map<String, dynamic>> weeklyChartData = [];
  List<Map<String, dynamic>> monthlyChartData = [];
  List<Map<String, dynamic>> weeklyCaloriesData = [];
  List<Map<String, dynamic>> monthlyCaloriesData = [];
  List<Map<String, dynamic>> achievements = [];
  List<Map<String, dynamic>> categoryData = [];
  Map<String, dynamic> streakData = {};
  Map<String, dynamic> goalData = {'weeklyWorkouts': 5, 'currentProgress': 0};
  Map<String, dynamic> analyticsData = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeServices();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    await _demoMode.initialize();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_demoMode.isDemoMode) {
        _loadDemoData();
      } else {
        await _loadRealData();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadDemoData() {
    setState(() {
      // Replace undefined methods with direct demo data
      primaryStats = {
        'totalWorkouts': 45,
        'workoutTrend': 12,
        'caloriesBurned': 2850,
        'caloriesTrend': 8,
        'activeMinutes': 1260,
        'minutesTrend': 15,
      };
      
      weeklyChartData = [
        {'label': 'Mon', 'value': 2},
        {'label': 'Tue', 'value': 1},
        {'label': 'Wed', 'value': 3},
        {'label': 'Thu', 'value': 0},
        {'label': 'Fri', 'value': 2},
        {'label': 'Sat', 'value': 1},
        {'label': 'Sun', 'value': 2},
      ];
      
      monthlyChartData = [
        {'label': 'Week 1', 'value': 8},
        {'label': 'Week 2', 'value': 12},
        {'label': 'Week 3', 'value': 10},
        {'label': 'Week 4', 'value': 15},
      ];
      
      weeklyCaloriesData = [
        {'label': 'Mon', 'value': 450},
        {'label': 'Tue', 'value': 320},
        {'label': 'Wed', 'value': 680},
        {'label': 'Thu', 'value': 0},
        {'label': 'Fri', 'value': 520},
        {'label': 'Sat', 'value': 280},
        {'label': 'Sun', 'value': 600},
      ];
      
      monthlyCaloriesData = [
        {'label': 'Week 1', 'value': 1850},
        {'label': 'Week 2', 'value': 2200},
        {'label': 'Week 3', 'value': 1950},
        {'label': 'Week 4', 'value': 2650},
      ];
      
      achievements = [
        {
          'id': 1,
          'title': 'First Workout',
          'description': 'Complete your first workout session',
          'icon': 'fitness_center',
          'unlocked': true,
          'isNew': false,
          'unlockedDate': 'Jan 15, 2024',
        },
        {
          'id': 2,
          'title': '7-Day Streak',
          'description': 'Maintain a 7-day workout streak',
          'icon': 'local_fire_department',
          'unlocked': true,
          'isNew': false,
          'unlockedDate': 'Jan 22, 2024',
        },
      ];
      
      streakData = {
        'currentStreak': 12,
        'longestStreak': 28,
        'isActive': true,
        'lastWorkoutDate': 'Today',
      };

      // Demo category data
      categoryData = [
        {'name': 'Strength', 'percentage': 35, 'sessions': 16, 'duration': 45},
        {'name': 'Cardio', 'percentage': 28, 'sessions': 13, 'duration': 35},
        {'name': 'Yoga', 'percentage': 20, 'sessions': 9, 'duration': 60},
        {'name': 'Running', 'percentage': 12, 'sessions': 6, 'duration': 30},
        {'name': 'Stretching', 'percentage': 5, 'sessions': 3, 'duration': 15},
      ];

      analyticsData = {
        'fitnessScore': 8.7,
        'weeklyGoalProgress': 85,
        'performanceInsights': [
          {
            'title': 'Peak Performance',
            'description': 'Tuesday evenings show 23% higher workout intensity',
            'icon': 'schedule',
            'color': 'success',
          },
          {
            'title': 'Recovery Pattern',
            'description':
                'Rest days between strength training improved by 18%',
            'icon': 'healing',
            'color': 'teal',
          },
        ],
      };
    });
  }

  Future<void> _loadRealData() async {
    try {
      // Load real workout stats
      final stats = await _db.getWorkoutStats();
      final sessions = await _db.getWorkoutSessions();

      // Calculate real primary stats
      primaryStats = {
        'totalWorkouts': stats['totalWorkouts'] ?? 0,
        'workoutTrend': 0, // Would require historical comparison
        'caloriesBurned': (stats['totalCalories'] ?? 0.0).round(),
        'caloriesTrend': 0,
        'activeMinutes': stats['totalMinutes'] ?? 0,
        'minutesTrend': 0,
      };

      // Generate real chart data
      await _generateChartData(sessions);

      // Calculate real streak data
      streakData = {
        'currentStreak': await _calculateCurrentStreak(sessions),
        'longestStreak': await _calculateLongestStreak(sessions),
        'isActive': sessions.isNotEmpty &&
            sessions.first.sessionDate
                .isAfter(DateTime.now().subtract(const Duration(days: 2))),
        'lastWorkoutDate':
            sessions.isNotEmpty ? _formatDate(sessions.first.sessionDate) : 'Never',
      };

      // Generate category data from real sessions
      categoryData = _generateCategoryData(sessions);

      // Calculate real achievements
      achievements = await _calculateAchievements(stats, sessions);

      // Calculate current week progress for goal
      final currentWeekSessions = sessions.where((session) {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return (session as dynamic).sessionDate.isAfter(weekStart);
      }).length;

      goalData = {
        'weeklyWorkouts': 5,
        'currentProgress': currentWeekSessions,
      };

      // Generate analytics insights
      analyticsData = _generateAnalyticsData(stats, sessions);
    } catch (e) {
      debugPrint('Load real data error: $e');
      // Show empty state for real data
      primaryStats = {
        'totalWorkouts': 0,
        'workoutTrend': 0,
        'caloriesBurned': 0,
        'caloriesTrend': 0,
        'activeMinutes': 0,
        'minutesTrend': 0,
      };

      weeklyChartData = [];
      monthlyChartData = [];
      weeklyCaloriesData = [];
      monthlyCaloriesData = [];
      achievements = [];
      categoryData = [];
      streakData = {
        'currentStreak': 0,
        'longestStreak': 0,
        'isActive': false,
        'lastWorkoutDate': 'Never',
      };
      analyticsData = {
        'fitnessScore': 0.0,
        'weeklyGoalProgress': 0,
        'performanceInsights': [],
      };
    }
  }

  Future<void> _generateChartData(List sessions) async {
    // Generate weekly data
    weeklyChartData = [];
    weeklyCaloriesData = [];

    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final daySessions = sessions
          .where(
              (s) => s.sessionDate.isAfter(dayStart) && s.sessionDate.isBefore(dayEnd))
          .toList();

      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final dayName = dayNames[date.weekday - 1];

      weeklyChartData.add({
        'label': dayName,
        'value': daySessions.length,
      });

      final totalCalories =
          daySessions.fold(0.0, (sum, s) => sum + (s.caloriesBurned ?? 0));
      weeklyCaloriesData.add({
        'label': dayName,
        'value': totalCalories.round(),
      });
    }

    // Generate monthly data (last 4 weeks)
    monthlyChartData = [];
    monthlyCaloriesData = [];

    for (int i = 3; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: (i * 7) + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final weekSessions = sessions
          .where((s) =>
              s.sessionDate.isAfter(weekStart) && s.sessionDate.isBefore(weekEnd))
          .toList();

      monthlyChartData.add({
        'label': 'Week ${4 - i}',
        'value': weekSessions.length,
      });

      final totalCalories =
          weekSessions.fold(0.0, (sum, s) => sum + (s.caloriesBurned ?? 0));
      monthlyCaloriesData.add({
        'label': 'Week ${4 - i}',
        'value': totalCalories.round(),
      });
    }
  }

  Future<int> _calculateCurrentStreak(List sessions) async {
    if (sessions.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    // Sort sessions by date (newest first)
    sessions.sort((a, b) => b.sessionDate.compareTo(a.sessionDate));

    // Check each day backwards
    for (int i = 0; i < 365; i++) {
      // Max streak check of 365 days
      final checkDate = currentDate.subtract(Duration(days: i));
      final dayStart = DateTime(checkDate.year, checkDate.month, checkDate.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      // Check if there's a workout on this day
      final hasWorkout = sessions.any((session) =>
          session.sessionDate.isAfter(dayStart) &&
          session.sessionDate.isBefore(dayEnd));

      if (hasWorkout) {
        streak++;
      } else if (i > 0) {
        // Don't break on first day (today) if no workout yet
        break;
      }
    }

    return streak;
  }

  Future<int> _calculateLongestStreak(List sessions) async {
    if (sessions.isEmpty) return 0;

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? lastWorkoutDate;

    // Sort sessions by date (oldest first)
    sessions.sort((a, b) => a.sessionDate.compareTo(b.sessionDate));

    for (final session in sessions) {
      final sessionDate = DateTime(
        session.sessionDate.year,
        session.sessionDate.month,
        session.sessionDate.day,
      );

      if (lastWorkoutDate == null) {
        currentStreak = 1;
      } else {
        final daysBetween = sessionDate.difference(lastWorkoutDate).inDays;
        if (daysBetween == 1) {
          currentStreak++;
        } else if (daysBetween > 1) {
          maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
          currentStreak = 1;
        }
      }

      lastWorkoutDate = sessionDate;
    }

    return maxStreak > currentStreak ? maxStreak : currentStreak;
  }

  List<Map<String, dynamic>> _generateCategoryData(List sessions) {
    final Map<String, int> typeCounts = {};
    final Map<String, double> typeDurations = {};

    for (final session in sessions) {
      final type = session.workoutType.toLowerCase();
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      typeDurations[type] =
          (typeDurations[type] ?? 0.0) + session.durationMinutes.toDouble();
    }

    final totalSessions = sessions.length;
    if (totalSessions == 0) return [];

    final List<Map<String, dynamic>> categories = [];

    typeCounts.forEach((type, count) {
      final percentage = ((count / totalSessions) * 100).round();
      final avgDuration = (typeDurations[type]! / count).round();

      categories.add({
        'name': type.substring(0, 1).toUpperCase() + type.substring(1),
        'percentage': percentage,
        'sessions': count,
        'duration': avgDuration,
      });
    });

    // Sort by percentage (highest first)
    categories.sort((a, b) => b['percentage'].compareTo(a['percentage']));

    return categories.take(5).toList(); // Return top 5 categories
  }

  Future<List<Map<String, dynamic>>> _calculateAchievements(
      Map<String, dynamic> stats, List sessions) async {
    final List<Map<String, dynamic>> userAchievements = [];

    // First Workout Achievement
    if (stats['totalWorkouts'] > 0) {
      userAchievements.add({
        'id': 1,
        'title': 'First Workout',
        'description': 'Complete your first workout session',
        'icon': 'fitness_center',
        'unlocked': true,
        'isNew': false,
        'unlockedDate': sessions.isNotEmpty
            ? _formatDate(sessions.last.sessionDate)
            : 'Recently',
      });
    }

    // Streak Achievements
    final currentStreak = await _calculateCurrentStreak(sessions);
    if (currentStreak >= 7) {
      userAchievements.add({
        'id': 2,
        'title': '7-Day Streak',
        'description': 'Maintain a 7-day workout streak',
        'icon': 'local_fire_department',
        'unlocked': true,
        'isNew': currentStreak == 7,
        'unlockedDate': 'Recently',
      });
    }

    // Calorie Achievement
    final highCalorieWorkout =
        sessions.where((s) => (s.caloriesBurned ?? 0) >= 500).isNotEmpty;
    if (highCalorieWorkout) {
      userAchievements.add({
        'id': 3,
        'title': 'Calorie Crusher',
        'description': 'Burn 500+ calories in a single workout',
        'icon': 'whatshot',
        'unlocked': true,
        'isNew': false,
        'unlockedDate': 'Recently',
      });
    }

    // Distance Achievement (if applicable)
    final longDistanceWorkout =
        sessions.where((s) => s.distanceM >= 5000).isNotEmpty; // 5km
    if (longDistanceWorkout) {
      userAchievements.add({
        'id': 4,
        'title': 'Marathon Runner',
        'description': 'Complete a 5km run',
        'icon': 'directions_run',
        'unlocked': true,
        'isNew': false,
        'unlockedDate': 'Recently',
      });
    }

    return userAchievements;
  }

  Map<String, dynamic> _generateAnalyticsData(
      Map<String, dynamic> stats, List sessions) {
    double fitnessScore = 0.0;
    int weeklyGoalProgress = 0;
    List<Map<String, dynamic>> insights = [];

    if (sessions.isNotEmpty) {
      // Calculate fitness score based on activity
      final totalWorkouts = stats['totalWorkouts'] ?? 0;
      final totalMinutes = stats['totalMinutes'] ?? 0;

      if (totalWorkouts > 0) {
        fitnessScore =
            ((totalWorkouts * 0.5) + (totalMinutes * 0.01)).clamp(0.0, 10.0);
      }

      // Calculate weekly progress
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final thisWeekSessions =
          sessions.where((s) => s.sessionDate.isAfter(weekStart)).length;
      weeklyGoalProgress = ((thisWeekSessions / 5) * 100).clamp(0, 100).round();

      // Generate insights
      if (totalWorkouts >= 10) {
        insights.add({
          'title': 'Consistency Building',
          'description': 'You\'re building a great workout habit',
          'icon': 'trending_up',
          'color': 'success',
        });
      }

      if (totalMinutes >= 300) {
        // 5 hours total
        insights.add({
          'title': 'Active Lifestyle',
          'description': 'Great job staying active this month',
          'icon': 'fitness_center',
          'color': 'teal',
        });
      }
    }

    return {
      'fitnessScore': fitnessScore,
      'weeklyGoalProgress': weeklyGoalProgress,
      'performanceInsights': insights,
    };
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            StatisticsHeaderWidget(
              selectedPeriod: selectedPeriod,
              onPeriodChanged: _onPeriodChanged,
              onExport: _exportStatistics,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _refreshData,
                      color: AppTheme.primaryBlue,
                      child: primaryStats['totalWorkouts'] == 0 &&
                              !_demoMode.isDemoMode
                          ? _buildEmptyState()
                          : SingleChildScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  SizedBox(height: 2.h),
                                  EnhancedPrimaryStatsWidget(
                                      statsData: primaryStats),
                                  SizedBox(height: 2.h),
                                  AdvancedAnalyticsWidget(
                                      analyticsData: analyticsData),
                                  SizedBox(height: 2.h),
                                  if (weeklyChartData.isNotEmpty ||
                                      _demoMode.isDemoMode)
                                    InteractiveChartWidget(
                                      chartType: 'line',
                                      chartData: selectedPeriod == 'Weekly'
                                          ? weeklyChartData
                                          : monthlyChartData,
                                      selectedPeriod: selectedPeriod,
                                    ),
                                  SizedBox(height: 2.h),
                                  if (weeklyCaloriesData.isNotEmpty ||
                                      _demoMode.isDemoMode)
                                    InteractiveChartWidget(
                                      chartType: 'bar',
                                      chartData: selectedPeriod == 'Weekly'
                                          ? weeklyCaloriesData
                                          : monthlyCaloriesData,
                                      selectedPeriod: selectedPeriod,
                                    ),
                                  SizedBox(height: 2.h),
                                  AchievementBadgesWidget(
                                      achievements: achievements),
                                  SizedBox(height: 2.h),
                                  if (categoryData.isNotEmpty)
                                    WorkoutCategoryChartWidget(
                                        categoryData: categoryData),
                                  SizedBox(height: 2.h),
                                  StreakCounterWidget(streakData: streakData),
                                  SizedBox(height: 2.h),
                                  GoalSettingWidget(
                                    goalData: goalData,
                                    onGoalUpdated: _updateGoal,
                                  ),
                                  SizedBox(height: 2.h),
                                  if (primaryStats['totalWorkouts'] > 0)
                                    _buildComparisonSection(),
                                  SizedBox(height: 4.h),
                                ],
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 60.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 80,
              color: AppTheme.neutralGray,
            ),
            SizedBox(height: 3.h),
            Text(
              'No Workout Data Yet',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Start your first workout to see detailed progress statistics and analytics.',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.neutralGray,
                height: 1.5,
              ),
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: 60.w,
              height: 6.h,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/home-dashboard-screen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.pureWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.play_arrow),
                label: Text(
                  'Start First Workout',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.pureWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            if (kDebugMode) // Only show in debug mode
              TextButton(
                onPressed: () async {
                  await _demoMode.setDemoMode(true);
                  await _loadData();
                },
                child: Text(
                  'Enable Demo Mode',
                  style: TextStyle(
                    color: AppTheme.accentTeal,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Comparison',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildComparisonItem(
                  'This Month',
                  '${primaryStats['totalWorkouts']} workouts',
                  '+12%',
                  true,
                  AppTheme.primaryBlue,
                ),
              ),
              Container(
                width: 1,
                height: 8.h,
                color: AppTheme.neutralGray.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildComparisonItem(
                  'Last Month',
                  '${(primaryStats['totalWorkouts'] * 0.85).round()} workouts',
                  '+8%',
                  true,
                  AppTheme.accentTeal,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'trending_up',
                  color: AppTheme.successGreen,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Great improvement! Keep up the excellent work.',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(
    String period,
    String value,
    String change,
    bool isPositive,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: 'bar_chart',
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: isPositive ? 'trending_up' : 'trending_down',
              color: isPositive ? AppTheme.successGreen : AppTheme.errorRed,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              change,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isPositive ? AppTheme.successGreen : AppTheme.errorRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          period,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.neutralGray,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 8.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem('Home', 'home', false, '/home-dashboard-screen'),
              _buildNavItem('Workouts', 'fitness_center', false,
                  '/workout-detail-screen'),
              _buildNavItem(
                  'Progress', 'bar_chart', true, '/progress-statistics-screen'),
              _buildNavItem('Settings', 'settings', false, '/settings-screen'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      String label, String iconName, bool isActive, String route) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: isActive ? AppTheme.primaryBlue : AppTheme.neutralGray,
            size: 24,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: isActive ? AppTheme.primaryBlue : AppTheme.neutralGray,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _onPeriodChanged(String period) {
    setState(() {
      selectedPeriod = period;
    });
  }

  void _exportStatistics() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exporting statistics...'),
        backgroundColor: AppTheme.primaryBlue,
        action: SnackBarAction(
          label: 'View',
          textColor: AppTheme.pureWhite,
          onPressed: () {
            Navigator.pushNamed(context, '/settings-screen');
          },
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statistics updated!'),
          backgroundColor: AppTheme.successGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _updateGoal(Map<String, dynamic> newGoalData) {
    setState(() {
      goalData = newGoalData;
    });
  }
}