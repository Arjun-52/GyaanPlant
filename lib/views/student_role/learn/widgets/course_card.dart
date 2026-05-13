import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final int modules;
  final double progress;

  const CourseCard({
    required this.title,
    required this.modules,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF081C0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE + TAG
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "ENROLLED",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "Modules: $modules",
            style: TextStyle(color: Colors.grey.shade400),
          ),

          const SizedBox(height: 12),

          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey.shade800,
            color: Colors.greenAccent,
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
              ),
              child: const Text(
                "Resume Course",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
