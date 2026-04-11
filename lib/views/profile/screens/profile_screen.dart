import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/common_bottom_nav.dart';
import 'package:gyaanplant/viewmodels/profile_viewmodel.dart';
import 'package:gyaanplant/views/profile/widgets/achievements_section.dart';
import 'package:gyaanplant/views/profile/widgets/badge_card.dart';
import 'package:gyaanplant/views/profile/widgets/certificate_card.dart';
import 'package:gyaanplant/views/profile/widgets/mentor_section.dart';
import 'package:gyaanplant/views/profile/widgets/profile_header.dart';
import 'package:gyaanplant/views/profile/widgets/stats_grid.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFF020B08),
        bottomNavigationBar: const CommonBottomNav(currentIndex: 4),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              SizedBox(height: 20),

              ProfileHeader(),
              SizedBox(height: 20),

              BadgeCard(),
              SizedBox(height: 20),

              StatsGrid(),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Certificates",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      // TODO: navigate to certificates page
                    },
                    child: Text(
                      "View all",
                      style: TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              CertificateCard(),
              SizedBox(height: 20),

              AchievementsSection(),

              SizedBox(height: 20),

              MentorSection(),
            ],
          ),
        ),
      ),
    );
  }
}
