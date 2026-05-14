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

class MentorProfileScreen extends StatelessWidget {
  const MentorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MentorProfileViewModel()..loadProfile(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<MentorProfileViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.dashboard == null) {
              return const Center(
                child: Text(
                  "Failed to load",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final data = vm.dashboard!;

            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// Header with title and logout
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final shouldLogout = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF1A0033),
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
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
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
                                await context.read<AuthViewModel>().logout(
                                  context,
                                );
                                if (context.mounted) context.go('/role');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.5),
                                ),
                              ),
                              child: const Icon(
                                Icons.logout,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                            ? () => vm.saveProfile()
                            : null,
                        isLoading: vm.isSaving,
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
