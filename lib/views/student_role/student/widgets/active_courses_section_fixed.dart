import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/student_tab_controller.dart';
import 'package:gyaanplant/views/student_role/learn/screens/course_details_screen.dart';

class ActiveCoursesSectionFixed extends StatelessWidget {
  final List enrollments;

  const ActiveCoursesSectionFixed({super.key, required this.enrollments});

  @override
  Widget build(BuildContext context) {
    if (enrollments.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            decoration: BoxDecoration(
              color: const Color(0xFF071711),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.auto_stories_outlined, size: 36, color: Color(0xFF00E676)),
                const SizedBox(height: 12),
                const Text(
                  'No Active Courses Yet',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Start learning to see your courses here.',
                  style: TextStyle(color: Colors.white60),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => context.read<StudentTabController>().switchTab(1),
                  child: const Text('Explore Courses', style: TextStyle(color: Color(0xFF031B15))),
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
            const Text('Active Courses', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => context.read<StudentTabController>().switchTab(1),
              child: const Row(children: [Text('See all', style: TextStyle(color: Color(0xFF00C853))), SizedBox(width: 6), Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF00C853))]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...enrollments.map((e) => CourseItem(enrollment: e)).toList(),
      ],
    );
  }
}

class CourseItem extends StatelessWidget {
  final dynamic enrollment;

  const CourseItem({super.key, required this.enrollment});

  String _getCourseTitle() {
    if (enrollment is Map) {
      final course = enrollment['course'] ?? {};
      return (course['title'] as String?) ?? 'Untitled Course';
    }
    return enrollment.course.title ?? 'Untitled Course';
  }

  String _getCourseId() {
    if (enrollment is Map) {
      final course = enrollment['course'] ?? {};
      return (course['_id'] ?? course['id'] ?? '').toString();
    }
    return enrollment.course.id ?? '';
  }

  double _getProgress() {
    if (enrollment is Map) return ((enrollment['progress'] as num?) ?? 0) / 100.0;
    return ((enrollment.progress as num?) ?? 0) / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final title = _getCourseTitle();
    final progress = _getProgress().clamp(0.0, 1.0);
    final progressColor = progress >= 0.7 ? Colors.green : (progress >= 0.4 ? Colors.orange : Colors.red);

    return InkWell(
      onTap: () {
        final id = _getCourseId();
        if (id.isNotEmpty) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailsScreen(courseId: id)));
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF07120F), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          CircleAvatar(backgroundColor: Colors.white10, child: Text(title.isNotEmpty ? title[0].toUpperCase() : 'C')),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: progress, minHeight: 6, valueColor: AlwaysStoppedAnimation(progressColor))),
            ]),
          ),
          const SizedBox(width: 12),
          Text('${(progress * 100).round()}%', style: TextStyle(color: progressColor, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
