import 'package:flutter/material.dart';

class DeptProgressCard extends StatelessWidget {
  final List<dynamic> departments;

  const DeptProgressCard({super.key, required this.departments});

  Color getColor(int value) {
    if (value >= 70) return const Color(0xFF00C853);
    if (value >= 55) return const Color(0xFFFFA726);
    return const Color(0xFFFF5252);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(20),

        color: const Color(0xFF0F3D34),
      ),

      child: Column(
        children: departments.map((dept) {
          final color = getColor(dept.percent);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                ///DEPT NAME
                SizedBox(
                  width: 50,
                  child: Text(
                    dept.name,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ///  PROGRESS BAR
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: dept.percent / 100,
                      minHeight: 8,
                      color: color,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                ///  PERCENT
                Text(
                  "${dept.percent}%",
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
