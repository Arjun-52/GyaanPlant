import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/views/student/widgets/ai_advisor_sheet.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});
  void _showAiAdvisorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AiAdvisorSheet();
      },
    );
  }

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
              borderColor: Colors.green,
              onTap: () {
                context.push('/test');
              },
            ),
            ActionItem(
              "🤖",
              "AI Advisor",
              borderColor: Colors.purple,
              onTap: () {
                _showAiAdvisorSheet(context);
              },
            ),
            const ActionItem("💼", "Jobs", borderColor: Colors.blue),
            const ActionItem("🏆", "Leaderboard", borderColor: Colors.orange),
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
  final Color borderColor;

  const ActionItem(
    this.icon,
    this.label, {
    required this.borderColor,
    this.onTap,
    super.key,
  });

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
              border: Border.all(color: borderColor, width: 0.8),
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
