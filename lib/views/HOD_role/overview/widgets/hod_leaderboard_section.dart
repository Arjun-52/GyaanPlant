import 'package:flutter/material.dart';
import 'package:gyaanplant/models/gamification/leaderboard_model.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/leaderboard_viewmodel.dart';
import 'package:gyaanplant/views/student_role/student/widgets/podium_user.dart';
import 'package:gyaanplant/views/student_role/student/widgets/rank_card.dart';
import 'package:provider/provider.dart';

class HodLeaderboardSection extends StatefulWidget {
  const HodLeaderboardSection({super.key});

  @override
  State<HodLeaderboardSection> createState() => _HodLeaderboardSectionState();
}

class _HodLeaderboardSectionState extends State<HodLeaderboardSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<LeaderboardViewModel>().fetchLeaderboard();
      }
    });
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  Widget _buildBody(LeaderboardViewModel vm) {
    if (vm.isLoading) return _LeaderboardShimmer();

    if (vm.errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0C221B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
            SizedBox(width: 8),
            Text(
              'Failed to load leaderboard',
              style: TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
      );
    }

    if (vm.users.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0C221B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No leaderboard data yet',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return _buildLoaded(vm.users);
  }

  Widget _buildLoaded(List<LeaderboardEntry> users) {
    final rankList = users.length > 3
        ? users.sublist(3)
        : (users.length == 3 ? [] : users);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Podium (top 3) with dynamic pop-spring animation
        if (users.length >= 3)
          AnimatedPodium(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0C221B), Color(0xFF05100C)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PodiumUser(
                    _initials(users[1].name),
                    users[1].name,
                    '${users[1].xp} XP',
                    2,
                  ),
                  PodiumUser(
                    _initials(users[0].name),
                    users[0].name,
                    '${users[0].xp} XP',
                    1,
                  ),
                  PodiumUser(
                    _initials(users[2].name),
                    users[2].name,
                    '${users[2].xp} XP',
                    3,
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Rank list (4th onward) with sequential slide up stagger transitions
        ...List.generate(rankList.length, (index) {
          final user = rankList[index];
          return AnimatedRankCard(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RankCard(
                user.rank,
                _initials(user.name),
                user.name,
                user.department ?? '—',
                '${user.xp} XP',
                highlight: false,
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaderboardViewModel>(
      builder: (context, vm, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: Color(0xFF00C853), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Student Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (vm.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00C853),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            _buildBody(vm),
          ],
        );
      },
    );
  }
}

// 🔷 STAGGERED LIST SLIDE CARD
class AnimatedRankCard extends StatefulWidget {
  final int index;
  final Widget child;

  const AnimatedRankCard({super.key, required this.index, required this.child});

  @override
  State<AnimatedRankCard> createState() => _AnimatedRankCardState();
}

class _AnimatedRankCardState extends State<AnimatedRankCard> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _visible ? 1.0 : 0.0,
      curve: Curves.easeOut,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 600),
        offset: _visible ? Offset.zero : const Offset(0, 0.25),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

// 🔷 PODIUM ELASTIC SPRING POP
class AnimatedPodium extends StatefulWidget {
  final Widget child;
  const AnimatedPodium({super.key, required this.child});

  @override
  State<AnimatedPodium> createState() => _AnimatedPodiumState();
}

class _AnimatedPodiumState extends State<AnimatedPodium> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _animate = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 800),
      scale: _animate ? 1.0 : 0.88,
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: _animate ? 1.0 : 0.0,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// Shimmer placeholder
class _LeaderboardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF0C221B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.05)),
          ),
        ),
      ),
    );
  }
}
