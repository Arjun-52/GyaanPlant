import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/dashboard_viewmodel.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/achievements_section.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/badge_card.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/certificate_card.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/mentor_section.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/profile_header.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/stats_grid.dart';
import 'package:provider/provider.dart';
import '../../../../data/services/local_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<DashboardViewModel>().fetchDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = vm.dashboard;
          final student = data?.student;

          return Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    ProfileHeader(
                      rank: data?.rank ?? 0,
                      streak: student?['streakDays'] ?? 0,
                    ),
                    const SizedBox(height: 20),
                    const BadgeCard(),
                    const SizedBox(height: 20),
                    StatsGrid(
                      readinessScore: student?['profileStrength'] ?? 0,
                      testsCompleted: student?['testsCompleted'] ?? 0,
                      hoursLearned: student?['totalPoints'] ?? 0,
                      streak: student?['streakDays'] ?? 0,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'My Certificates',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'View all',
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
              ),
              // Logout button at top right
              Positioned(
                top: 50,
                right: 16,
                child: GestureDetector(
                  onTap: () async {
                    // Show confirmation dialog
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF020B08),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true) {
                      await LocalStorageService.clearToken();
                      if (context.mounted) context.go('/');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
