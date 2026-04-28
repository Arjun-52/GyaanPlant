import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/HOD_bottom_nav.dart';
import 'package:gyaanplant/views/HOD_role/overview/screens/overview_screen.dart';
import 'package:gyaanplant/views/HOD_role/depts/screens/departments_screen.dart';
import 'package:gyaanplant/views/HOD_role/analytics/screens/analytics_screen.dart';
import 'package:gyaanplant/views/HOD_role/naac/screens/naac_screen.dart';
import 'package:gyaanplant/views/HOD_role/settings/screens/settings_screen.dart';

class HODShell extends StatefulWidget {
  const HODShell({super.key});

  @override
  State<HODShell> createState() => _HODShellState();
}

class _HODShellState extends State<HODShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const OverViewScreen(),
    const DepartmentsScreen(),
    AnalyticsScreen(),
    const NaacScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: HODBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
