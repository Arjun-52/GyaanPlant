import 'package:flutter/material.dart';

class SessionCard extends StatelessWidget {
  final String initials;
  final String name;
  final String detail;
  final String time;
  final String topic;

  const SessionCard({
    super.key,
    required this.initials,
    required this.name,
    required this.detail,
    required this.time,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        /// 🔥 dark green gradient (important)
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0E2A1F), // deep green
            const Color(0xFF081A14), // darker bottom
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔷 TOP ROW (avatar + name)
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF16C47F),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// 🔷 TIME + TOPIC
          Row(
            children: [
              const Text("⏰", style: TextStyle(fontSize: 14)),

              const SizedBox(width: 6),

              Text(
                time,
                style: const TextStyle(
                  color: Color(0xFFFFB020), // orange
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  topic,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// 🔷 BUTTONS
          Row(
            children: [
              /// JOIN BUTTON
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16C47F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Join Session",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// RESCHEDULE BUTTON
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                    color: Colors.transparent,
                  ),
                  child: const Center(
                    child: Text(
                      "Reschedule",
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w500,
                      ),
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
