import 'package:flutter/material.dart';

/// Controls row for traversing backward and forward inside the course lessons.
class NavigationControlsRow extends StatelessWidget {
  final int currentIdx;
  final int maxCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const NavigationControlsRow({
    super.key,
    required this.currentIdx,
    required this.maxCount,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFirst = currentIdx == 0;
    final bool isLast = currentIdx == maxCount - 1;

    return Row(
      children: [
        // PREVIOUS BUTTON
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isFirst ? null : onPrevious,
              icon: Icon(
                Icons.arrow_back,
                size: 16,
                color: isFirst ? Colors.white24 : Colors.black,
              ),
              label: Text(
                "Previous Lesson",
                style: TextStyle(
                  color: isFirst ? Colors.white24 : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // NEXT BUTTON
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLast ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Next Lesson",
                    style: TextStyle(
                      color: isLast ? Colors.white24 : Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: isLast ? Colors.white24 : Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
