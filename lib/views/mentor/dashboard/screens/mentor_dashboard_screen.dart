import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/mentor_viewmodel/mentor_dashboard_viewmodel.dart';
import 'package:gyaanplant/views/mentor/dashboard/widgets/header_widget.dart';
import 'package:gyaanplant/views/mentor/dashboard/widgets/quick_stats.dart';
import 'package:gyaanplant/views/mentor/dashboard/widgets/session_card.dart';
import 'package:gyaanplant/core/common_widgets/mentor_bottom_nav.dart';
import 'package:provider/provider.dart';

class MentorDashboardScreen extends StatelessWidget {
  const MentorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MentorDashboardViewModel()..loadDashboard(),
      child: Scaffold(
        backgroundColor: const Color(0xFF050A0A),

        body: Consumer<MentorDashboardViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.dashboard == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to Load Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (vm.error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          vm.error!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: vm.loadDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = vm.dashboard!;

            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///  HEADER
                    HeaderWidget(data: data),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          ///  TODAY SESSIONS
                          const Text(
                            "Today's Sessions",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          _buildSessionsList(),

                          const SizedBox(height: 24),

                          ///  QUICK STATS
                          const Text(
                            "Quick Stats",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: StatBox(
                                  "${data.rating}",
                                  "Rating",
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatBox(
                                  "₹${data.earnings}",
                                  "Earnings",
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: StatBox(
                                  "${data.sessionsDone}",
                                  "Sessions",
                                  Colors.purple,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: StatBox("0", "Pending", Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        bottomNavigationBar: const MentorBottomNav(currentIndex: 0),
      ),
    );
  }

  Widget _buildSessionsList() {
    // Mock session data since the model doesn't have upcomingSessions
    final sessions = [
      {
        'studentName': 'John Doe',
        'topic': 'Career Guidance',
        'time': '10:00 AM',
      },
      {
        'studentName': 'Jane Smith',
        'topic': 'Skill Development',
        'time': '2:00 PM',
      },
    ];

    if (sessions.isEmpty) {
      return const Text(
        "No sessions today",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: sessions.map<Widget>((session) {
        return SessionCard(
          initials: _getInitials(session['studentName'] ?? "Student"),
          name: session['studentName'] ?? "Student",
          detail: "Session",
          time: session['time'] ?? "TBD",
          topic: session['topic'] ?? "Mentoring",
        );
      }).toList(),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'S';
  }
}
