import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/core/common_widgets/common_bottom_nav.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/student_tab_controller.dart';
import 'package:gyaanplant/views/student_role/student/screens/student_dashboard.dart';
import 'package:gyaanplant/views/student_role/learn/screens/learn_screen.dart';
import 'package:gyaanplant/views/student_role/Test_/screens/test_screen.dart';
import 'package:gyaanplant/views/student_role/jobs/screens/job_screen.dart';
import 'package:gyaanplant/views/student_role/profile/screens/profile_screen.dart';

class StudentShell extends StatelessWidget {
  const StudentShell({super.key});

  static const List<Widget> _pages = [
    StudentDashboard(),
    LearnScreen(),
    TestScreen(),
    JobScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final tabController = context.watch<StudentTabController>();

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: tabController.currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CommonBottomNav(
        currentIndex: tabController.currentIndex,
        onTabSelected: (index) =>
            context.read<StudentTabController>().switchTab(index),
      ),
    );
  }
}
