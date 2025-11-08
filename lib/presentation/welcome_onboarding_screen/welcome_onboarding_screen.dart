import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/page_indicator_widget.dart';

class WelcomeOnboardingScreen extends StatefulWidget {
  const WelcomeOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeOnboardingScreen> createState() =>
      _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  void _nextPage() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _skipToEnd() {
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login-registration-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // PageView for multiple onboarding slides
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  // Slide 1 - Welcome to FitMotion
                  _buildSlide1(constraints),
                  // Slide 2 - Guided Workouts
                  _buildSlide2(constraints),
                  // Slide 3 - Track Progress
                  _buildSlide3(constraints),
                ],
              ),

              // Overlay controls (Skip, Page Indicator, and Next buttons)
              SafeArea(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip Button (Top Right) - Responsive positioning
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth > 600 ? 4.w : 6.w,
                          vertical: constraints.maxHeight > 800 ? 1.5.h : 2.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _skipToEnd,
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.pureWhite,
                                backgroundColor: AppTheme.textDark.withValues(
                                  alpha: 0.3,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      constraints.maxWidth > 600 ? 3.w : 4.w,
                                  vertical:
                                      constraints.maxHeight > 800 ? 0.8.h : 1.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2.h),
                                ),
                              ),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: AppTheme.pureWhite,
                                  fontWeight: FontWeight.w500,
                                  fontSize: constraints.maxWidth > 600
                                      ? 12.sp
                                      : 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Page Indicator - Positioned above buttons
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        child: PageIndicatorWidget(
                          currentPage: _currentIndex,
                          totalPages: 3,
                        ),
                      ),

                      // Action Buttons - Responsive spacing and sizing
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth > 600 ? 4.w : 6.w,
                          vertical: constraints.maxHeight > 800 ? 2.h : 3.h,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Next/Get Started Button - Responsive sizing
                            SizedBox(
                              width: double.infinity,
                              height: constraints.maxHeight > 800 ? 5.5.h : 6.h,
                              child: ElevatedButton(
                                onPressed: _nextPage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  foregroundColor: AppTheme.pureWhite,
                                  elevation: 2,
                                  shadowColor: AppTheme.shadowLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3.h),
                                  ),
                                ),
                                child: Text(
                                  _currentIndex == 2 ? 'Get Started' : 'Next',
                                  style: TextStyle(
                                    color: AppTheme.pureWhite,
                                    fontWeight: FontWeight.w600,
                                    fontSize: constraints.maxWidth > 600
                                        ? 14.sp
                                        : 16.sp,
                                  ),
                                ),
                              ),
                            ),

                            // Bottom padding for safe area - Responsive
                            SizedBox(
                              height: constraints.maxHeight > 800 ? 1.5.h : 2.h,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Slide 1 - Welcome to FitMotion with responsive text overlay
  Widget _buildSlide1(BoxConstraints constraints) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-screen responsive background image
        Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Image.asset(
            'assets/images/fitmotion_runner_compressed-1760612586485.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            semanticLabel:
                "Professional fitness image showing a woman in athletic wear (grey tank top and navy blue leggings) performing a running lunge exercise against an urban wall background with graffiti",
          ),
        ),

        // Responsive text overlay with gradient background
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600 ? 8.w : 6.w,
                vertical: constraints.maxHeight > 800 ? 8.h : 10.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - Responsive sizing
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.85,
                    ),
                    child: Text(
                      'Welcome to\nFitMotion',
                      style: TextStyle(
                        color: AppTheme.pureWhite,
                        fontSize: constraints.maxWidth > 600
                            ? 24.sp
                            : constraints.maxWidth < 350
                                ? 20.sp
                                : 22.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: constraints.maxHeight > 800 ? 2.h : 1.5.h),

                  // Description - Responsive sizing and wrapping
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.9,
                    ),
                    child: Text(
                      'Transform your fitness journey with personalized workouts, expert guidance, and powerful progress tracking.',
                      style: TextStyle(
                        color: AppTheme.pureWhite,
                        fontSize: constraints.maxWidth > 600
                            ? 12.sp
                            : constraints.maxWidth < 350
                                ? 11.sp
                                : 13.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),

                  // Spacer to push content up from buttons
                  SizedBox(height: constraints.maxHeight > 800 ? 12.h : 10.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Slide 2 - Guided Workouts with responsive text overlay
  Widget _buildSlide2(BoxConstraints constraints) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-screen responsive background image
        Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Image.asset(
            'assets/images/fitmotion_onboarding_2_extended-1760613178218.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            semanticLabel:
                "Professional gym workout image showing someone's legs and feet in blue athletic shoes with red accents on rubber gym flooring while holding workout equipment",
          ),
        ),

        // Responsive text overlay with gradient background
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600 ? 8.w : 6.w,
                vertical: constraints.maxHeight > 800 ? 8.h : 10.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - Responsive sizing
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.85,
                    ),
                    child: Text(
                      'Expert-Led\nWorkouts',
                      style: TextStyle(
                        color: AppTheme.pureWhite,
                        fontSize: constraints.maxWidth > 600
                            ? 24.sp
                            : constraints.maxWidth < 350
                                ? 20.sp
                                : 22.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: constraints.maxHeight > 800 ? 2.h : 1.5.h),

                  // Description - Responsive sizing and wrapping
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.9,
                    ),
                    child: Text(
                      'Follow along with professional trainers through guided workouts designed for your fitness level and goals.',
                      style: TextStyle(
                        color: AppTheme.pureWhite,
                        fontSize: constraints.maxWidth > 600
                            ? 12.sp
                            : constraints.maxWidth < 350
                                ? 11.sp
                                : 13.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),

                  // Spacer to push content up from buttons
                  SizedBox(height: constraints.maxHeight > 800 ? 12.h : 10.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Slide 3 - Track Progress with responsive text overlay
  Widget _buildSlide3(BoxConstraints constraints) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-screen responsive background image
        Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Image.asset(
            'assets/images/progress_dark_wide_compressed-1760615991215.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            semanticLabel:
                "Dark-themed progress analytics interface featuring a weight tracking chart with blue to purple gradient line graph from Dec to Aug, fitness statistics displaying 102 Miles Ran, 58 Workouts, 9'12 Avg. Pace, and 14,50 Calories on a dark background with rounded corners in a wider format",
          ),
        ),

        // Responsive text overlay with gradient background
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600 ? 8.w : 6.w,
                vertical: constraints.maxHeight > 800 ? 8.h : 10.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - Responsive sizing
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.85,
                    ),
                    child: Text(
                      'Track Your\nProgress',
                      style: TextStyle(
                        color: AppTheme.pureWhite,
                        fontSize: constraints.maxWidth > 600
                            ? 24.sp
                            : constraints.maxWidth < 350
                                ? 20.sp
                                : 22.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: constraints.maxHeight > 800 ? 2.h : 1.5.h),

                  // Description - Responsive sizing and wrapping
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.9,
                    ),
                    child: Text(
                      'Monitor your fitness journey with detailed analytics, achievement badges, and personalized insights to reach your goals.',
                      style: TextStyle(
                        color: AppTheme.pureWhite,
                        fontSize: constraints.maxWidth > 600
                            ? 12.sp
                            : constraints.maxWidth < 350
                                ? 11.sp
                                : 13.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),

                  // Spacer to push content up from buttons
                  SizedBox(height: constraints.maxHeight > 800 ? 12.h : 10.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
