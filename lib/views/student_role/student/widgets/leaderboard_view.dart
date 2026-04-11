import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: SafeArea(
        child: Column(
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

            /// TABS
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
                    onTap: () {
                      setState(() => selectedTab = 0);
                    },
                  ),
                  TabItem(
                    "My College",
                    selectedTab == 1,
                    onTap: () {
                      setState(() => selectedTab = 1);
                    },
                  ),
                  TabItem(
                    "My Batch",
                    selectedTab == 2,
                    onTap: () {
                      setState(() => selectedTab = 2);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Podium
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                PodiumUser("PR", "Priya R.", "2,840", 2),
                PodiumUser("AK", "Arjun K.", "3,120", 1),
                PodiumUser("RV", "Rahul V.", "2,710", 3),
              ],
            ),

            const SizedBox(height: 20),

            /// LIST
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  RankCard(4, "SM", "Sneha M.", "MVSR Engg", "2,590"),
                  RankCard(5, "KP", "Karthik P.", "CBIT Hyd", "2,480"),
                  RankCard(
                    47,
                    "You",
                    "You · Arjun Kumar",
                    "GRIET Hyderabad",
                    "1,840",
                    highlight: true,
                  ),
                  RankCard(48, "DS", "Divya S.", "Vasavi College", "1,820"),
                  RankCard(49, "MT", "Manohar T.", "Osmania Univ", "1,790"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
