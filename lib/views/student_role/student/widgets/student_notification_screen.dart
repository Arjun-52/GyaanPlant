import 'package:flutter/material.dart';

class StudentNotificationScreen extends StatelessWidget {
  const StudentNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06130F), // dark greenish bg
      appBar: AppBar(
        backgroundColor: const Color(0xFF06130F),
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "MARK ALL",
              style: TextStyle(
                color: Color(0xFF00E676), // neon green
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Subtitle
            const Text(
              "0 new alerts require your attention",
              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 20),

            /// Notifications list
            Expanded(child: ListView(children: const [NotificationCard()])),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),

        /// 🔥 Gradient like your design
        gradient: const LinearGradient(
          colors: [Color(0xFF0B2A1E), Color(0xFF0F3D2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        /// Glow effect
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Icon with glow
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E676).withOpacity(0.15),
            ),
            child: const Icon(
              Icons.celebration,
              color: Color(0xFF00E676),
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          /// Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "🎉 Level Up! You are now Explorer",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Congratulations! You reached Level 2. Keep going!",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 10),

                Row(
                  children: const [
                    Text(
                      "APR 27, 2026",
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "ACKNOWLEDGED",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF00E676),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
