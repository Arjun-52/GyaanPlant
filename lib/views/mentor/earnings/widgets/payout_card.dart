import 'package:flutter/material.dart';

class PayoutCard extends StatelessWidget {
  final String date;
  final String sessions;
  final String amount;

  const PayoutCard({
    super.key,
    required this.date,
    required this.sessions,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2A20), Color(0xFF0A1F18)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_money, color: Colors.greenAccent),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(sessions, style: const TextStyle(color: Colors.white38)),
              ],
            ),
          ),

          Text(
            amount,
            style: const TextStyle(
              color: Color(0xFFB388FF),
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text("Paid", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
