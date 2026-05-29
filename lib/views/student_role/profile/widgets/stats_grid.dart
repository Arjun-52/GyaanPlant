import 'package:flutter/material.dart';

class StatsGrid extends StatelessWidget {
  final int readinessScore;
  final int testsCompleted;
  final int hoursLearned;
  final int streak;

  const StatsGrid({
    super.key,
    required this.readinessScore,
    required this.testsCompleted,
    required this.hoursLearned,
    required this.streak,
  });

  Widget box({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      height: 120, // Equal height guaranteed
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B2B23), Color(0xFF02100C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF00E676).withOpacity(0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.02),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Icon(
                icon,
                color: color.withOpacity(0.8),
                size: 16,
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.0,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: box(
                context: context,
                value: "$readinessScore",
                label: "Readiness",
                icon: Icons.bolt_rounded,
                color: const Color(0xFF00E676),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: box(
                context: context,
                value: "$testsCompleted",
                label: "Tests Done",
                icon: Icons.assignment_turned_in_rounded,
                color: const Color(0xFF00E676),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: box(
                context: context,
                value: "$hoursLearned",
                label: "XP Earned",
                icon: Icons.school_rounded,
                color: const Color(0xFF00E676),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: box(
                context: context,
                value: "$streak Days",
                label: "Streak",
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFFFA726),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
