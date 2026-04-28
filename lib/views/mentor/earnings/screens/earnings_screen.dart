import 'package:flutter/material.dart';
import 'package:gyaanplant/views/mentor/earnings/widgets/earnings_header.dart';
import 'package:gyaanplant/views/mentor/earnings/widgets/earnings_stat_box.dart';
import 'package:gyaanplant/views/mentor/earnings/widgets/payout_card.dart';
import 'package:gyaanplant/views/mentor/earnings/widgets/total_earnings_card.dart';
import 'package:gyaanplant/core/common_widgets/mentor_bottom_nav.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A0A),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EarningsHeader(),
              const SizedBox(height: 16),

              const TotalEarningsCard(),
              const SizedBox(height: 20),

              /// stats grid
              Row(
                children: const [
                  Expanded(
                    child: EarningsStatBox(
                      "₹9,600",
                      "March 2026",
                      Color(0xFFB388FF),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: EarningsStatBox(
                      "₹400",
                      "Avg per Session",
                      Color(0xFFFFB020),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                    child: EarningsStatBox(
                      "₹22,720",
                      "Paid Out",
                      Color(0xFF16C47F),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: EarningsStatBox(
                      "₹5,680",
                      "Pending",
                      Color(0xFF00E5FF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Recent Payouts",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  children: const [
                    PayoutCard(
                      date: "Mar 1, 2026",
                      sessions: "16 sessions",
                      amount: "₹6,400",
                    ),
                    SizedBox(height: 10),
                    PayoutCard(
                      date: "Feb 1, 2026",
                      sessions: "20 sessions",
                      amount: "₹8,000",
                    ),
                    SizedBox(height: 10),
                    PayoutCard(
                      date: "Dec 1, 2025",
                      sessions: "20 sessions",
                      amount: "₹8,320",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const MentorBottomNav(currentIndex: 3),
    );
  }
}
