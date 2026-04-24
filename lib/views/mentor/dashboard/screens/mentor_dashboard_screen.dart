import 'package:flutter/material.dart';
import 'package:gyaanplant/views/mentor/dashboard/widgets/header_widget.dart';
import 'package:gyaanplant/views/mentor/dashboard/widgets/quick_stats.dart';
import 'package:gyaanplant/views/mentor/dashboard/widgets/session_card.dart';
import 'package:gyaanplant/views/mentor/dashboard/widgets/stat_card.dart';
import 'package:gyaanplant/core/common_widgets/mentor_bottom_nav.dart';

class MentorDashboardScreen extends StatelessWidget {
  const MentorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A0A),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderWidget(),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Sessions",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: Navigate to all bookings screen
                          },
                          child: const Text(
                            "All Bookings",
                            style: TextStyle(
                              color: Color(0xFF00C853),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const SessionCard(
                      initials: "AK",
                      name: "Arjun Kumar",
                      detail: "GRIET · CSE · 2025",
                      time: "3:00 PM today",
                      topic: "Resume review + TCS prep",
                    ),

                    const SizedBox(height: 14),

                    const SessionCard(
                      initials: "SM",
                      name: "Sneha Murthy",
                      detail: "GRIET · IT · 2025",
                      time: "5:30 PM today",
                      topic: "Interview strategy",
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Quick Stats",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: const [
                        Expanded(
                          child: StatBox(
                            "96%",
                            "Acceptance Rate",
                            Colors.green,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: StatBox(
                            "₹400",
                            "Avg Session Rate",
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: const [
                        Expanded(
                          child: StatBox("18", "Sessions", Colors.purple),
                        ),
                        SizedBox(width: 12),
                        Expanded(child: StatBox("3", "Pending", Colors.red)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const TpoBottomNav(currentIndex: 0),
    );
  }
}
