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
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 6),
                const Text("📚", style: TextStyle(fontSize: 20)),
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
}
