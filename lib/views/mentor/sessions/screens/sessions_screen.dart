import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/mentor_viewmodel/session_viewmodel.dart';
import 'package:gyaanplant/views/mentor/dashboard/widgets/session_card.dart';
import 'package:gyaanplant/views/mentor/sessions/widgets/session_history_card.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/core/common_widgets/mentor_bottom_nav.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});
  String getInitials(String name) {
    return name.split(" ").map((e) => e[0]).take(2).join();
  }

  String formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return "TBD";

    return "${dt.day}/${dt.month}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionViewModel()..loadSessions(),
      child: Scaffold(
        backgroundColor: const Color(0xFF050A0A),

        body: Consumer<SessionViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final list = vm.completed;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Session History 💬",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: list.isEmpty
                          ? const Center(
                              child: Text(
                                "No completed sessions yet",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final s = list[index];

                                return Column(
                                  children: [
                                    SessionHistoryCard(
                                      initials: getInitials(s.name),
                                      name: s.name,
                                      date: formatDate(s.time),
                                      topic: s.topic,
                                      feedback: s.review,
                                      avatarColor: Colors.greenAccent,
                                      rating: s.rating,
                                      duration: "${s.duration} min",
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        bottomNavigationBar: const MentorBottomNav(currentIndex: 2),
      ),
    );
  }
}
