import 'package:flutter/material.dart';

class TopStudentsCard extends StatelessWidget {
  final List<Map<String, dynamic>> students;

  const TopStudentsCard({super.key, required this.students});

  Color getColor(int score) {
    if (score >= 85) return const Color(0xFF00C853);
    if (score >= 75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3B2E), Color(0xFF071E17)],
        ),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
      ),

      child: Column(
        children: students.map((student) {
          final score = student['score'];
          final color = getColor(score);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                /// NAME
                Expanded(
                  child: Text(
                    student['name'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                /// PROGRESS BAR
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      minHeight: 6,
                      color: color,
                      backgroundColor: Colors.white10,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// SCORE
                Text("$score", style: const TextStyle(color: Colors.white)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
