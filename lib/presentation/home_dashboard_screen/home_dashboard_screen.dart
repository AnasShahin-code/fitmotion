import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/database_service.dart';
import '../../services/demo_mode_service.dart';
import '../../services/tracking_service.dart';
import './widgets/premium_upgrade_banner.dart';
import './widgets/quick_stats_widget.dart';
import './widgets/recent_workout_card.dart';
import './widgets/streak_counter_widget.dart';
import './widgets/workout_category_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  bool _isRefreshing = false;
  bool _isPremiumUser = false;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  final DatabaseService _db = DatabaseService();
  final DemoModeService _demoMode = DemoModeService();
  final TrackingService _tracking = TrackingService();

  // Real data
  List<Map<String, dynamic>> _workoutCategories = [];
  List<Map<String, dynamic>> _recentWorkouts = [];
  Map<String, dynamic> _userStats = {};

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _initializeServices();
    _loadData();
  }

  Future<void> _initializeServices() async {
    await _demoMode.initialize();
    await _tracking.initializeTracking();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isRefreshing = true;
      });

      // Always disable demo mode by default - load real data only
      await _demoMode.setDemoMode(false);
      await _loadRealData();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _loadRealData() async {
    try {
      // Load real workout stats
      final stats = await _db.getWorkoutStats();
      final sessions = await _db.getWorkoutSessions(limit: 5);
      final todaysSteps = await _tracking.getTodaysSteps();

      // Convert workout sessions to recent workouts format
      final recentWorkouts = sessions
          .map((session) => {
                'id': (session as dynamic).id,
                'name': (session as dynamic).type,
                'type': (session as dynamic).type,
                'duration': (session as dynamic).duration,
                'calories': ((session as dynamic).caloriesKcal as num).round(),
                'distance': (session as dynamic).distanceM / 1000, // Convert to km
                'date': (session as dynamic).startAt,
              })
          .toList();

      // Calculate current streak
      int currentStreak = await _calculateCurrentStreak();

      setState(() {
        _userStats = {
          "totalWorkouts": stats['totalWorkouts'] ?? 0,
          "totalMinutes": stats['totalMinutes'] ?? 0,
          "caloriesBurned": (stats['totalCalories'] ?? 0.0).round(),
          "currentStreak": currentStreak,
          "streakType": "Day Streak",
          "todaysSteps": todaysSteps,
        };

        _recentWorkouts = List<Map<String, dynamic>>.from(recentWorkouts);

        // Static workout categories (these don't change)
        _workoutCategories = [
          {
            "id": 1,
            "name": "Running",
            "image":
                "https://images.unsplash.com/photo-1622853977697-f72a1b23a8e8",
            "semanticLabel":
                "Athletic man in black running gear jogging on outdoor track during sunset",
            "type": "running",
            "isPremium": false,
          },
          {
            "id": 2,
            "name": "Walking",
            "image":
                "https://images.unsplash.com/photo-1716893489124-32d2230b39bf",
            "semanticLabel":
                "Person walking on outdoor trail with scenic mountain background",
            "type": "walking",
            "isPremium": false,
          },
          {
            "id": 3,
            "name": "Strength Training",
            "image":
                "https://images.unsplash.com/photo-1701820430999-b4c0a7a8dd45",
            "semanticLabel":
                "Muscular man lifting heavy barbell in modern gym with equipment in background",
            "type": "strength",
            "isPremium": false,
          },
          {
            "id": 4,
            "name": "General Workout",
            "image":
                "https://images.unsplash.com/photo-1630225760878-d9457af14fd6",
            "semanticLabel":
                "Woman in white workout clothes doing yoga pose on purple mat in peaceful setting",
            "type": "general",
            "isPremium": false,
          },
        ];
      });
    } catch (e) {
      debugPrint('Load real data error: $e');
      // Show empty state for real data - no fallback to demo data
      setState(() {
        _userStats = {
          "totalWorkouts": 0,
          "totalMinutes": 0,
          "caloriesBurned": 0,
          "currentStreak": 0,
          "streakType": "Day Streak",
          "todaysSteps": 0,
        };
        _recentWorkouts = [];
        _workoutCategories = [
          {
            "id": 1,
            "name": "Running",
            "image":
                "https://images.unsplash.com/photo-1622853977697-f72a1b23a8e8",
            "semanticLabel":
                "Athletic man in black running gear jogging on outdoor track during sunset",
            "type": "running",
            "isPremium": false,
          },
          {
            "id": 2,
            "name": "Walking",
            "image":
                "https://images.unsplash.com/photo-1716893489124-32d2230b39bf",
            "semanticLabel":
                "Person walking on outdoor trail with scenic mountain background",
            "type": "walking",
            "isPremium": false,
          },
          {
            "id": 3,
            "name": "Strength Training",
            "image":
                "https://images.unsplash.com/photo-1701820430999-b4c0a7a8dd45",
            "semanticLabel":
                "Muscular man lifting heavy barbell in modern gym with equipment in background",
            "type": "strength",
            "isPremium": false,
          },
          {
            "id": 4,
            "name": "General Workout",
            "image":
                "https://images.unsplash.com/photo-1630225760878-d9457af14fd6",
            "semanticLabel":
                "Woman in white workout clothes doing yoga pose on purple mat in peaceful setting",
            "type": "general",
            "isPremium": false,
          },
        ];
      });
    }
  }

  Future<int> _calculateCurrentStreak() async {
    try {
      final sessions = await _db.getWorkoutSessions();
      if (sessions.isEmpty) return 0;

      int streak = 0;
      DateTime currentDate = DateTime.now();

      // Sort sessions by date (newest first)
      sessions.sort((a, b) => (b as dynamic).startAt.compareTo((a as dynamic).startAt));

      // Check each day backwards
      for (int i = 0; i < 365; i++) {
        // Max streak check of 365 days
        final checkDate = currentDate.subtract(Duration(days: i));
        final dayStart =
            DateTime(checkDate.year, checkDate.month, checkDate.day);
        final dayEnd = dayStart.add(const Duration(days: 1));

        // Check if there's a workout on this day
        final hasWorkout = sessions.any((session) =>
            (session as dynamic).startAt.isAfter(dayStart) &&
            (session as dynamic).startAt.isBefore(dayEnd));

        if (hasWorkout) {
          streak++;
        } else if (i > 0) {
          // Don't break on first day (today) if no workout yet
          break;
        }
      }

      return streak;
    } catch (e) {
      debugPrint('Calculate streak error: $e');
      return 0;
    }
  }

  void _loadBannerAd() {
    if (!_isPremiumUser) {
      _bannerAd = BannerAd(
        adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ad unit ID
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isBannerAdReady = true;
            });
          },
          onAdFailedToLoad: (ad, err) {
            _isBannerAdReady = false;
            ad.dispose();
          },
        ),
      );
      _bannerAd?.load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  void _navigateToWorkoutDetail(Map<String, dynamic> category) async {
    if (category['isPremium'] == true && !_isPremiumUser) {
      _showPremiumDialog();
      return;
    }

    // Start real workout tracking
    final workoutType = category['type'] ?? 'general';
    final success = await _tracking.startWorkout(workoutType);

    if (success && mounted) {
      Navigator.pushNamed(context, '/workout-detail-screen', arguments: {
        'category': category,
        'isTracking': true,
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to start workout tracking'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _showWorkoutOptions(Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.neutralGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'play_arrow',
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              title: Text('Start Workout'),
              onTap: () {
                Navigator.pop(context);
                _navigateToWorkoutDetail(category);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'history',
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              title: Text('View History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/progress-statistics-screen');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'star',
              color: AppTheme.energyOrange,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Premium Required'),
          ],
        ),
        content: Text(
          'This workout is available for Premium users only. Upgrade now to access all premium content!',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToSubscription();
            },
            child: Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _navigateToSubscription() {
    // Navigate to subscription screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subscription screen would open here'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _startQuickWorkout() {
    _navigateToWorkoutDetail({
      'id': 0,
      'name': 'Quick Workout',
      'type': 'general',
      'isPremium': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.primaryBlue,
          child: CustomScrollView(
            slivers: [
              // Sticky Header
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
                elevation: 0,
                expandedHeight: 12.h,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good Day!',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: AppTheme.neutralGray,
                                  ),
                                ),
                                Text(
                                  'Ready to workout?',
                                  style: AppTheme
                                      .lightTheme.textTheme.headlineSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, '/settings-screen'),
                              icon: CustomIconWidget(
                                iconName: 'settings',
                                color: AppTheme.neutralGray,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Streak Counter
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: StreakCounterWidget(
                        streakCount: _userStats['currentStreak'] ?? 0,
                        streakType: _userStats['streakType'] ?? 'Day Streak',
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Quick Stats
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: QuickStatsWidget(stats: _userStats),
                    ),

                    SizedBox(height: 3.h),

                    // Recent Workouts Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Workouts',
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, '/progress-statistics-screen'),
                            child: Text('View All'),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Recent Workouts Horizontal List or Empty State
                    _recentWorkouts.isNotEmpty
                        ? SizedBox(
                            height: 20.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              itemCount: _recentWorkouts.length,
                              itemBuilder: (context, index) {
                                return RecentWorkoutCard(
                                  workout: _recentWorkouts[index],
                                  onTap: () => Navigator.pushNamed(
                                      context, '/progress-statistics-screen'),
                                );
                              },
                            ),
                          )
                        : Container(
                            height: 20.h,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    AppTheme.neutralGray.withValues(alpha: 0.3),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fitness_center_outlined,
                                  size: 48,
                                  color: AppTheme.neutralGray,
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'No workouts yet',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: AppTheme.neutralGray,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  'Tap "Start Workout" below to begin',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme.neutralGray,
                                  ),
                                ),
                              ],
                            ),
                          ),

                    SizedBox(height: 3.h),

                    // Premium Banner (for free users)
                    if (!_isPremiumUser)
                      PremiumUpgradeBanner(
                        onUpgradeTap: _navigateToSubscription,
                      ),

                    // AdMob Banner (for free users)
                    if (!_isPremiumUser &&
                        _isBannerAdReady &&
                        _bannerAd != null)
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(vertical: 2.h),
                        child: AdWidget(ad: _bannerAd!),
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                      ),

                    // Workout Categories Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'Start Workout',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Workout Categories Grid
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 2.w,
                          mainAxisSpacing: 2.h,
                        ),
                        itemCount: _workoutCategories.length,
                        itemBuilder: (context, index) {
                          return WorkoutCategoryCard(
                            category: _workoutCategories[index],
                            onTap: () => _navigateToWorkoutDetail(
                                _workoutCategories[index]),
                            onLongPress: () =>
                                _showWorkoutOptions(_workoutCategories[index]),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 10.h), // Bottom padding for FAB
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });

          switch (index) {
            case 0:
              // Already on Home
              break;
            case 1:
              Navigator.pushNamed(context, '/progress-statistics-screen');
              break;
            case 2:
              Navigator.pushNamed(context, '/settings-screen');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentTabIndex == 0
                  ? AppTheme.primaryBlue
                  : AppTheme.neutralGray,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'bar_chart',
              color: _currentTabIndex == 1
                  ? AppTheme.primaryBlue
                  : AppTheme.neutralGray,
              size: 24,
            ),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: _currentTabIndex == 2
                  ? AppTheme.primaryBlue
                  : AppTheme.neutralGray,
              size: 24,
            ),
            label: 'Settings',
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startQuickWorkout,
        backgroundColor: AppTheme.energyOrange,
        foregroundColor: AppTheme.pureWhite,
        icon: CustomIconWidget(
          iconName: 'play_arrow',
          color: AppTheme.pureWhite,
          size: 24,
        ),
        label: Text(
          'Start Workout',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.pureWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}