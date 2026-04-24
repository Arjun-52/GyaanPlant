import 'package:flutter/material.dart';
import 'package:gyaanplant/views/mentor/sessions/widgets/session_history_card.dart';
import 'package:gyaanplant/views/mentor/sessions/widgets/sessions_header.dart';
import 'package:gyaanplant/core/common_widgets/mentor_bottom_nav.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A0A),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SessionsHeader(),
              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  children: const [
                    SessionHistoryCard(
                      initials: "AK",
                      name: "Arjun Kumar",
                      date: "Mar 10, 2026",
                      duration: "32 min",
                      topic: "TCS prep strategy",
                      feedback: "Very insightful! Helped me crack TCS mock.",
                      avatarColor: Colors.green,
                    ),

                    SizedBox(height: 14),

                    SessionHistoryCard(
                      initials: "SM",
                      name: "Sneha Murthy",
                      date: "Mar 8, 2026",
                      duration: "28 min",
                      topic: "Resume review",
                      feedback:
                          "Great resume tips, got shortlisted by Infosys!",
                      avatarColor: Colors.blue,
                    ),

                    SizedBox(height: 14),

                    SessionHistoryCard(
                      initials: "RT",
                      name: "Ravi Teja",
                      date: "Mar 5, 2026",
                      duration: "35 min",
                      topic: "Career guidance",
                      feedback: "Really helpful career path advice.",
                      avatarColor: Colors.orange,
                    ),

                    SizedBox(height: 14),

                    SessionHistoryCard(
                      initials: "PG",
                      name: "Pooja Gupta",
                      date: "Feb 28, 2026",
                      duration: "30 min",
                      topic: "Aptitude weakness",
                      feedback: "My aptitude score went from 52 to 74!",
                      avatarColor: Colors.teal,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const TpoBottomNav(currentIndex: 2),
    );
  }
}
