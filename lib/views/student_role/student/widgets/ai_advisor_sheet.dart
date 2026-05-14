import 'package:flutter/material.dart';

class AiAdvisorSheet extends StatelessWidget {
  const AiAdvisorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF071E17),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            /// Title
            const Text(
              "🤖 AI Career Advisor",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            /// BOT CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2A22), Color(0xFF0A1F19)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TOP ROW → Avatar + Name
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF00C853),
                        child: Icon(Icons.android, color: Colors.black),
                      ),
                      const SizedBox(width: 10),

                      const Text(
                        "GyaanBot",
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// DESCRIPTION TEXT
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.white70, height: 1.4),
                      children: [
                        TextSpan(text: "Based on your profile, you're a "),
                        TextSpan(
                          text: "87% match",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text:
                              " for Data Analyst roles at MNCs. Here's your personalised 90-day roadmap:",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ROADMAP CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2A22), Color(0xFF0A1F19)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// ICON (colored card style)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A3A32),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.bar_chart,
                          color: Colors.greenAccent,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// TITLE + SUBTITLE
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Data Analyst",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "TCS · Infosys · Amazon · Flipkart",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// MATCH BADGE (2-line like UI)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00C853).withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              "87%",
                              style: TextStyle(
                                color: Color(0xFF00C853),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "match",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// SKILLS
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      SkillChip("✓ SQL basics", Colors.green),
                      SkillChip("✓ Excel", Colors.green),
                      SkillChip("⚡ Python", Colors.orange),
                      SkillChip("⚡ Power BI", Colors.orange),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// STEPS
                  const RoadmapStep(
                    number: "✓",
                    title: "SQL & Excel Mastery",
                    trailing: "Done",
                    isDone: true,
                  ),
                  RoadmapStep(
                    number: "2",
                    title: "Python for Data Analysis",
                    trailing: "Day 1–30",
                  ),
                  RoadmapStep(
                    number: "3",
                    title: "Power BI Dashboards",
                    trailing: "Day 31–60",
                  ),
                  RoadmapStep(
                    number: "4",
                    title: "Mock interviews + Apply",
                    trailing: "Day 61–90",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Start My Roadmap →",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class SkillChip extends StatelessWidget {
  final String text;
  final Color color;

  const SkillChip(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class RoadmapStep extends StatelessWidget {
  final String number;
  final String title;
  final String trailing;
  final bool isDone;

  const RoadmapStep({
    super.key,
    required this.number,
    required this.title,
    required this.trailing,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          /// Circle
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isDone ? Colors.green : const Color(0xFF00C853),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),

          const SizedBox(width: 10),

          /// Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: isDone ? Colors.white38 : Colors.white),
            ),
          ),

          /// Trailing
          Text(
            trailing,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
