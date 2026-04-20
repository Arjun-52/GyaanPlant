import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/role_viewmodel.dart';
import 'package:go_router/go_router.dart';

class RoleCard extends StatelessWidget {
  final RoleModel role;

  const RoleCard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (role.title.toLowerCase().contains('student')) {
          context.push('/student-dashboard');
        } else if (role.title.toLowerCase().contains('tpo')) {
          context.push('/tpo-dashboard');
        } else if (role.title.toLowerCase().contains('hod') ||
            role.title.toLowerCase().contains('principal')) {
          context.push('/overview');
        }
        // Add other role navigation here as needed
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: Color(0xFF0B2F25), width: 1.2),

          color: const Color(0xFF0A0F0D),
        ),

        child: Row(
          children: [
            //  Icon box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2A22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Color(0xFF00C853).withValues(alpha: 0.35)),
              ),
              child: Text(role.icon, style: const TextStyle(fontSize: 20)),
            ),

            const SizedBox(width: 16),

            //  Text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.subtitle,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward, size: 18, color: Color(0xFFBDBDBD)),
          ],
        ),
      ),
    );
  }
}
