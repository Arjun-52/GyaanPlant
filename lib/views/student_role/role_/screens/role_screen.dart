import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/role_viewmodel.dart';

import '../widgets/header_section.dart';
import '../widgets/role_list.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  final viewModel = RoleViewModel();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return WillPopScope(
      onWillPop: () async {
        context.go('/splash');
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF030705), // Deep dark black background
      body: Stack(
        children: [
          // Ambient Glow Orbs
          _GlowingOrb(
            top: -50,
            left: -50,
            size: screenWidth * 0.6,
            color: const Color(0xFF00FFA3),
          ),
          _GlowingOrb(
            top: screenHeight * 0.4,
            left: screenWidth * 0.5,
            size: screenWidth * 0.7,
            color: const Color(0xFF00FFA3),
          ),
          _GlowingOrb(
            top: screenHeight * 0.75,
            left: -100,
            size: screenWidth * 0.8,
            color: const Color(0xFF0F3B2E),
          ),

          // Main Scrollable Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeaderSection(),
                    RoleList(roles: viewModel.roles),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _GlowingOrb extends StatefulWidget {
  final double top;
  final double left;
  final double size;
  final Color color;

  const _GlowingOrb({
    required this.top,
    required this.left,
    required this.size,
    required this.color,
  });

  @override
  State<_GlowingOrb> createState() => _GlowingOrbState();
}

class _GlowingOrbState extends State<_GlowingOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final currentSize = widget.size * _animation.value;
          return Container(
            width: currentSize,
            height: currentSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.08 * _animation.value),
                  blurRadius: currentSize * 0.6,
                  spreadRadius: currentSize * 0.15,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
