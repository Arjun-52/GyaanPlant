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

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardViewModel>().fetchDashboard();
        _loadEnrollments();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031B15),
      body: SafeArea(
        child: Consumer<DashboardViewModel>(
          builder: (context, vm, child) {
            print("🎨 [StudentDashboard.build] Rendering - isLoading: ${vm.isLoading}, isLoaded: ${vm.isLoaded}, errorMessage: ${vm.errorMessage}, dashboardNull: ${vm.dashboard == null}");
            
            // Show loading state
            if (vm.isLoading) {
              print("🎨 [StudentDashboard.build] Showing loading spinner");
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading dashboard...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            }

            // Show error state
            if (vm.errorMessage != null) {
              print("🎨 [StudentDashboard.build] Showing error: ${vm.errorMessage}");
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      color: Colors.white38,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Could not load dashboard',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vm.errorMessage ?? 'Unknown error',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        print("🎨 [StudentDashboard.build] Retry button pressed");
                        vm.isLoaded = false;
                        vm.fetchDashboard();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Show empty state
            if (vm.dashboard == null) {
              print("🎨 [StudentDashboard.build] Dashboard is null, showing no data message");
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.dashboard,
                      color: Colors.white38,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No data available',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        print("🎨 [StudentDashboard.build] Retry button pressed");
                        vm.isLoaded = false;
                        vm.fetchDashboard();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            print("🎨 [StudentDashboard.build] Showing dashboard content");
            final data = vm.dashboard!;
            final userName = context.read<AuthViewModel>().userName ?? 'User';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(
                    name: userName,
                    driveText: _getDriveText(data.drives),
                  ),
                  const SizedBox(height: 20),
                  ScoreCard(
                    xp: data.xp ?? 0,
                    rank: data.rank ?? 0,
                    progress: data.xpProgress ?? 0,
                  ),
                  const SizedBox(height: 20),
                  const StreakCard(),
                  const SizedBox(height: 20),
                  const QuickActions(),
                  const SizedBox(height: 20),
                  const BotCard(),
                  const SizedBox(height: 20),

                  Consumer<LearningViewModel>(
                    builder: (context, lvm, _) {
                      if (lvm.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ActiveCoursesSection(
                        enrollments: lvm.enrollments,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  UpcomingDrivesSection(drives: data.drives ?? const []),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
