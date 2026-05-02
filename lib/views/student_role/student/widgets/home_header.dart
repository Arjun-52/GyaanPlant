import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeHeader extends StatelessWidget {
  final String name;
  final String? driveText;

  const HomeHeader({super.key, required this.name, this.driveText});

  @override
  Widget build(BuildContext context) {
    final parts = name.split(" ");
    final firstName = parts.isNotEmpty ? parts[0] : "";
    final lastName = parts.length > 1 ? parts[1] : "";

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ///  Left
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Good morning 👋",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 4),

              ///  Dynamic Name
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

              Text(
                driveText ?? "Keep pushing forward 🚀",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),

          ///  Right
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(1),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F2A22),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 19,
                  ),
                  onPressed: () {
                    context.push('/notifications');
                  },
                ),
              ),
              const SizedBox(width: 12),
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
