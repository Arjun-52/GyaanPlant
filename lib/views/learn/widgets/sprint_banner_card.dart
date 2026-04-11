import 'package:flutter/material.dart';

class SprintBannerCard extends StatelessWidget {
  const SprintBannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1F1A), Color(0xFF0A3D2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Color(0xFF1F5A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///  Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: const Text(
              "⚡ 7-Day Sprint",
              style: TextStyle(
                color: Color(0xFF00E676),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// Title
          const Text(
            "TCS Placement Sprint",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          /// Subtitle
          const Text(
            "3 live sessions + unlimited mocks + human resume review",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),

          const SizedBox(height: 16),

          /// Bottom Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.end, // 👈 IMPORTANT
                children: [
                  const Text(
                    "₹799",
                    style: TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      "₹1,999",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ),

              /// Button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  "Enroll Now",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
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
