import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  final String initials;
  final String name;
  final String college;
  final String time;
  final String topic;
  final String price;
  final Color avatarColor;

  const BookingCard({
    super.key,
    required this.initials,
    required this.name,
    required this.college,
    required this.time,
    required this.topic,
    required this.price,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        /// 🔥 gradient bg
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
          /// 🔷 TOP ROW
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
                      college,
                      style: const TextStyle(color: Colors.white38),
                    ),
                  ],
                ),
              ),

              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFF16C47F),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ///  TIME AND TOPIC
          Row(
            children: [
              Text(
                "📅 $time",
                style: const TextStyle(
                  color: Color(0xFFFFB020),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  topic,
                  style: const TextStyle(color: Colors.white38),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// 🔷 BUTTONS
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16C47F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Accept",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Center(
                    child: Text(
                      "Decline",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
