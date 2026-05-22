import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/views/mentor/earnings/widgets/earnings_header.dart';
import 'package:gyaanplant/views/mentor/earnings/widgets/earnings_stat_box.dart';
import 'package:gyaanplant/views/mentor/earnings/widgets/payout_card.dart';
import 'package:gyaanplant/views/mentor/earnings/widgets/total_earnings_card.dart';
import 'package:gyaanplant/core/common_widgets/mentor_bottom_nav.dart';
import 'package:gyaanplant/viewmodels/mentor_viewmodel/mentor_earnings_controller.dart';
import 'withdraw_screen.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<MentorEarningsController>().fetchEarnings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A0A),
      body: SafeArea(
        child: Consumer<MentorEarningsController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF16C47F),
                ),
              );
            }

            if (controller.errorMessage != null) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16C47F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => controller.fetchEarnings(),
                        child: const Text(
                          "Retry",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final model = controller.earnings;
            final stats = model?.stats;
            final recentSessions = model?.recentSessions ?? [];

            final totalEarnings = stats?.totalEarnings ?? 0.0;
            final monthlyEarnings = stats?.monthlyEarnings ?? 0.0;
            final netEarnings = stats?.netEarnings ?? 0.0;
            final sessionsCompleted = stats?.sessionsCompleted ?? 0;
            final pendingClearance = stats?.pendingClearance ?? 0.0;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EarningsHeader(),
                  const SizedBox(height: 16),

                  TotalEarningsCard(
                    totalEarnings: totalEarnings,
                    sessionsCompleted: sessionsCompleted,
                    monthlyEarnings: monthlyEarnings,
                  ),
                  const SizedBox(height: 20),

                  /// stats grid
                  Row(
                    children: [
                      Expanded(
                        child: EarningsStatBox(
                          "₹${monthlyEarnings.toStringAsFixed(0)}",
                          "Monthly Earnings",
                          const Color(0xFFB388FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: EarningsStatBox(
                          "₹${(sessionsCompleted > 0 ? (totalEarnings / sessionsCompleted) : 0.0).toStringAsFixed(0)}",
                          "Avg per Session",
                          const Color(0xFFFFB020),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: EarningsStatBox(
                          "₹${netEarnings.toStringAsFixed(0)}",
                          "Net Earnings",
                          const Color(0xFF16C47F),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: EarningsStatBox(
                          "₹${pendingClearance.toStringAsFixed(0)}",
                          "Pending Clearance",
                          const Color(0xFF00E5FF),
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
                      children: [
                        if (recentSessions.isEmpty)
                          const SizedBox(
                            height: 100,
                            child: Center(
                              child: Text(
                                "No recent payouts found",
                                style: TextStyle(color: Colors.white38),
                              ),
                            ),
                          )
                        else
                          ...recentSessions.map((item) {
                            final dateStr = (item is Map && item.containsKey('date'))
                                ? item['date']?.toString() ?? "N/A"
                                : "N/A";
                            final sessionsStr = (item is Map && item.containsKey('sessions'))
                                ? "${item['sessions']} sessions"
                                : "1 session";
                            final amountStr = (item is Map && item.containsKey('amount'))
                                ? "₹${item['amount']}"
                                : "₹0";
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: PayoutCard(
                                date: dateStr,
                                sessions: sessionsStr,
                                amount: amountStr,
                              ),
                            );
                          }),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16C47F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WithdrawScreen(
                                      availableBalance: pendingClearance,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Withdraw ₹${pendingClearance.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const MentorBottomNav(currentIndex: 3),
    );
  }
}
