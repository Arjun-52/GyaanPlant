import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class BadgeCard extends StatelessWidget {
  const BadgeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B2B23), Color(0xFF02100C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF00E676).withOpacity(0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.04),
            blurRadius: 24,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0x1F00E676),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00E676).withOpacity(0.1),
              ),
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Color(0xFF00E676),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          // Texts
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Share GyaanPlant Badge",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Let recruiters discover your profile",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Share Button
          GestureDetector(
            onTap: () {
              SharePlus.instance.share(
                ShareParams(
                  text:
                      "Check out my GyaanPlant profile!\n\n"
                      "https://gyaanplant.com/profile/arjun",
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00C853)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Share",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.ios_share_rounded,
                    size: 13,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
