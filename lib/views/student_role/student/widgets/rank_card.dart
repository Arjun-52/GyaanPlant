import "package:flutter/material.dart";

class RankCard extends StatelessWidget {
  final int rank;
  final String initials;
  final String name;
  final String college;
  final String score;
  final bool highlight;

  const RankCard(
    this.rank,
    this.initials,
    this.name,
    this.college,
    this.score, {
    this.highlight = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2A22), Color(0xFF0A1F19)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? const Color(0xFF00C853)
              : Colors.green.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          /// RANK
          Text("$rank", style: const TextStyle(color: Colors.white54)),

          const SizedBox(width: 10),

          /// AVATAR
          CircleAvatar(backgroundColor: Colors.blue, child: Text(initials)),

          const SizedBox(width: 10),

          /// NAME + COLLEGE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white)),
                Text(
                  college,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),

          /// SCORE
          Text(
            score,
            style: const TextStyle(
              color: Color(0xFF00C853),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
