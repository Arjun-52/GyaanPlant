import "package:flutter/material.dart";

class PodiumUser extends StatelessWidget {
  final String initials;
  final String name;
  final String score;
  final int rank;

  const PodiumUser(
    this.initials,
    this.name,
    this.score,
    this.rank, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final height = rank == 1 ? 70.0 : 50.0;
    final color = rank == 1
        ? Colors.amber
        : rank == 2
        ? Colors.grey
        : Colors.orange;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        /// AVATAR
        Stack(
          alignment: Alignment.topCenter,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 28 : 24,
              backgroundColor: color,
              child: Text(
                initials,
                style: const TextStyle(color: Colors.black),
              ),
            ),

            if (rank == 1)
              const Positioned(
                top: -10,
                child: Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              ),
          ],
        ),

        const SizedBox(height: 6),

        Text(name, style: const TextStyle(color: Colors.white)),
        Text(score, style: const TextStyle(color: Color(0xFF00C853))),

        const SizedBox(height: 8),

        /// PODIUM BLOCK
        Container(
          width: 60,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.6), color.withOpacity(0.2)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "$rank",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
