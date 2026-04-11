import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔹 Left Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Good morning 👋",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 4),

              // 🔥 Name with 2 colors
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Arjun ",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: "Kumar",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00C853),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "TCS drive in ",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    TextSpan(
                      text: "12 days",
                      style: TextStyle(
                        color: Color(0xFFFFA726),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 🔹 Right Side
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F2A22),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: const [
                    Icon(Icons.notifications, color: Colors.white, size: 18),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF00C853),
                child: Text(
                  "AK",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
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
