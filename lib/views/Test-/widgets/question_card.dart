import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A241D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          //  TOP LABEL
          Text(
            "VERBAL REASONING · TCS PATTERN",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 10),

          //  QUESTION
          Text(
            "If ROAD is coded as URDG, what is the code for SWAN?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
