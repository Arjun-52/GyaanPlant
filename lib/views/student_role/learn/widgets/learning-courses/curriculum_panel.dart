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
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0C241B).withValues(alpha: 0.35),
            const Color(0xFF030D0A).withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.03),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Expandable Header Trigger
          InkWell(
            onTap: onToggleExpand,
            splashColor: const Color(0xFF00FFA3).withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.format_list_bulleted, color: Color(0xFF00FFA3), size: 20),
                      SizedBox(width: 12),
                      Text(
                        "Course Curriculum",
                        style: TextStyle(
                          fontFamily: 'Gilroy-Bold',
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF00FFA3),
                    ),
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
                    // Section Title Header Separator (Glass styled banner)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C241B).withValues(alpha: 0.4),
                        border: Border(
                          top: BorderSide(color: const Color(0xFF00FFA3).withValues(alpha: 0.1), width: 1),
                          bottom: BorderSide(color: const Color(0xFF00FFA3).withValues(alpha: 0.1), width: 1),
                        ),
                      ),
                      child: Text(
                        "SECTION ${section.order}: ${section.title.toUpperCase()}",
                        style: TextStyle(
                          fontFamily: 'Gilroy-Bold',
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // Lessons mapping
                    ...section.lessons.map((lesson) {
                      final bool isSelected = lesson.id == selectedLessonId;

                      return _CurriculumRow(
                        lesson: lesson,
                        isSelected: isSelected,
                        onTap: () => onLessonClick(lesson),
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

class _CurriculumRow extends StatefulWidget {
  final PlayerLesson lesson;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurriculumRow({
    required this.lesson,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CurriculumRow> createState() => _CurriculumRowState();
}

class _CurriculumRowState extends State<_CurriculumRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFF0C241B).withValues(alpha: 0.5)
                : (_isHovered ? const Color(0xFF0C241B).withValues(alpha: 0.15) : Colors.transparent),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.04),
                width: 1,
              ),
              left: BorderSide(
                color: widget.isSelected ? const Color(0xFF00FFA3) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              // Play / Complete Status icon indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: widget.lesson.isCompleted
                      ? const Color(0xFF00FFA3).withValues(alpha: 0.12)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.lesson.isCompleted
                      ? Icons.check_circle
                      : (widget.isSelected ? Icons.play_arrow : Icons.play_arrow_outlined),
                  color: widget.lesson.isCompleted
                      ? const Color(0xFF00FFA3)
                      : (widget.isSelected ? const Color(0xFF00FFA3) : Colors.white30),
                  size: 19,
                ),
              ),
              const SizedBox(width: 14),

              // Lesson title and length
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lesson.title,
                      style: TextStyle(
                        fontFamily: widget.isSelected ? 'Gilroy-Bold' : 'Gilroy-Medium',
                        color: widget.isSelected ? const Color(0xFF00FFA3) : Colors.white70,
                        fontSize: 13.5,
                        fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${widget.lesson.durationMins} mins",
                      style: TextStyle(
                        fontFamily: 'Gilroy-Medium',
                        color: widget.isSelected ? const Color(0xFF00FFA3).withValues(alpha: 0.7) : Colors.white38,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
