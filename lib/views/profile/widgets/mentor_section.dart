import 'package:flutter/material.dart';
import 'mentor_card.dart';

class MentorSection extends StatelessWidget {
  const MentorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Alumni Mentors 👨‍🏫",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Find more",
              style: TextStyle(color: Color(0xFF00C853), fontSize: 13),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// Cards
        const MentorCard(
          name: "Rahul Singh",
          role: "SDE-2 @ Amazon",
          year: "2022",
          price: "₹299/30min",
          initials: "RS",
          avatarColor: Colors.green,
        ),

        const MentorCard(
          name: "Priya Menon",
          role: "Analyst @ Deloitte",
          year: "2023",
          price: "₹199/30min",
          initials: "PM",
          avatarColor: Colors.blue,
        ),
      ],
    );
  }
}
