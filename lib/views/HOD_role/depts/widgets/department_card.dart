import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/department_model.dart';
import 'package:go_router/go_router.dart';

class DepartmentCard extends StatelessWidget {
  final Department dept;

  const DepartmentCard({super.key, required this.dept});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to department details screen using the department ID
        // Ensure the ID is non‑empty; fallback to empty string if missing
        final id = dept.id.isNotEmpty ? dept.id : '';
        context.push('/department/$id');
      },
      child: Container(
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
                        dept.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dept.code?.toUpperCase() ?? "-",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "HOD: ${dept.head?.name ?? "No HOD Assigned"}",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Institution: ${dept.college?.name ?? "Unknown College"}",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const Text("🏢"),
              ],
            ),

            const SizedBox(height: 10),

            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white54, size: 12),
                SizedBox(width: 4),
                Text(
                  "Department Information",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.business, color: Colors.white38, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Department details available in admin panel",
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
