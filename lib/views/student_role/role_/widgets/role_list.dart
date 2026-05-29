import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/role_viewmodel.dart';

import 'role_card.dart';

class RoleList extends StatelessWidget {
  final List<RoleModel> roles;

  const RoleList({super.key, required this.roles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...roles.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final role = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 20), // Increased spacing between cards
              child: _StaggeredTransition(
                index: index,
                child: RoleCard(role: role),
              ),
            );
          },
        ),
        
        // Premium Bottom Section Text
        const SizedBox(height: 20),
        const _StaggeredTransition(
          index: 4, // Shows up last after all cards are loaded
          child: Center(
            child: Text(
              "Select a role to continue",
              style: TextStyle(
                fontFamily: 'Gilroy-Medium',
                fontSize: 14,
                color: Colors.white54,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StaggeredTransition extends StatefulWidget {
  final Widget child;
  final int index;

  const _StaggeredTransition({required this.child, required this.index});

  @override
  State<_StaggeredTransition> createState() => _StaggeredTransitionState();
}

class _StaggeredTransitionState extends State<_StaggeredTransition> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Stagger sequential entry animations
    Future.delayed(Duration(milliseconds: 400 + widget.index * 120), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}
