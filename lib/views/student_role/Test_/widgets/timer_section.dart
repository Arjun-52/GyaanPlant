import 'package:flutter/material.dart';

class TimerSection extends StatelessWidget {
  const TimerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT SIDE (Time + Label)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "TIME LEFT",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "03:47",
              style: TextStyle(
                color: Color(0xFFFFA726),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // CENTER (Round badge)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0A2A22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.6)),
          ),
          child: const Text(
            "Round 2 of 3",
            style: TextStyle(color: Colors.lightBlueAccent, fontSize: 12),
          ),
        ),

        //  RIGH
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            "Q 16/20",
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
