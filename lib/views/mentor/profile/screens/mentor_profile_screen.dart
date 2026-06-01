import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/viewmodels/mentor_viewmodel/mentor_profile_viewmodel.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/core/common_widgets/mentor_bottom_nav.dart';
import 'package:gyaanplant/models/mentor_models/mentor_profile_model.dart';

import '../widgets/profile_header.dart';
import '../widgets/expertise_section.dart';
import '../widgets/availability_section.dart';
import '../widgets/save_button.dart';

class MentorProfileScreen extends StatefulWidget {
  const MentorProfileScreen({super.key});

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MentorProfileViewModel()..loadProfile(),
      child: Scaffold(
        backgroundColor: const Color(0xFF020B08),
        body: Consumer<MentorProfileViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00E676),
                ),
              );
            }

            if (vm.dashboard == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to Load Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => vm.loadProfile(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Start entry animations
            _animController.forward();

            final data = vm.dashboard!;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    /// Header with title and logout
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E676).withOpacity(0.4),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () async {
                              final shouldLogout = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF0C1612),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: const Color(0xFFFF1744).withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  title: const Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: const Text(
                                    'Are you sure you want to logout from GyaanPlant?',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF1744),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 8,
                                        shadowColor: const Color(0xFFFF1744).withOpacity(0.4),
                                      ),
                                      child: const Text(
                                        'Logout',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (shouldLogout == true) {
                                if (context.mounted) {
                                  await context.read<AuthViewModel>().logout(context);
                                  if (context.mounted) context.go('/role');
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF1744).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFF1744).withOpacity(0.25),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF1744).withOpacity(0.05),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFFF1744),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Staggered animated scroll area
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: child,
                            ),
                          );
                        },
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              ProfileHeader(
                                mentor: Mentor(
                                  name: data.name,
                                  role: data.role,
                                  rating: data.rating,
                                  sessions: data.sessionsDone,
                                  expertise: vm.expertise,
                                  availability: vm.availability,
                                ),
                              ),
                              ExpertiseSection(
                                expertise: vm.expertise,
                                onToggle: (skill) => vm.toggleExpertise(skill),
                              ),
                              AvailabilitySection(
                                availability: vm.availability,
                                onToggle: (day, time) => vm.toggleTime(day, time),
                              ),
                              Consumer<MentorProfileViewModel>(
                                builder: (context, vm, _) => SaveButton(
                                  onPressed: vm.hasChanges && !vm.isSaving
                                      ? () async {
                                          final error = await vm.saveProfile();
                                          if (context.mounted) {
                                            if (error == null) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('✅ Availability updated successfully.'),
                                                  backgroundColor: Color(0xFF00E676),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('❌ Failed to save changes: $error'),
                                                  backgroundColor: Colors.redAccent,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      : null,
                                  isLoading: vm.isSaving,
                                ),
                              ),
                              
                              // Defensive spacing to protect contents from floating bottom nav bar overlap
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const MentorBottomNav(currentIndex: 4),
      ),
    );
  }
}

