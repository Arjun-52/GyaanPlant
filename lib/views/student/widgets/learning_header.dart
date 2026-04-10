import 'package:flutter/material.dart';

class LearningHeader extends StatelessWidget {
  const LearningHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Learn",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 20,
                  height: 12,
                  child: Stack(
                    children: [
                      _book(const Color(0xFF00C853), 0),
                      _book(const Color(0xFF42A5F5), 6),
                      _book(const Color(0xFFE91E63), 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              "Your personalised curriculum",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _book(Color color, double left) {
    return Positioned(
      left: left,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
