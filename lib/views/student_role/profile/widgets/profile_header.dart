import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/student_viewmodel/auth_viewmodel.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    final name = vm.user?['name'] ?? 'No Name';
    final email = vm.user?['email'] ?? '';

    // 🔥 Get initials dynamically
    String initials = "NA";
    if (name.isNotEmpty) {
      final parts = name.split(" ");
      initials = parts.length > 1
          ? "${parts[0][0]}${parts[1][0]}"
          : parts[0][0];
    }

    return Column(
      children: [
        // Avatar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0A241D),
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00C853), width: 2),
            ),
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00C853),
              ),
              alignment: Alignment.center,
              child: Text(
                initials, // 🔥 dynamic initials
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 🔥 NAME (DYNAMIC)
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        // 🔥 EMAIL (DYNAMIC)
        Text(
          email,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),

        const SizedBox(height: 12),

        // Chips row (static for now)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chip("🏆 Rank #47", Colors.green),
            const SizedBox(width: 8),
            _chip("🔥 14-day streak", Colors.orange),
            const SizedBox(width: 8),
            _chip("📘 3 certs", Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
