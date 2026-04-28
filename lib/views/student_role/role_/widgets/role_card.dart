import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/role_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/services/student_services/local_storage_service.dart';

class RoleCard extends StatelessWidget {
  final RoleModel role;

  const RoleCard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        print("🔍 ROLE TAPPED: ${role.title}");
        print("🔍 LOWERCASE: ${role.title.toLowerCase()}");

        // Save role and navigate to sign-in
        String selectedRole = 'student'; // default

        if (role.title.toLowerCase().contains('student')) {
          selectedRole = 'student';
        } else if (role.title.toLowerCase().contains('tpo')) {
          selectedRole = 'tpo';
        } else if (role.title.toLowerCase().contains('hod') ||
            role.title.toLowerCase().contains('principal')) {
          selectedRole = 'hod';
        } else if (role.title.toLowerCase().contains('mentor') ||
            role.title.toLowerCase().contains('alumni')) {
          selectedRole = 'mentor';
        }

        // Save role to local storage
        await LocalStorageService.saveRole(selectedRole);
        print("💾 ROLE SAVED: $selectedRole");

        // Navigate to sign-in screen
        print("🚀 NAVIGATING TO: /");
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
            //  Icon box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2A22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Color(0xFF00C853).withOpacity(0.35)),
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
