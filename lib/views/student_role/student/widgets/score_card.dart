import 'package:flutter/material.dart';

class SkillTextInline extends StatelessWidget {
  final String label;
  final String value;
  final int xp;
  final int rank;
  final int progress;
  const SkillTextInline(
    this.label,
    this.value, {
    super.key,
    required this.xp,
    required this.rank,
    required this.progress,
  });

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
  final int xp;
  final int rank;
  final int progress;

  const ScoreCard({
    super.key,
    required this.xp,
    required this.rank,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final score = progress; // map this properly later

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0E3A2F), Color(0xFF041A14)],
        ),
        border: Border.all(color: const Color(0xFF1FA463), width: 1.2),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP
          Row(
            children: [
              const Expanded(
                child: Text(
                  "AI PLACEMENT READINESS SCORE",
                  style: TextStyle(color: Colors.white54, fontSize: 11.5),
                ),
              ),

              Text(
                "Rank #$rank",
                style: const TextStyle(
                  color: Color(0xFF00C853),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// SCORE
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$score",
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00C853),
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  "/100",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// PROGRESS BAR
          Row(
            children: List.generate(
              10,
              (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: index < (score ~/ 10)
                        ? const Color(0xFF00C853)
                        : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// XP
          Text(
            "XP: $xp",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
