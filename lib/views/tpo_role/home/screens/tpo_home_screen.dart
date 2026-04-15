import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/tpo_bottom_nav.dart';
import 'package:gyaanplant/views/tpo_role/home/widgets/dashboard_action_card.dart';
import 'package:gyaanplant/views/tpo_role/home/widgets/dashboard_stat_card.dart';

class TPODashboard extends StatelessWidget {
  const TPODashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Good morning, TPO 👋",
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 6),
              const Text(
                "GRIET Hyderabad",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              /// STATS GRID
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: const [
                  DashboardStatCard(
                    title: "Total Students",
                    value: "2,847",
                    subtitle: "+312 this month",
                  ),
                  DashboardStatCard(
                    title: "Active on LMS",
                    value: "73%",
                    subtitle: "+8% vs last month",
                  ),
                  DashboardStatCard(
                    title: "Drive-Ready",
                    value: "847",
                    subtitle: "Score ≥70",
                  ),
                  DashboardStatCard(
                    title: "Active Drives",
                    value: "12",
                    subtitle: "3 closing this week",
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                "⚠ Action Required",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              DashboardActionCard(
                title: "TCS Drive — Shortlist Due Friday",
                description:
                    "342 eligible. 12 haven't completed aptitude module.",
                buttonText: "Send WhatsApp to 12 students →",
                color: Colors.orange,
                icon: "🔔",
              ),
              const SizedBox(height: 12),
              DashboardActionCard(
                title: "NAAC Q3 Report Ready",
                description:
                    "Q3 placement data auto-compiled. Review and download.",
                buttonText: "Download Report →",
                color: Colors.blue,
                icon: "📄",
              ),

              const SizedBox(height: 12),
              DashboardActionCard(
                title: "23 Students Below Score 50",
                description:
                    "These students need intervention before next drive cycle.",
                buttonText: "View & Assign Remedial →",
                color: Colors.red,
                icon: "⚡",
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Student Readiness — Top 5",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("See all", style: TextStyle(color: Colors.green)),
                ],
              ),
            ],
          ),
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: const TpoBottomNav(currentIndex: 0),
    );
  }
}
