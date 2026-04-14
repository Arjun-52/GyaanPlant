import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/dashboard_viewmodel.dart';
import 'package:gyaanplant/views/student_role/student/widgets/upcoming_drives_section.dart';
import 'package:provider/provider.dart';

import 'package:gyaanplant/core/common_widgets/common_bottom_nav.dart';

import 'package:gyaanplant/views/student_role/student/widgets/active_courses_section.dart';
import 'package:gyaanplant/views/student_role/student/widgets/home_header.dart';
import 'package:gyaanplant/views/student_role/student/widgets/bot_card.dart';
import 'package:gyaanplant/views/student_role/student/widgets/quick_actions.dart';
import 'package:gyaanplant/views/student_role/student/widgets/score_card.dart';
import 'package:gyaanplant/views/student_role/student/widgets/streak_card.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  /// Safely extract student name from student data with type checking
  String? _getStudentName(Map<String, dynamic>? studentData) {
    if (studentData == null) return null;

    final user = studentData['user'];

    // If user is a Map, try to get the name field
    if (user is Map<String, dynamic>) {
      return user['name'] as String?;
    }

    // If user is a String (ID), we can't get name from it
    // Return null to trigger fallback
    if (user is String) {
      return null;
    }

    // Any other type, return null
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel()..fetchDashboard(),

      child: Scaffold(
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
                    ///  HEADER (you can later pass name/avatar)
                    HomeHeader(name: _getStudentName(data.student) ?? "User"),

                    const SizedBox(height: 20),

                    ///  SCORE CARD
                    ScoreCard(
                      xp: data.xp,
                      rank: data.rank,
                      progress: data.xpProgress,
                    ),

                    const SizedBox(height: 20),

                    ///  STREAK (we’ll connect later)
                    const StreakCard(),

                    const SizedBox(height: 20),

                    ///  QUICK ACTIONS
                    const QuickActions(),

                    const SizedBox(height: 20),

                    ///  BOT CARD
                    const BotCard(),

                    const SizedBox(height: 20),
                    const Text(
                      "Active Courses",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    ///  COURSES (connected to API)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: ActiveCoursesSection(
                          enrollments: data.enrollments,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    UpcomingDrivesSection(drives: []),
                  ],
                ),
              );
            },
          ),
        ),

        bottomNavigationBar: const CommonBottomNav(currentIndex: 0),
      ),
    );
  }
}
