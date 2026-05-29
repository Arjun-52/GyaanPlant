import 'package:flutter/material.dart';

/// Renders a dynamic completion progress indicator.
class ProgressCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final double percent;

  const ProgressCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.percent,
  });

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.trending_up, color: Color(0xFF00FFA3), size: 18),
                  SizedBox(width: 8),
                  Text(
                    "COURSE PROGRESS",
                    style: TextStyle(
                      fontFamily: 'Gilroy-Bold',
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Text(
                "$completedCount of $totalCount completed (${(percent * 100).round()}%)",
                style: const TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  color: Color(0xFF00FFA3),
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Linear Progress bar with beautiful gradient fill and smooth animated transitions
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: percent),
              builder: (context, val, child) {
                return LinearProgressIndicator(
                  value: val,
                  minHeight: 9,
                  backgroundColor: const Color(0xFF0C241B).withValues(alpha: 0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FFA3)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
