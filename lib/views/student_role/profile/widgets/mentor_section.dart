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
      context.read<MentorViewModel>().fetchMentors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MentorViewModel>(
      builder: (context, vm, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Alumni Mentors 👨‍🏫",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text("Find more", style: TextStyle(color: Color(0xFF00C853))),
              ],
            ),

            const SizedBox(height: 12),

            /// STATES
            if (vm.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (vm.error != null)
              Text("Error: ${vm.error}", style: TextStyle(color: Colors.red))
            else if (vm.mentors.isEmpty)
              const Text(
                "No mentors found",
                style: TextStyle(color: Colors.white),
              )
            else
              Column(
                children: vm.mentors.map((mentor) {
                  return MentorCard(
                    name: mentor.name,
                    role: "${mentor.designation} ${mentor.company}",
                    year: "",

                    // convert rate
                    price: "₹${mentor.rate}/30min",

                    initials: mentor.name.isNotEmpty
                        ? mentor.name.substring(0, 1).toUpperCase()
                        : "?",

                    avatarColor: Colors.green,
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }
}
