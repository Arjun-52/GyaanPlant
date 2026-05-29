import 'package:flutter/material.dart';
import 'package:gyaanplant/models/learning/player_models.dart';

/// Information block displaying current section, lesson title, and description.
class LessonInfoCard extends StatefulWidget {
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
  State<LessonInfoCard> createState() => _LessonInfoCardState();
}

class _LessonInfoCardState extends State<LessonInfoCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section & Completion Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Modern Section Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFA3).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  "SEC ${widget.section.order}: ${widget.section.title.toUpperCase()}",
                  style: const TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    color: Color(0xFF00FFA3),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              // Interactive Premium Completion Toggle
              GestureDetector(
                onTapDown: (_) => _animController.forward(),
                onTapUp: (_) => _animController.reverse(),
                onTapCancel: () => _animController.reverse(),
                onTap: () => widget.onCheckboxChanged(!widget.isCompleted),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.isCompleted
                          ? const Color(0xFF00FFA3)
                          : const Color(0xFF0C241B).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: widget.isCompleted
                            ? const Color(0xFF00FFA3)
                            : const Color(0xFF00FFA3).withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.isCompleted
                              ? const Color(0xFF00FFA3).withValues(alpha: 0.35)
                              : Colors.transparent,
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontFamily: 'Gilroy-Bold',
                            color: widget.isCompleted ? const Color(0xFF030705) : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                          child: Text(widget.isCompleted ? "COMPLETED" : "MARK DONE"),
                        ),
                        const SizedBox(width: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            color: widget.isCompleted ? const Color(0xFF030705) : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.isCompleted
                                  ? const Color(0xFF030705)
                                  : Colors.white.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            color: widget.isCompleted ? const Color(0xFF00FFA3) : Colors.transparent,
                            size: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 18),

          // Lesson Title
          Text(
            widget.lesson.title,
            style: const TextStyle(
              fontFamily: 'Gilroy-Bold',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          
          const SizedBox(height: 8),

          // Divider
          Divider(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.1),
            thickness: 1.2,
          ),
          const SizedBox(height: 8),

          // Lesson Description
          Text(
            widget.lesson.description,
            style: TextStyle(
              fontFamily: 'Gilroy-Medium',
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
