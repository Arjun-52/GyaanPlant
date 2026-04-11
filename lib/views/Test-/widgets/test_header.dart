import 'package:flutter/material.dart';

class TestHeader extends StatelessWidget {
  const TestHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mock Test 🎯",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Company-specific preparation",
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }
}
