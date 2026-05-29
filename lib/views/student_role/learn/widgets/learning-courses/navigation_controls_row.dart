import 'package:flutter/material.dart';

/// Controls row for traversing backward and forward inside the course lessons.
class NavigationControlsRow extends StatefulWidget {
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
  State<NavigationControlsRow> createState() => _NavigationControlsRowState();
}

class _NavigationControlsRowState extends State<NavigationControlsRow> {
  bool _prevTapped = false;
  bool _nextTapped = false;

  @override
  Widget build(BuildContext context) {
    final bool isFirst = widget.currentIdx == 0;
    final bool isLast = widget.currentIdx == widget.maxCount - 1;

    return Row(
      children: [
        // PREVIOUS BUTTON
        Expanded(
          child: AnimatedScale(
            scale: _prevTapped && !isFirst ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isFirst
                      ? [
                          Colors.white.withValues(alpha: 0.02),
                          Colors.white.withValues(alpha: 0.02),
                        ]
                      : [
                          const Color(0xFF0C241B).withValues(alpha: 0.35),
                          const Color(0xFF030D0A).withValues(alpha: 0.85),
                        ],
                ),
                border: Border.all(
                  color: isFirst
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFF00FFA3).withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isFirst
                        ? Colors.transparent
                        : const Color(0xFF00FFA3).withValues(alpha: 0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isFirst
                        ? null
                        : () async {
                            setState(() => _prevTapped = true);
                            await Future.delayed(const Duration(milliseconds: 100));
                            setState(() => _prevTapped = false);
                            widget.onPrevious();
                          },
                    splashColor: const Color(0xFF00FFA3).withValues(alpha: 0.15),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: isFirst ? Colors.white30 : const Color(0xFF00FFA3),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Previous Lesson",
                            style: TextStyle(
                              fontFamily: 'Gilroy-Bold',
                              color: isFirst ? Colors.white30 : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // NEXT BUTTON
        Expanded(
          child: AnimatedScale(
            scale: _nextTapped && !isLast ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isLast
                      ? [
                          Colors.white.withValues(alpha: 0.02),
                          Colors.white.withValues(alpha: 0.02),
                        ]
                      : [
                          const Color(0xFF00FFA3),
                          const Color(0xFF0C241B),
                        ],
                ),
                border: Border.all(
                  color: isLast
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFF00FFA3).withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isLast
                        ? Colors.transparent
                        : const Color(0xFF00FFA3).withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isLast
                        ? null
                        : () async {
                            setState(() => _nextTapped = true);
                            await Future.delayed(const Duration(milliseconds: 100));
                            setState(() => _nextTapped = false);
                            widget.onNext();
                          },
                    splashColor: const Color(0xFF00FFA3).withValues(alpha: 0.2),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Next Lesson",
                            style: TextStyle(
                              fontFamily: 'Gilroy-Bold',
                              color: isLast ? Colors.white30 : const Color(0xFF030705),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: isLast ? Colors.white30 : const Color(0xFF030705),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
