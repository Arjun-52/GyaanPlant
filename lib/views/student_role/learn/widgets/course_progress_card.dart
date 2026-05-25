import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourseProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String percentText;
  final String progressCount;
  final double progress;
  final Color progressColor;
  final String? tag;
  final Color? tagColor;
  final bool isEnrolled;
  final String courseId;
  final String? thumbnail;
  const CourseProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.percentText,
    required this.progressCount,
    required this.progress,
    required this.progressColor,
    required this.courseId,
    required this.isEnrolled,
    this.tag,
    this.tagColor,
    this.thumbnail,
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
        border: Border.all(color: const Color(0xFF1F5A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///  Top Row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 56,
                  height: 56,
                  color: Colors.white10,
                  padding: const EdgeInsets.all(8),
                  child: Image.network(
                    (thumbnail != null && thumbnail!.isNotEmpty)
                        ? thumbnail!
                        : _getCourseImageUrl(title),
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Color(0xFF00C853)),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.menu_book,
                        color: Colors.white38,
                        size: 24,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              /// Title + subtitle
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

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Progress Bar
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

              /// Percentage
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

              GestureDetector(
                onTap: () {
                  if (isEnrolled) {
                    // resume logic
                  } else {
                    context.push('/course-details/${courseId}');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isEnrolled
                        ? const Color(0xFF00C853)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isEnrolled
                        ? null
                        : Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    isEnrolled ? 'Resume →' : 'Details →',
                    style: TextStyle(
                      color: isEnrolled ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCourseImageUrl(String title) {
    final t = title.toLowerCase();
    if (t.contains('javascript') || t.contains('js')) {
      return 'https://img.icons8.com/color/144/javascript--v1.png';
    }
    if (t.contains('flutter') || t.contains('dart')) {
      return 'https://img.icons8.com/color/144/flutter.png';
    }
    if (t.contains('python')) {
      return 'https://img.icons8.com/color/144/python--v1.png';
    }
    if (t.contains('sql') || t.contains('database') || t.contains('db')) {
      return 'https://img.icons8.com/fluency/144/database.png';
    }
    if (t.contains('azure') || t.contains('cloud') || t.contains('aws')) {
      return 'https://img.icons8.com/color/144/azure-1.png';
    }
    if (t.contains('dsa') || t.contains('data structure') || t.contains('algorithm') || t.contains('coding')) {
      return 'https://img.icons8.com/fluency/144/code.png';
    }
    if (t.contains('aptitude') || t.contains('math') || t.contains('quant')) {
      return 'https://img.icons8.com/fluency/144/math.png';
    }
    if (t.contains('verbal') || t.contains('english') || t.contains('communication')) {
      return 'https://img.icons8.com/fluency/144/speech-bubble.png';
    }
    if (t.contains('hr') || t.contains('interview') || t.contains('career')) {
      return 'https://img.icons8.com/color/144/briefcase.png';
    }
    return 'https://img.icons8.com/fluency/144/education.png';
  }
}
