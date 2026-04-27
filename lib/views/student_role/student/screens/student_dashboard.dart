import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/dashboard_viewmodel.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/auth_viewmodel.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'package:gyaanplant/views/student_role/student/widgets/upcoming_drives_section.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/services/student_services/local_storage_service.dart';

import 'package:gyaanplant/core/common_widgets/common_bottom_nav.dart';

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
      context.read<DashboardViewModel>().fetchDashboard();
      loadEnrollments();
    });
  }

  String? _getDriveText(List<dynamic>? drives) {
    if (drives == null || drives.isEmpty) {
      return null;
    }

    // Get the first upcoming drive
    final firstDrive = drives.first;
    final company = firstDrive['company'] as String?;
    final driveDateStr = firstDrive['driveDate'] as String?;

    if (company == null || driveDateStr == null) {
      return null;
    }

    try {
      // Parse the drive date
      final driveDate = DateTime.parse(driveDateStr);
      final now = DateTime.now();
      final difference = driveDate.difference(now).inDays;

      if (difference < 0) {
        return null; // Past drive, don't show
      }

      if (difference == 0) {
        return "$company drive today!";
      } else if (difference == 1) {
        return "$company drive tomorrow!";
      } else {
        return "$company drive in $difference days";
      }
    } catch (e) {
      return null;
    }
  }

  void loadEnrollments() async {
    print("🚀 DASHBOARD: loadEnrollments() called");
    final token = await LocalStorageService.getToken();
    print("🔑 DASHBOARD: Token retrieved: ${token != null ? '✅' : '❌ NULL'}");

    if (token != null && mounted) {
      print("📱 DASHBOARD: Calling fetchEnrollments with token");
      final vm = context.read<LearningViewModel>();
      vm.fetchEnrollments(token);
    } else {
      print("❌ DASHBOARD: Token is null or widget not mounted");
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
              print('📱 UI: Showing loading state');
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.errorMessage != null) {
              print(' UI: Showing error state: ${vm.errorMessage}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${vm.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vm.fetchDashboard(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            //  No data
            if (vm.dashboard == null) {
              print('⚠️ UI: No dashboard data available');
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No data available",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Check console for debug info",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final data = vm.dashboard!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///  HEADER
                  HomeHeader(
                    name: () {
                      final userName = context.read<AuthViewModel>().userName;
                      print(" DEBUG: userName from AuthViewModel: $userName");
                      return userName ?? "User";
                    }(),
                    driveText: _getDriveText(data.drives),
                  ),

                  const SizedBox(height: 20),

                  ///  SCORE CARD
                  ScoreCard(
                    xp: data.xp,
                    rank: data.rank,
                    progress: data.xpProgress,
                  ),

                  const SizedBox(height: 20),

                  ///  STREAK (we'll connect later)
                  const StreakCard(),

                  const SizedBox(height: 20),

                  ///  QUICK ACTIONS
                  const QuickActions(),

                  const SizedBox(height: 20),

                  ///  BOT CARD
                  const BotCard(),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                  ),

                  ///  COURSES
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 350),
                      child: Consumer<LearningViewModel>(
                        builder: (context, vm, _) {
                          print("UI RECEIVED IN DASHBOARD: ${vm.enrollments}");
                          print(
                            "UI ENROLLMENTS COUNT IN DASHBOARD: ${vm.enrollments.length}",
                          );

                          if (vm.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return ActiveCoursesSection(
                            enrollments: vm.enrollments,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  UpcomingDrivesSection(drives: data.drives ?? []),
                ],
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: const CommonBottomNav(currentIndex: 0),
    );
  }
}
