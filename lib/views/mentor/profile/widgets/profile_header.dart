import 'package:flutter/material.dart';
import 'package:gyaanplant/models/mentor_models/mentor_profile_model.dart';

class ProfileHeader extends StatelessWidget {
  final Mentor mentor;

  const ProfileHeader({super.key, required this.mentor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.green,
          child: Text("RS", style: TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 10),
        Text(
          mentor.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(mentor.role, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            chip("⭐ ${mentor.rating} Rating"),
            chip("📅 ${mentor.sessions} Sessions"),
            chip("🏆 Top Mentor"),
          ],
        ),
      ],
    );
  }

  Widget chip(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.green.withOpacity(0.2),
      ),
      child: Text(text, style: TextStyle(color: Colors.green)),
    );
  }
}
