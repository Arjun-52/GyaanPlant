import 'package:flutter/material.dart';

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
                  StatCard(
                    title: "Total Students",
                    value: "2,847",
                    subtitle: "+312 this month",
                  ),
                  StatCard(
                    title: "Active on LMS",
                    value: "73%",
                    subtitle: "+8% vs last month",
                  ),
                  StatCard(
                    title: "Drive-Ready",
                    value: "847",
                    subtitle: "Score ≥70",
                  ),
                  StatCard(
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

              const ActionCard(
                title: "TCS Drive — Shortlist Due Friday",
                description:
                    "342 eligible. 12 haven't completed aptitude module.",
                buttonText: "Send WhatsApp to 12 students →",
                color: Colors.orange,
              ),
              const SizedBox(height: 12),

              const ActionCard(
                title: "NAAC Q3 Report Ready",
                description: "Q3 placement data auto-compiled.",
                buttonText: "Download Report →",
                color: Colors.blue,
              ),
              const SizedBox(height: 12),

              const ActionCard(
                title: "23 Students Below Score 50",
                description: "Need intervention before next drive.",
                buttonText: "View & Assign Remedial →",
                color: Colors.red,
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0A241D),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Students"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Drives"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}

/// STAT CARD
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2F24), Color(0xFF0A241D)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// ACTION CARD
class ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final Color color;

  const ActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Text(
            buttonText,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
