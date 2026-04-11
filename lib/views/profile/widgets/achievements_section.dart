import 'package:flutter/material.dart';
import 'achievement_card.dart';

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Achievements",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            AchievementCard(icon: Text("🔥"), title: "14-Day Streak"),
            AchievementCard(icon: Text("🎯"), title: "Mock Master"),
            AchievementCard(icon: Text("🏆"), title: "Top Scorer"),
            AchievementCard(
              icon: Text("🚀"),
              title: "First Job",
              isActive: false,
            ),
            AchievementCard(icon: Text("🏆"), title: "Top 10", isActive: false),
            AchievementCard(
              icon: Text("📈"),
              title: "100-Day",
              isActive: false,
            ),
          ],
        ),
      ],
    );
  }
}
