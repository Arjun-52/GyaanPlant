import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/common_bottom_nav.dart';
import 'package:gyaanplant/views/student/widgets/active_courses_section.dart';
import 'package:gyaanplant/views/student/widgets/student_header.dart';
import 'package:gyaanplant/views/student/widgets/bot_card.dart';
import 'package:gyaanplant/views/student/widgets/quick_actions.dart';
import 'package:gyaanplant/views/student/widgets/score_card.dart';
import 'package:gyaanplant/views/student/widgets/streak_card.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF031B15),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 20),
              ScoreCard(),
              SizedBox(height: 20),
              StreakCard(),
              SizedBox(height: 20),
              QuickActions(),
              SizedBox(height: 20),
              BotCard(),
              SizedBox(height: 20),
              ActiveCoursesSection(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const CommonBottomNav(currentIndex: 0),
    );
  }
}
