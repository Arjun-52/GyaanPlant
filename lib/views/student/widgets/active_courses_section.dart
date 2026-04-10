import 'package:flutter/material.dart';
import 'package:gyaanplant/views/student/screens/learn_screen.dart';

class ActiveCoursesSection extends StatelessWidget {
  const ActiveCoursesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //  Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Active Courses",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LearnScreen()),
                );
              },
              child: const Text(
                "See all →",
                style: TextStyle(
                  color: Color(0xFF00C853),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        // Course List
        const CourseItem(
          iconBg: Color(0xFF0F2A22),
          icon: "📊",
          title: "Data Structures & Algorithms",
          subtitle: "TCS Pattern • 24/35 modules",
          progress: 0.68,
          progressColor: Color(0xFF00C853),
        ),

        CourseItem(
          iconBg: Color(0xFF1A2332),
          icon: "🧮",
          title: "Quantitative Aptitude",
          subtitle: "All Companies • 8/18 modules",
          progress: 0.45,
          progressColor: Color(0xFFFFA726),
        ),

        CourseItem(
          iconBg: Color(0xFF1E1E2F),
          icon: "💬",
          title: "Verbal Communication",
          subtitle: "HR Rounds • 14/20 modules",
          progress: 0.70,
          progressColor: Color(0xFF00C853),
        ),
      ],
    );
  }
}

class CourseItem extends StatelessWidget {
  final Color iconBg;
  final String icon;
  final String title;
  final String subtitle;
  final double progress;
  final Color progressColor;

  const CourseItem({
    super.key,
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Icon Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),

          const SizedBox(width: 14),

          // 🔹 Text + Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),

                const SizedBox(height: 10),

                // 🔹 Progress Bar + %
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFF1A1A1A),
                          valueColor: AlwaysStoppedAnimation(progressColor),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      "${(progress * 100).toInt()}%",
                      style: TextStyle(
                        color: progressColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
