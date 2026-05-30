import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/student_tab_controller.dart';

class AiAdvisorSheet extends StatefulWidget {
  const AiAdvisorSheet({super.key});

  @override
  State<AiAdvisorSheet> createState() => _AiAdvisorSheetState();
}

class _AiAdvisorSheetState extends State<AiAdvisorSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF020B08).withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: const Color(0xFF00E676).withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E676).withOpacity(0.05),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Premium Drag Handle
              Center(
                child: Container(
                  width: 46,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              /// Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: Color(0xFF00E676),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "AI Career Advisor",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// GyaanBot Card (Premium AI Card)
              ScaleTransition(
                scale: _scaleAnimation,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C241B).withOpacity(0.45),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF00E676).withOpacity(0.15),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Glowing Bot Avatar
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00E676).withOpacity(0.1),
                            border: Border.all(
                              color: const Color(0xFF00E676).withOpacity(0.3),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E676).withOpacity(0.15),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: Color(0xFF00E676),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "GyaanBot",
                                style: TextStyle(
                                  color: Color(0xFF00E676),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    height: 1.4,
                                    fontSize: 13,
                                  ),
                                  children: const [
                                    TextSpan(text: "Based on your profile, you're a "),
                                    TextSpan(
                                      text: "87% match",
                                      style: TextStyle(
                                        color: Color(0xFF00E676),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " for Data Analyst roles at MNCs. Here's your personalised 90-day roadmap:",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ROADMAP CARD (Premium Glass Container)
              ScaleTransition(
                scale: _scaleAnimation,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1410).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF00E676).withOpacity(0.12),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// Career Icon Container
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF00E676).withOpacity(0.2),
                                  width: 1.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.bar_chart_rounded,
                                color: Colors.greenAccent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),

                            /// TITLE + SUBTITLE
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Data Analyst",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "TCS · Infosys · Amazon · Flipkart",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Large Glowing circular progress ring
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00E676).withOpacity(0.05),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: 0.87,
                                    backgroundColor: const Color(0xFF00E676).withOpacity(0.1),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                                    strokeWidth: 3.5,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "87%",
                                        style: TextStyle(
                                          color: Color(0xFF00E676),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "match",
                                        style: TextStyle(
                                          color: Colors.white30,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

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

                        const SizedBox(height: 24),

                        /// Vertical Roadmap Steps Timeline
                        Stack(
                          children: [
                            Positioned(
                              left: 17,
                              top: 24,
                              bottom: 24,
                              child: Container(
                                width: 2,
                                color: const Color(0xFF00E676).withOpacity(0.2),
                              ),
                            ),
                            Column(
                              children: const [
                                RoadmapStep(
                                  number: "✓",
                                  title: "SQL & Excel Mastery",
                                  trailing: "Done",
                                  isDone: true,
                                  isActive: false,
                                ),
                                RoadmapStep(
                                  number: "2",
                                  title: "Python for Data Analysis",
                                  trailing: "Day 1–30",
                                  isDone: false,
                                  isActive: true,
                                ),
                                RoadmapStep(
                                  number: "3",
                                  title: "Power BI Dashboards",
                                  trailing: "Day 31–60",
                                  isDone: false,
                                  isActive: false,
                                ),
                                RoadmapStep(
                                  number: "4",
                                  title: "Mock interviews + Apply",
                                  trailing: "Day 61–90",
                                  isDone: false,
                                  isActive: false,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// START MY ROADMAP BUTTON (Gradient CTA)
              ScaleTransition(
                scale: _scaleAnimation,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.35),
                          blurRadius: 16,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<StudentTabController>().switchTab(1);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.rocket_launch_rounded,
                            color: Color(0xFF031B15),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Start My Roadmap",
                            style: TextStyle(
                              color: Color(0xFF031B15),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
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
  final bool isActive;

  const RoadmapStep({
    super.key,
    required this.number,
    required this.title,
    required this.trailing,
    this.isDone = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = isDone
        ? const Color(0xFF00E676)
        : (isActive ? const Color(0xFF00E676) : Colors.white24);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          /// Connected Step Circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFF00E676).withOpacity(0.15)
                  : (isActive ? const Color(0xFF00E676) : const Color(0xFF1A1A1A).withOpacity(0.4)),
              shape: BoxShape.circle,
              border: Border.all(
                color: ringColor,
                width: 1.5,
              ),
              boxShadow: [
                if (isActive)
                  BoxShadow(
                    color: const Color(0xFF00E676).withOpacity(0.2),
                    blurRadius: 8,
                  ),
              ],
            ),
            alignment: Alignment.center,
            child: isDone
                ? const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF00E676),
                    size: 16,
                  )
                : Text(
                    number,
                    style: TextStyle(
                      color: isActive ? const Color(0xFF031B15) : Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          const SizedBox(width: 14),

          /// Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDone
                    ? Colors.white38
                    : (isActive ? Colors.white : Colors.white70),
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),

          /// Trailing Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFF00E676).withOpacity(0.08)
                  : (isActive ? const Color(0xFF00E676).withOpacity(0.12) : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trailing,
              style: TextStyle(
                color: isDone
                    ? const Color(0xFF00E676).withOpacity(0.6)
                    : (isActive ? const Color(0xFF00E676) : Colors.white38),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

