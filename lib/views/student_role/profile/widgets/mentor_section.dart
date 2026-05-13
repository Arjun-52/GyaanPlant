import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/mentor_viewmodel.dart';
import 'package:provider/provider.dart';
import 'mentor_card.dart';

class MentorSection extends StatefulWidget {
  const MentorSection({super.key});

  @override
  State<MentorSection> createState() => _MentorSectionState();
}

class _MentorSectionState extends State<MentorSection> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) context.read<MentorViewModel>().fetchMentors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MentorViewModel>(
      builder: (context, vm, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
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
                  style: TextStyle(
                    color: Color(0xFF00C853),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            /// STATES
            if (vm.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (vm.error != null)
              Text(
                "Error: ${vm.error}",
                style: const TextStyle(color: Colors.red),
              )
            else if (vm.mentors.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFF06271E),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.groups_rounded, color: Colors.white38, size: 42),

                    SizedBox(height: 12),

                    Text(
                      "No mentors available yet",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: vm.mentors.map((mentor) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: MentorCard(
                      name: mentor.name,

                      /// EXPERTISE / ROLE
                      role: "${mentor.designation} ${mentor.company}".trim(),

                      /// EXPERIENCE
                      year: "New Mentor",

                      /// PRICE
                      price: "₹${mentor.rate}/hr",

                      /// INITIALS
                      initials: mentor.name.isNotEmpty
                          ? mentor.name.substring(0, 2).toUpperCase()
                          : "?",

                      avatarColor: Colors.green,
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }
}
