import 'package:flutter/material.dart';

class SessionsHeader extends StatelessWidget {
  const SessionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          "Session History",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 6),
        Text("💬", style: TextStyle(fontSize: 18)),
      ],
    );
  }
}
