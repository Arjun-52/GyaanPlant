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
                color: const Color(0xFF00E676).withValues(alpha: 0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
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
                    color: const Color(0xFF00E676).withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withValues(alpha: 0.04),
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
                            color: const Color(0xFF00E676).withValues(alpha: 0.25),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
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
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_right_rounded,
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

class CourseItem extends StatefulWidget {
  final dynamic enrollment;

  const CourseItem({super.key, required this.enrollment});

  @override
  State<CourseItem> createState() => _CourseItemState();
}

class _CourseItemState extends State<CourseItem> {
  bool _isPressed = false;

  String getCourseIcon() {
    String title;
    String category;

    if (widget.enrollment is Map<String, dynamic>) {
      final course = widget.enrollment['course'] as Map<String, dynamic>? ?? {};
      title = (course['title'] as String? ?? '').toLowerCase();
      category = (course['category'] as String? ?? '').toLowerCase();
    } else {
      title = widget.enrollment.course.title.toLowerCase();
      category = (widget.enrollment.course.category ?? '').toLowerCase();
    }

    if (category.contains('data') || title.contains('data') || title.contains('algorithm')) {
      return '📊';
    }
    if (category.contains('quant') || title.contains('quant') || title.contains('aptitude')) {
      return '🧮';
    }
    if (category.contains('verbal') || title.contains('verbal') || title.contains('communication')) {
      return '💬';
    }
    if (category.contains('coding') || title.contains('programming') || title.contains('code')) {
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
      return const Color(0xFF00C853).withValues(alpha: 0.1);
    }
    if (p >= 0.4) {
      return const Color(0xFFFFA726).withValues(alpha: 0.1);
    }
    return const Color(0xFFEF5350).withValues(alpha: 0.1);
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
    if (widget.enrollment is Map<String, dynamic>) {
      progress = widget.enrollment['progress'] as int? ?? 0;
    } else {
      progress = widget.enrollment.progress ?? 0;
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

    if (widget.enrollment is Map<String, dynamic>) {
      final course = widget.enrollment['course'] as Map<String, dynamic>? ?? {};
      title = course['title'] as String? ?? 'Unknown Course';
      totalModules = course['totalModules'] as int? ?? 0;
      completedModules = widget.enrollment['completedModules'] as int? ?? 0;
    } else {
      title = widget.enrollment.course.title;
      totalModules = widget.enrollment.course.totalModules;
      completedModules = widget.enrollment.completedModules ?? 0;
    }

    final subtitle = completedModules > 0
        ? '$completedModules/$totalModules modules'
        : '$totalModules modules';
    final progress = getProgress();
    final progressColor = getProgressColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        String courseId;
        if (widget.enrollment is Map<String, dynamic>) {
          final course = widget.enrollment['course'] as Map<String, dynamic>? ?? {};
          final idVal = course['_id'] ?? course['id'] ?? '';
          courseId = idVal.toString();
        } else {
          courseId = widget.enrollment.course.id;
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
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _isPressed ? 0.98 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF0C251F), Color(0xFF02110D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFF00E676).withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Glowing icon block
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: progressColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 16),
              // Middle details
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
                              letterSpacing: 0.1,
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
                            shadows: [
                              Shadow(
                                color: progressColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
              const SizedBox(width: 12),
              // Play/Continue learning Chevron
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: progressColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: progressColor,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
