import 'package:flutter/material.dart';
import 'package:gyaanplant/models/learning/player_models.dart';

/// Information block displaying current section, lesson title, and description.
class LessonInfoCard extends StatelessWidget {
  final PlayerSection section;
  final PlayerLesson lesson;
  final bool isCompleted;
  final ValueChanged<bool?> onCheckboxChanged;

  const LessonInfoCard({
    super.key,
    required this.section,
    required this.lesson,
    required this.isCompleted,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F1A), // GyaanPlant card color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1FA463).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section & Status Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF103A2B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Section ${section.order}: ${section.title.toUpperCase()}",
                  style: const TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              // Interactive Complete Status Checkbox
              InkWell(
                onTap: () => onCheckboxChanged(!isCompleted),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Text(
                      isCompleted ? "COMPLETED" : "MARK DONE",
                      style: TextStyle(
                        color: isCompleted ? const Color(0xFF00E676) : Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: Checkbox(
                        value: isCompleted,
                        onChanged: onCheckboxChanged,
                        activeColor: const Color(0xFF00C853),
                        checkColor: Colors.black,
                        side: const BorderSide(color: Colors.white54, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Lesson Title
          Text(
            lesson.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),

          // Divider
          Divider(color: Colors.white.withValues(alpha: 0.08), thickness: 1),
          const SizedBox(height: 8),

          // Lesson Description
          Text(
            lesson.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
