import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final bool isActive;

  const AchievementCard({
    super.key,
    required this.icon,
    required this.title,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0F2A22) : const Color(0xFF0B1F19),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF12352C) : Colors.white10,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DefaultTextStyle.merge(
            style: TextStyle(
              color: isActive ? Colors.orange : Colors.white24,
              fontSize: 26,
            ),
            child: icon,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white70 : Colors.white24,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
