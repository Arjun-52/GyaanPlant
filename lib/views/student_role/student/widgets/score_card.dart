import 'package:flutter/material.dart';

class SkillTextInline extends StatelessWidget {
  final String label;
  final String value;

  const SkillTextInline(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E3A2F), Color(0xFF041A14)],
        ),

        border: Border.all(color: const Color(0xFF1FA463), width: 1.2),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  "AI PLACEMENT READINESS SCORE",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2A22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF1FA463)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 12,
                      color: Color(0xFF00C853),
                    ),
                    SizedBox(width: 4),
                    Text(
                      "+8 this week",
                      style: TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "71",
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00C853),
                  height: 1,
                ),
              ),
              SizedBox(width: 6),
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  "/100",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: List.generate(
              10,
              (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: index < 7
                        ? const Color(0xFF00C853)
                        : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Bottom stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkillTextInline("Aptitude", "82%"),
              SkillTextInline("Coding", "64%"),
              SkillTextInline("HR", "68%"),
            ],
          ),
        ],
      ),
    );
  }
}
