import 'package:flutter/material.dart';
import 'package:gyaanplant/models/learning/player_models.dart';

/// Expandable Syllabus block containing all sections and lessons.
class CurriculumPanel extends StatelessWidget {
  final PlayerCourse course;
  final String selectedLessonId;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final ValueChanged<PlayerLesson> onLessonClick;

  const CurriculumPanel({
    super.key,
    required this.course,
    required this.selectedLessonId,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onLessonClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1FA463).withValues(alpha: 0.15),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Expandable Header Trigger
          InkWell(
            onTap: onToggleExpand,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_list_bulleted, color: Color(0xFF00E676), size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        "Course Curriculum",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),

          // Dynamic Lesson Trees
          if (isExpanded)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: course.sections.length,
              itemBuilder: (context, index) {
                final section = course.sections[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title Header Separator
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      color: const Color(0xFF0D251F),
                      child: Text(
                        "SECTION ${section.order}: ${section.title.toUpperCase()}",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // Lessons mapping
                    ...section.lessons.map((lesson) {
                      final bool isSelected = lesson.id == selectedLessonId;

                      return InkWell(
                        onTap: () => onLessonClick(lesson),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0F362A) // Green accent highlights active selection
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withValues(alpha: 0.04),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Play / Complete Status icon indicator
                              Icon(
                                lesson.isCompleted
                                    ? Icons.check_circle
                                    : (isSelected ? Icons.play_arrow : Icons.play_arrow_outlined),
                                color: lesson.isCompleted
                                    ? const Color(0xFF00E676)
                                    : (isSelected ? const Color(0xFF00E676) : Colors.white30),
                                size: 18,
                              ),
                              const SizedBox(width: 12),

                              // Lesson title and length
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lesson.title,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white70,
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${lesson.durationMins} mins",
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFF00E676) : Colors.white38,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
