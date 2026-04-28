import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/dashboard_viewmodel.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/auth_viewmodel.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'package:gyaanplant/views/student_role/student/widgets/upcoming_drives_section.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/data/services/local_storage_service.dart';

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
    final token = await LocalStorageService.getToken();
    if (token != null && mounted) {
      context.read<LearningViewModel>().fetchEnrollments(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031B15),
      body: SafeArea(
        child: Consumer<DashboardViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.white38, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Could not load dashboard',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check your connection and try again',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        vm.isLoaded = false;
                        vm.fetchDashboard();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (vm.dashboard == null) {
              return const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

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
                    xp: data.xp,
                    rank: data.rank,
                    progress: data.xpProgress,
                  ),
                  const SizedBox(height: 20),
                  const StreakCard(),
                  const SizedBox(height: 20),
                  const QuickActions(),
                  const SizedBox(height: 20),
                  const BotCard(),
                  const SizedBox(height: 20),

                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 350),
                      child: Consumer<LearningViewModel>(
                        builder: (context, lvm, _) {
                          if (lvm.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return ActiveCoursesSection(enrollments: lvm.enrollments);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  UpcomingDrivesSection(drives: data.drives),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
