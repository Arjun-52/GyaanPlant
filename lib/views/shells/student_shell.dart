import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/core/common_widgets/common_bottom_nav.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/student_tab_controller.dart';
import 'package:gyaanplant/views/student_role/student/screens/student_dashboard.dart';
import 'package:gyaanplant/views/student_role/learn/screens/learn_screen.dart';
import 'package:gyaanplant/views/student_role/Test_/screens/test_screen.dart';
import 'package:gyaanplant/views/student_role/jobs/screens/job_screen.dart';
import 'package:gyaanplant/views/student_role/profile/screens/profile_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final List<Widget> _pages;

  int _currentIndex = 0;
  int _previousIndex = 0;
  StudentTabController? _tabController;

  @override
  void initState() {
    super.initState();
    _pages = [
      StudentDashboard(),
      LearnScreen(),
      TestScreen(),
      JobScreen(),
      ProfileScreen(),
    ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _previousIndex = _currentIndex;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabController = Provider.of<StudentTabController>(context);
    if (_tabController != tabController) {
      _tabController?.removeListener(_onTabChanged);
      _tabController = tabController;
      _tabController?.addListener(_onTabChanged);
      _currentIndex = tabController.currentIndex;
      _previousIndex = tabController.currentIndex;
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final int newIndex = _tabController?.currentIndex ?? 0;
    if (newIndex == _currentIndex) return;

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = newIndex;
    });

    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: List.generate(_pages.length, (index) {
          final bool isCurrent = index == _currentIndex;
          final bool isPrevious = index == _previousIndex;

          // If not animating, only keep current page onstage and visible
          if (_currentIndex == _previousIndex) {
            return Offstage(
              offstage: !isCurrent,
              child: IgnorePointer(
                ignoring: !isCurrent,
                child: _pages[index],
              ),
            );
          }

          // If this screen is neither current nor previous during animation, keep it offstage
          if (!isCurrent && !isPrevious) {
            return Offstage(
              offstage: true,
              child: _pages[index],
            );
          }

          // Determine slide direction (forward/backward)
          final bool isForward = _currentIndex > _previousIndex;

          final Animation<Offset> slideAnimation;
          final Animation<double> opacityAnimation;

          if (isCurrent) {
            // New screen animating IN
            slideAnimation = Tween<Offset>(
              begin: isForward ? const Offset(0.08, 0.0) : const Offset(-0.08, 0.0),
              end: Offset.zero,
            ).animate(_animation);
            opacityAnimation = _animation;
          } else {
            // Old screen animating OUT
            slideAnimation = Tween<Offset>(
              begin: Offset.zero,
              end: isForward ? const Offset(-0.08, 0.0) : const Offset(0.08, 0.0),
            ).animate(_animation);
            opacityAnimation = Tween<double>(
              begin: 1.0,
              end: 0.0,
            ).animate(_animation);
          }

          return Offstage(
            offstage: false,
            child: IgnorePointer(
              ignoring: !isCurrent,
              child: FadeTransition(
                opacity: opacityAnimation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: _pages[index],
                ),
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: CommonBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: (index) =>
            context.read<StudentTabController>().switchTab(index),
      ),
    );
  }
}
