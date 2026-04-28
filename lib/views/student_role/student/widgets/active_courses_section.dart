import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/student_tab_controller.dart';
import 'package:gyaanplant/models/student_role_models/dashboard_model.dart';

class ActiveCoursesSection extends StatelessWidget {
  final List<Enrollment> enrollments;

  const ActiveCoursesSection({super.key, required this.enrollments});

  @override
  Widget build(BuildContext context) {
    // Empty state
    if (enrollments.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1F1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF1FA463).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.menu_book, size: 40, color: Colors.white38),
                SizedBox(height: 10),
                Text("No active courses yet"),
                SizedBox(height: 6),
                Text("Start learning to see your courses"),

                SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () {
                    context.read<StudentTabController>().switchTab(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    side: const BorderSide(
                      color: Color(0xFF00C853),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    "Explore Courses",
                    style: TextStyle(
                      color: Color(0xFF00C853),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

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
                context.read<StudentTabController>().switchTab(1);
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
        // Course List from API data
        ...enrollments
            .map((enrollment) => CourseItem(enrollment: enrollment)),
      ],
    );
  }
}

class CourseItem extends StatelessWidget {
  final Enrollment enrollment;

  const CourseItem({super.key, required this.enrollment});

  /// Get icon based on course category or title
  String getCourseIcon() {
    final title = enrollment.course.title.toLowerCase();
    final category = enrollment.course.category?.toLowerCase() ?? '';

    if (category.contains('data') ||
        title.contains('data') ||
        title.contains('algorithm')) {
      return '📊';
    } else if (category.contains('quant') ||
        title.contains('quant') ||
        title.contains('aptitude')) {
      return '🧮';
    } else if (category.contains('verbal') ||
        title.contains('verbal') ||
        title.contains('communication')) {
      return '💬';
    } else if (category.contains('coding') ||
        title.contains('programming') ||
        title.contains('code')) {
      return '💻';
    } else if (category.contains('hr') || title.contains('interview')) {
      return '👔';
    } else {
      return '📚';
    }
  }

  /// Get icon background color based on progress
  Color getIconBgColor() {
    final progress = enrollment.progressPercentage;
    if (progress >= 0.7) {
      return const Color(0xFF0F2A22); // Green tint for high progress
    } else if (progress >= 0.4) {
      return const Color(0xFF1A2332); // Blue tint for medium progress
    } else {
      return const Color(0xFF1E1E2F); // Purple tint for low progress
    }
  }

  /// Get progress color based on percentage
  Color getProgressColor() {
    final progress = enrollment.progressPercentage;
    if (progress >= 0.7) {
      return const Color(0xFF00C853); // Green
    } else if (progress >= 0.4) {
      return const Color(0xFFFFA726); // Orange
    } else {
      return const Color(0xFFEF5350); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconBg = getIconBgColor();
    final icon = getCourseIcon();
    final title = enrollment.course.title;
    final subtitle = enrollment.subtitleText;
    final progress = enrollment.progressPercentage;
    final progressColor = getProgressColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  Icon Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),

          const SizedBox(width: 14),

          //  Text + Progress
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

                //  Progress Bar + %
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
