import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String name;

  const HomeHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    // Split first name & last name
    final parts = name.split(" ");
    final firstName = parts.isNotEmpty ? parts[0] : "";
    final lastName = parts.length > 1 ? parts[1] : "";

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// 🔹 Left
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Good morning 👋",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 4),

              /// 🔥 Dynamic Name
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$firstName ",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: lastName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00C853),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Keep pushing forward 🚀",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),

          /// 🔹 Right
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F2A22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 18,
                ),
              ),

              const SizedBox(width: 10),

              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF00C853),
                child: Text(
                  firstName.isNotEmpty
                      ? firstName[0] + (lastName.isNotEmpty ? lastName[0] : "")
                      : "U",
                  style: const TextStyle(
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
