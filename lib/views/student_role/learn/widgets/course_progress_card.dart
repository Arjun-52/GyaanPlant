import 'package:flutter/material.dart';

class CourseProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String percentText;
  final String progressCount;
  final double progress;
  final Color progressColor;
  final String? tag;
  final Color? tagColor;

  const CourseProgressCard({
    super.key,
    required this.title,
    required this.tagColor,
    required this.subtitle,
    required this.percentText,
    required this.progressCount,
    required this.progress,
    required this.progressColor,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1F1A), Color(0xFF0A2E25)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Color(0xFF1F5A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row
          Row(
            children: [
              /// Icon Box
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.bar_chart, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),

              /// Title + Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              /// Tag
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (tagColor ?? Colors.white).withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag!,
                    style: TextStyle(
                      fontSize: 10,
                      color: tagColor ?? Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          /// Progress Bar
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Progress bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(progressColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              /// Percentage + count
              Row(
                children: [
                  Text(
                    percentText,
                    style: TextStyle(
                      color: progressColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    progressCount,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              /// Resume Button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Resume →",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
