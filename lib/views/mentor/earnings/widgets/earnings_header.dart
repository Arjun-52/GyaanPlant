import 'package:flutter/material.dart';

class EarningsHeader extends StatelessWidget {
  const EarningsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          "Earnings",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 6),
        Text("💰", style: TextStyle(fontSize: 20)),
      ],
    );
  }
}
