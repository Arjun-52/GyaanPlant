import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/tpo_bottom_nav.dart';
import 'package:gyaanplant/views/tpo_role/home/screens/tpo_home_screen.dart';
import 'package:gyaanplant/views/tpo_role/student/screens/student_screen.dart';
import 'package:gyaanplant/views/tpo_role/Drives/screens/drive_screen.dart';
import 'package:gyaanplant/views/tpo_role/reports/screens/reports_screen.dart';
import 'package:gyaanplant/views/tpo_role/settings/screens/settings_screen.dart' as tpo;

class TPOShell extends StatefulWidget {
  const TPOShell({super.key});

  @override
  State<TPOShell> createState() => _TPOShellState();
}

class _TPOShellState extends State<TPOShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TPODashboard(),
    StudentScreen(),
    DrivesScreen(),
    ReportsScreen(),
    tpo.SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: TpoBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
