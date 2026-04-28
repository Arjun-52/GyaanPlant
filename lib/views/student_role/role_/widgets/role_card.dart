import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/role_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/data/services/local_storage_service.dart';

class RoleCard extends StatelessWidget {
  final RoleModel role;

  const RoleCard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final title = role.title.toLowerCase();
        String selectedRole = 'student';

        if (title.contains('student')) {
          selectedRole = 'student';
        } else if (title.contains('tpo')) {
          selectedRole = 'tpo';
        } else if (title.contains('hod') || title.contains('principal')) {
          selectedRole = 'hod';
        } else if (title.contains('mentor') || title.contains('alumni')) {
          selectedRole = 'mentor';
        }

        await LocalStorageService.saveRole(selectedRole);
        context.go('/');
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2A22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Color(0xFF00C853).withValues(alpha: 0.35),
                ),
              ),
              child: Text(role.icon, style: const TextStyle(fontSize: 20)),
            ),

            const SizedBox(width: 16),

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
