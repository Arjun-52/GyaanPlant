import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/department_model.dart';

class DepartmentCard extends StatelessWidget {
  final Department dept;

  const DepartmentCard({super.key, required this.dept});

  Color getColor() {
    if (dept.readiness >= 70) return const Color(0xFF00C853);
    if (dept.readiness >= 55) return const Color(0xFFFFA726);
    return const Color(0xFFFF5252);
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0F3D34),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(dept.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dept.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "HOD: ${dept.hod}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const Text("📊"),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                "Students: ${dept.students}",
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(width: 12),
              Text(
                "Ready: ${dept.readiness}%",
                style: TextStyle(color: color, fontSize: 11),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: dept.readiness / 100,
              minHeight: 6,
              color: color,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}
