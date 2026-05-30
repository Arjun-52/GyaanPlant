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

class _EarningsScreenState extends State<EarningsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    Future.microtask(() {
      if (mounted) {
        context.read<MentorEarningsController>().fetchEarnings();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: SafeArea(
        child: Consumer<MentorEarningsController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00E676),
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
                          backgroundColor: const Color(0xFF00E676),
                          foregroundColor: Colors.black,
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

            // Start animations once dashboard data is available
            _animController.forward();

            final model = controller.earnings;
            final stats = model?.stats;
            final recentSessions = model?.recentSessions ?? [];

            final totalEarnings = stats?.totalEarnings ?? 0.0;
            final monthlyEarnings = stats?.monthlyEarnings ?? 0.0;
            final netEarnings = stats?.netEarnings ?? 0.0;
            final sessionsCompleted = stats?.sessionsCompleted ?? 0;
            final pendingClearance = stats?.pendingClearance ?? 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  
                  // Header Animated Fade-In
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      );
                    },
                    child: const EarningsHeader(),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: child,
                          ),
                        );
                      },
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          TotalEarningsCard(
                            totalEarnings: totalEarnings,
                            sessionsCompleted: sessionsCompleted,
                            monthlyEarnings: monthlyEarnings,
                          ),
                          const SizedBox(height: 24),

                          /// Stats Grid
                          Row(
                            children: [
                              Expanded(
                                child: EarningsStatBox(
                                  "₹${monthlyEarnings.toStringAsFixed(0)}",
                                  "Monthly Earnings",
                                  const Color(0xFF00E676),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: EarningsStatBox(
                                  "₹${(sessionsCompleted > 0 ? (totalEarnings / sessionsCompleted) : 0.0).toStringAsFixed(0)}",
                                  "Avg per Session",
                                  const Color(0xFF00E676),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: EarningsStatBox(
                                  "₹${netEarnings.toStringAsFixed(0)}",
                                  "Net Earnings",
                                  const Color(0xFF00E676),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: EarningsStatBox(
                                  "₹${pendingClearance.toStringAsFixed(0)}",
                                  "Pending Clearance",
                                  const Color(0xFF00E676),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E676).withOpacity(0.4),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Recent Payouts",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          if (recentSessions.isEmpty)
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F3D34).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF00E676).withOpacity(0.1),
                                  width: 1.2,
                                ),
                              ),
                              child: const Center(
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
                                padding: const EdgeInsets.only(bottom: 12),
                                child: PayoutCard(
                                  date: dateStr,
                                  sessions: sessionsStr,
                                  amount: amountStr,
                                ),
                              );
                            }),

                          const SizedBox(height: 24),
                          
                          /// Withdraw Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E676).withOpacity(0.3),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF031B15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Color(0xFF031B15),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Withdraw ₹${pendingClearance.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        color: Color(0xFF031B15),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Bottom Navigation Margins
                          const SizedBox(height: 120),
                        ],
                      ),
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
