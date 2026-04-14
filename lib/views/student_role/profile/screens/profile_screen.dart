import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/common_bottom_nav.dart';

import 'package:gyaanplant/viewmodels/student_viewmodel/dashboard_viewmodel.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/achievements_section.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/badge_card.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/certificate_card.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/mentor_section.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/profile_header.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/stats_grid.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel()..fetchDashboard(),

      child: Scaffold(
        backgroundColor: const Color(0xFF020B08),
        bottomNavigationBar: const CommonBottomNav(currentIndex: 4),

        body: Consumer<DashboardViewModel>(
          builder: (context, vm, child) {
            ///  LOADING
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = vm.dashboard;
            final student = data?.student;

            return Padding(
              padding: const EdgeInsets.all(16),

              child: ListView(
                children: [
                  const SizedBox(height: 20),

                  /// HEADER (PASS DATA)
                  ProfileHeader(
                    rank: data?.rank ?? 0,
                    streak: student?['streakDays'] ?? 0,
                  ),

                  const SizedBox(height: 20),

                  const BadgeCard(),

                  const SizedBox(height: 20),

                  ///  STATS GRID (PASS DATA)
                  StatsGrid(
                    readinessScore: student?['profileStrength'] ?? 0,
                    testsCompleted: student?['testsCompleted'] ?? 0,
                    hoursLearned: student?['totalPoints'] ?? 0,
                    streak: student?['streakDays'] ?? 0,
                  ),

                  const SizedBox(height: 20),

                  /// CERTIFICATES HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "My Certificates",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "View all",
                        style: TextStyle(
                          color: Color(0xFF00C853),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const CertificateCard(),

                  const SizedBox(height: 20),

                  const AchievementsSection(),

                  const SizedBox(height: 20),

                  const MentorSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
