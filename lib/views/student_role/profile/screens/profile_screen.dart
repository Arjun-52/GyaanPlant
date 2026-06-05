import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/dashboard_viewmodel.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/certificates_viewmodel.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/achievements_viewmodel.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/badge_card.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/support_card.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/certificates_empty_state_fixed.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/achievements_empty_state_fixed.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/mentor_section.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/profile_header.dart';
import 'package:gyaanplant/views/student_role/profile/widgets/stats_grid.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/student_viewmodel/auth_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final CertificatesViewModel _certificatesViewModel = CertificatesViewModel();
  final AchievementsViewModel _achievementsViewModel = AchievementsViewModel();
  
  late final AnimationController _staggerCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();

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

    Future.microtask(() {
      if (mounted) {
        context.read<DashboardViewModel>().fetchDashboard().then((_) {
          if (mounted) {
            _staggerCtrl.forward(from: 0.0);
          }
        });
        _certificatesViewModel.initialize();
        _achievementsViewModel.initialize();
      }
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
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
                  color: Color(0x0A00E676),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Consumer<DashboardViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                    ),
                  );
                }

                final data = vm.dashboard;
                final student = data?.student;

                if (!_staggerCtrl.isAnimating && _staggerCtrl.value == 0.0) {
                  _staggerCtrl.forward();
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Profile Header Hero Card
                      FadeTransition(
                        opacity: _fadeAnims[0],
                        child: SlideTransition(
                          position: _slideAnims[0],
                          child: ProfileHeader(
                            rank: data?.rank ?? 0,
                            streak: student?['streakDays'] ?? 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Support Card
                      FadeTransition(
                        opacity: _fadeAnims[1],
                        child: SlideTransition(
                          position: _slideAnims[1],
                          child: const SupportCard(),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 2. Share Badge Card
                      FadeTransition(
                        opacity: _fadeAnims[2],
                        child: SlideTransition(
                          position: _slideAnims[2],
                          child: const BadgeCard(),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 3. Stats Grid
                      FadeTransition(
                        opacity: _fadeAnims[3],
                        child: SlideTransition(
                          position: _slideAnims[3],
                          child: StatsGrid(
                            readinessScore: student?['profileStrength'] ?? 0,
                            testsCompleted: student?['testsCompleted'] ?? 0,
                            hoursLearned: student?['totalPoints'] ?? 0,
                            streak: student?['streakDays'] ?? 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 4. Certificates Section
                      FadeTransition(
                        opacity: _fadeAnims[4],
                        child: SlideTransition(
                          position: _slideAnims[4],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'My Certificates',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  Text(
                                    'View all',
                                    style: TextStyle(
                                      color: Color(0xFF00E676),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ChangeNotifierProvider.value(
                                value: _certificatesViewModel,
                                child: Consumer<CertificatesViewModel>(
                                  builder: (context, certificatesVM, child) {
                                    if (certificatesVM.isLoading &&
                                        certificatesVM.certificates.isEmpty) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Color(0xFF00E676),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    if (certificatesVM.hasError) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.error_outline_rounded,
                                              size: 36,
                                              color: Colors.redAccent,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              certificatesVM.errorMessage!,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 12),
                                            ElevatedButton(
                                              onPressed: () => certificatesVM.retry(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF00E676),
                                                foregroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text('Retry'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return const CertificatesEmptyStateFixed();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 5. Achievements Section
                      FadeTransition(
                        opacity: _fadeAnims[5],
                        child: SlideTransition(
                          position: _slideAnims[5],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Unlocked Achievements',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ChangeNotifierProvider.value(
                                value: _achievementsViewModel,
                                child: Consumer<AchievementsViewModel>(
                                  builder: (context, achievementsVM, child) {
                                    if (achievementsVM.isLoading &&
                                        achievementsVM.achievements.isEmpty) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Color(0xFF00E676),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    if (achievementsVM.hasError) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.error_outline_rounded,
                                              size: 36,
                                              color: Colors.redAccent,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              achievementsVM.errorMessage!,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 12),
                                            ElevatedButton(
                                              onPressed: () => achievementsVM.retry(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF00E676),
                                                foregroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text('Retry'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return const AchievementsEmptyStateFixed();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 6. Alumni Mentors Section
                      FadeTransition(
                        opacity: _fadeAnims[6],
                        child: SlideTransition(
                          position: _slideAnims[6],
                          child: const MentorSection(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Logout button at top right
          Positioned(
            top: 10,
            right: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF02100C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: const Color(0xFF00E676).withOpacity(0.15),
                        ),
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                        'Are you sure you want to logout of your learning journey?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white60),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true && context.mounted) {
                    context.read<AuthViewModel>().logout(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
