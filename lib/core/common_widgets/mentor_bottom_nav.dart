import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MentorBottomNav extends StatelessWidget {
  final int currentIndex;

  const MentorBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/mentor-dashboard');
        break;
      case 1:
        context.go('/mentor-bookings');
        break;
      case 2:
        context.go('/mentor-sessions');
        break;
      case 3:
        context.go('/mentor-earnings');
        break;
      case 4:
        context.go('/mentor-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF020B08),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, 0, "🏠", "Home"),
            _navItem(context, 1, "📅", "Bookings"),
            _navItem(context, 2, "💬", "Sessions"),
            _navItem(context, 3, "💰", "Earnings"),
            _navItem(context, 4, "👤", "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, String emoji, String label) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 22,
              color: isActive ? Colors.white : Colors.white38,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? const Color(0xFF00C853) : Colors.white54,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),

          const SizedBox(height: 4),

          if (isActive)
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF00C853),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
