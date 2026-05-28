import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/student_tab_controller.dart';
import 'package:gyaanplant/views/student_role/learn/screens/course_details_screen.dart';

class ActiveCoursesSection extends StatelessWidget {
  final List enrollments;

  const ActiveCoursesSection({super.key, required this.enrollments});

  @override
  Widget build(BuildContext context) {
    if (enrollments.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            width: double.infinity, // Occupies the whole row width
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF092922), // Sleek deep glass-teal
                  Color(0xFF031612), // Deep black-green
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20), // Premium rounded corners
              border: Border.all(
                color: const Color(0xFF00E676).withOpacity(0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.06),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00E676).withOpacity(0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withOpacity(0.04),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_stories_outlined,
                    size: 32,
                    color: Color(0xFF00E676),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Active Courses Yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Start learning to see your courses here.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.read<StudentTabController>().switchTab(1),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00E676),
                            Color(0xFF00C853),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E676).withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explore Courses',
                            style: TextStyle(
                              color: Color(0xFF031B15), // Deep contrast text
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Color(0xFF031B15),
                          ),
                        ],
                      ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Courses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            InkWell(
              onTap: () => context.read<StudentTabController>().switchTab(1),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'See all',
                      style: TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Color(0xFF00C853),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...enrollments.map((enrollment) => CourseItem(enrollment: enrollment)).toList(),
      ],
    );
  }
}

class CourseItem extends StatelessWidget {
  final dynamic enrollment; // Can be Enrollment or Map for backward compatibility

  const CourseItem({super.key, required this.enrollment});

  String getCourseIcon() {
    // Handle both Enrollment object and Map format
    String title;
    String category;

    if (enrollment is Map<String, dynamic>) {
      final course = enrollment['course'] as Map<String, dynamic>? ?? {};
      title = (course['title'] as String? ?? '').toLowerCase();
      category = (course['category'] as String? ?? '').toLowerCase();
    } else {
      // Enrollment object
      title = enrollment.course.title.toLowerCase();
      category = (enrollment.course.category ?? '').toLowerCase();
    }

    if (category.contains('data') ||
        title.contains('data') ||
        title.contains('algorithm')) {
      return '📊';
    }
    if (category.contains('quant') ||
        title.contains('quant') ||
        title.contains('aptitude')) {
      return '🧮';
    }
    if (category.contains('verbal') ||
        title.contains('verbal') ||
        title.contains('communication')) {
      return '💬';
    }
    if (category.contains('coding') ||
        title.contains('programming') ||
        title.contains('code')) {
      return '💻';
    }
    if (category.contains('hr') || title.contains('interview')) {
      return '👔';
    }
    return '📚';
  }

  Color getIconBgColor() {
    final p = getProgress();
    if (p >= 0.7) {
      return const Color(0xFF00C853).withOpacity(0.12);
    }
    if (p >= 0.4) {
      return const Color(0xFFFFA726).withOpacity(0.12);
    }
    return const Color(0xFFEF5350).withOpacity(0.12);
  }

  Color getProgressColor() {
    final p = getProgress();
    if (p >= 0.7) {
      return const Color(0xFF00C853);
    }
    if (p >= 0.4) {
      return const Color(0xFFFFA726);
    }
    return const Color(0xFFEF5350);
  }

  double getProgress() {
    int progress;
    if (enrollment is Map<String, dynamic>) {
      progress = enrollment['progress'] as int? ?? 0;
    } else {
      // Enrollment object
      progress = enrollment.progress ?? 0;
    }
    return (progress / 100.0).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final iconBg = getIconBgColor();
    final icon = getCourseIcon();

    String title;
    int totalModules;
    int completedModules;

    if (enrollment is Map<String, dynamic>) {
      final course = enrollment['course'] as Map<String, dynamic>? ?? {};
      title = course['title'] as String? ?? 'Unknown Course';
      totalModules = course['totalModules'] as int? ?? 0;
      completedModules = enrollment['completedModules'] as int? ?? 0;
    } else {
      // Enrollment object
      title = enrollment.course.title;
      totalModules = enrollment.course.totalModules;
      completedModules = enrollment.completedModules ?? 0;
    }

    final subtitle = completedModules > 0
        ? '$completedModules/$totalModules modules'
        : '$totalModules modules';
    final progress = getProgress();
    final progressColor = getProgressColor();

    return InkWell(
      onTap: () {
        // Navigate to course details using the course id
        String courseId;
        if (enrollment is Map<String, dynamic>) {
          final course = enrollment['course'] as Map<String, dynamic>? ?? {};
          final idVal = course['_id'] ?? course['id'] ?? '';
          courseId = idVal.toString();
        } else {
          courseId = enrollment.course.id;
        }
        if (courseId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailsScreen(courseId: courseId),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF09241E), // Premium dark-teal card background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1FA463).withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: progressColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                icon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress.isFinite ? (progress * 100).round() : 0)}%',
                        style: TextStyle(
                          color: progressColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF041511),
                      valueColor: AlwaysStoppedAnimation(progressColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
