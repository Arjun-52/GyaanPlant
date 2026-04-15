import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/leaderboard_viewmodel.dart';
import 'package:provider/provider.dart';

import 'package:gyaanplant/views/student_role/student/widgets/podium_user.dart';
import 'package:gyaanplant/views/student_role/student/widgets/rank_card.dart';
import 'package:gyaanplant/views/student_role/student/widgets/tab_item.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<LeaderboardViewModel>(
        context,
        listen: false,
      ).fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeaderboardViewModel(),

      child: Scaffold(
        backgroundColor: const Color(0xFF020B08),

        body: SafeArea(
          child: Consumer<LeaderboardViewModel>(
            builder: (context, vm, child) {
              ///  LOADING
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              /// ❌ EMPTY STATE
              if (vm.users.isEmpty) {
                return const Center(
                  child: Text(
                    "No leaderboard data",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              ///  DATA UI
              final users = vm.users;

              return Column(
                children: [
                  const SizedBox(height: 10),

                  /// TITLE
                  const Text(
                    "Leaderboard 🏆",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// TABS (UI only for now)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2A22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        TabItem(
                          "All Colleges",
                          selectedTab == 0,
                          onTap: () => setState(() => selectedTab = 0),
                        ),
                        TabItem(
                          "My College",
                          selectedTab == 1,
                          onTap: () => setState(() => selectedTab = 1),
                        ),
                        TabItem(
                          "My Batch",
                          selectedTab == 2,
                          onTap: () => setState(() => selectedTab = 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  ///  PODIUM (TOP 3)
                  if (users.length >= 3)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PodiumUser(
                          _getInitials(users[1].name),
                          users[1].name,
                          users[1].xp.toString(),
                          2,
                        ),
                        PodiumUser(
                          _getInitials(users[0].name),
                          users[0].name,
                          users[0].xp.toString(),
                          1,
                        ),
                        PodiumUser(
                          _getInitials(users[2].name),
                          users[2].name,
                          users[2].xp.toString(),
                          3,
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  ///  LIST
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];

                        return RankCard(
                          user.rank,
                          _getInitials(user.name),
                          user.name,
                          "—", // college not available
                          user.xp.toString(),
                          highlight: false,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(" ");
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}";
    }
    return name.isNotEmpty ? name[0] : "U";
  }
}
