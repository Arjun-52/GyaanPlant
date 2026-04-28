import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/mentor_viewmodel/mentor_profile_viewmodel.dart';
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
                    ExpertiseSection(expertise: vm.expertise),
                    AvailabilitySection(availability: vm.availability),
                    SaveButton(onPressed: () {}),
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
