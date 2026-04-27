import 'package:flutter/material.dart';
import 'package:gyaanplant/models/mentor_models/mentor_dashboard_model.dart';
import 'package:gyaanplant/views/mentor/dashboard/widgets/stat_card.dart';

class HeaderWidget extends StatelessWidget {
  final MentorDashboardModel data;

  const HeaderWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF140A2E), Color(0xFF1A0033)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///  TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mentor Dashboard",
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 6),

                  ///  NAME
                  const Text(
                    "Mentor",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB388FF),
                    ),
                  ),

                  const SizedBox(height: 6),

                  ///  ROLE
                  Text(
                    data.role.isNotEmpty ? data.role : "Mentor",
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),

              ///  AVATAR
              Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.greenAccent,
                ),
                child: const Center(
                  child: Text(
                    "M",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ///  STATS ROW
          Row(
            children: [
              Expanded(
                child: StatCard(
                  "${data.sessionsDone}",
                  "Sessions Done",
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: StatCard(
                  "₹${data.earnings}",
                  "Total Earnings",
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: StatCard("${data.rating} ⭐", "Rating", Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
