import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ActionItem(
              "🎯",
              "Mock Test",
              onTap: () {
                context.push('/test');
              },
            ),
            const ActionItem("🤖", "AI Advisor"),
            const ActionItem("💼", "Jobs"),
            const ActionItem("🏆", "Leaderboard"),
          ],
        ),
      ],
    );
  }
}

class ActionItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const ActionItem(this.icon, this.label, {this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2A22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(icon),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
