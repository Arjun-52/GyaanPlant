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
    print("🔥 DEPT DATA: $departments");

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0F3D34),
      ),
      child: Column(
        children: departments.map((dept) {
          // ✅ FIX: read from Map correctly
          final percent = (dept['percent'] ?? 0) as num;
          final name = dept['name'] ?? "N/A";

          final int percentInt = percent.isFinite ? percent.round() : 0;
          final color = getColor(percentInt);

          double progress = percent.isFinite ? percent / 100 : 0;

          if (progress == 0) progress = 0.3;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.white.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                SizedBox(
                  width: 35,
                  child: Text(
                    "${percentInt}%",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
