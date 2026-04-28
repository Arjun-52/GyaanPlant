import 'package:flutter/material.dart';

class SessionHistoryCard extends StatelessWidget {
  final String initials;
  final String name;
  final String date;
  final String duration;
  final String topic;
  final String feedback;
  final Color avatarColor;
  final int rating;

  const SessionHistoryCard({
    super.key,
    required this.initials,
    required this.name,
    required this.date,
    required this.duration,
    required this.topic,
    required this.feedback,
    required this.avatarColor,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        gradient: const LinearGradient(
          colors: [Color(0xFF0F2A20), Color(0xFF0A1F18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///  TOP ROW
          Row(
            children: [
              CircleAvatar(
                backgroundColor: avatarColor,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$date · $duration",
                      style: const TextStyle(color: Colors.white38),
                    ),
                  ],
                ),
              ),

              /// ⭐ stars
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    color: index < rating ? Colors.amber : Colors.grey,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ///  topic
          Text("Topic: $topic", style: const TextStyle(color: Colors.white54)),

          const SizedBox(height: 10),

          ///  feedback box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"$feedback"',
              style: const TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
