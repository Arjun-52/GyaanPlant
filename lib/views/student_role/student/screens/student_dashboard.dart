import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/dashboard_viewmodel.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/auth_viewmodel.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'package:gyaanplant/views/student_role/student/widgets/upcoming_drives_section.dart';
import 'package:provider/provider.dart';

import 'package:gyaanplant/views/student_role/student/widgets/active_courses_section.dart';
import 'package:gyaanplant/views/student_role/student/widgets/home_header.dart';
import 'package:gyaanplant/views/student_role/student/widgets/bot_card.dart';
import 'package:gyaanplant/views/student_role/student/widgets/quick_actions.dart';
import 'package:gyaanplant/views/student_role/student/widgets/score_card.dart';
import 'package:gyaanplant/views/student_role/student/widgets/streak_card.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with TickerProviderStateMixin {
  late final AnimationController _staggerCtrl;
  late final AnimationController _pulseCtrl;

  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    // Staggered Entrance Animation
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnims = List.generate(7, (index) {
      final double start = index * 0.08;
      final double end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(7, (index) {
      final double start = index * 0.08;
      final double end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0.0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.fastOutSlowIn),
        ),
      );
    });

    // Looping Shimmer Pulse Animation for Loading Skeletons
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.45, end: 0.75).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardViewModel>().fetchDashboard().then((_) {
          if (mounted) {
            _staggerCtrl.forward(from: 0.0);
          }
        });
        _loadEnrollments();
      }
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String? _getDriveText(List<dynamic>? drives) {
    if (drives == null || drives.isEmpty) return null;

    final firstDrive = drives.first;
    final company = firstDrive['company'] as String?;
    final driveDateStr = firstDrive['driveDate'] as String?;
    if (company == null || driveDateStr == null) return null;

    try {
      final driveDate = DateTime.parse(driveDateStr);
      final difference = driveDate.difference(DateTime.now()).inDays;
      if (difference < 0) return null;
      if (difference == 0) return '$company drive today!';
      if (difference == 1) return '$company drive tomorrow!';
      return '$company drive in $difference days';
    } catch (_) {
      return null;
    }
  }

  void _loadEnrollments() async {
    if (mounted) {
      context.read<LearningViewModel>().fetchCourses();
    }
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBlock(height: 80, radius: 24),
          const SizedBox(height: 18),
          _skeletonBlock(height: 154, radius: 24),
          const SizedBox(height: 18),
          _skeletonBlock(height: 104, radius: 24),
          const SizedBox(height: 18),
          _skeletonBlock(height: 88, radius: 18),
          const SizedBox(height: 18),
          _skeletonBlock(height: 124, radius: 22),
        ],
      ),
    );
  }

  Widget _skeletonBlock({required double height, required double radius}) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Opacity(
          opacity: _pulseAnim.value,
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: const LinearGradient(
                colors: [Color(0xFF0C241E), Color(0xFF02100C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFF00E676).withValues(alpha: 0.05),
                width: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: Stack(
        children: [
          // Background ambient glowing gradients
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF02120F), Color(0xFF020907)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0A00E676), // 4% opacity (withValues(alpha: 0.04) equivalent)
                ),
              ),
            ),
          ),
          SafeArea(
            child: Consumer<DashboardViewModel>(
              builder: (context, vm, child) {
                // Show loading state with premium skeleton shimmers
                if (vm.isLoading) {
                  return _buildSkeletonLoader();
                }

                // Show error state
                if (vm.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Could not load dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            vm.errorMessage ?? 'Unknown error',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onPressed: () {
                              vm.isLoaded = false;
                              vm.fetchDashboard().then((_) {
                                if (mounted) _staggerCtrl.forward(from: 0.0);
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Show empty state
                if (vm.dashboard == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.dashboard_rounded,
                          color: Colors.white38,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No data available',
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            vm.isLoaded = false;
                            vm.fetchDashboard().then((_) {
                              if (mounted) _staggerCtrl.forward(from: 0.0);
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Normal state - render staggered animated list
                if (!_staggerCtrl.isAnimating && _staggerCtrl.value == 0.0) {
                  _staggerCtrl.forward();
                }

                final data = vm.dashboard!;
                final userName = context.read<AuthViewModel>().userName ?? 'User';

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80), // extra padding for floating navbar
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. GREETING
                      FadeTransition(
                        opacity: _fadeAnims[0],
                        child: SlideTransition(
                          position: _slideAnims[0],
                          child: HomeHeader(
                            name: userName,
                            driveText: _getDriveText(data.drives),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. HERO READINESS SCORE
                      FadeTransition(
                        opacity: _fadeAnims[1],
                        child: SlideTransition(
                          position: _slideAnims[1],
                          child: ScoreCard(
                            xp: data.xp ?? 0,
                            rank: data.rank ?? 0,
                            progress: data.xpProgress ?? 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. STREAK
                      FadeTransition(
                        opacity: _fadeAnims[2],
                        child: SlideTransition(
                          position: _slideAnims[2],
                          child: const StreakCard(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. QUICK ACTIONS
                      FadeTransition(
                        opacity: _fadeAnims[3],
                        child: SlideTransition(
                          position: _slideAnims[3],
                          child: const QuickActions(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. GYAANBOT
                      FadeTransition(
                        opacity: _fadeAnims[4],
                        child: SlideTransition(
                          position: _slideAnims[4],
                          child: const BotCard(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 6. ACTIVE COURSES
                      FadeTransition(
                        opacity: _fadeAnims[5],
                        child: SlideTransition(
                          position: _slideAnims[5],
                          child: Consumer<LearningViewModel>(
                            builder: (context, lvm, _) {
                              if (lvm.isLoading) {
                                return _skeletonBlock(height: 100, radius: 20);
                              }
                              return ActiveCoursesSection(
                                enrollments: lvm.enrollments,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 7. UPCOMING DRIVES
                      FadeTransition(
                        opacity: _fadeAnims[6],
                        child: SlideTransition(
                          position: _slideAnims[6],
                          child: UpcomingDrivesSection(drives: data.drives ?? const []),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
