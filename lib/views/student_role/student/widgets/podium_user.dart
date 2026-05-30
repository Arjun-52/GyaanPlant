import "package:flutter/material.dart";

class PodiumUser extends StatefulWidget {
  final String initials;
  final String name;
  final String score;
  final int rank;

  const PodiumUser(
    this.initials,
    this.name,
    this.score,
    this.rank, {
    super.key,
  });

  @override
  State<PodiumUser> createState() => _PodiumUserState();
}

class _PodiumUserState extends State<PodiumUser> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heightFactor;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
    );

    // Stagger animation based on rank (Rank 3 first, then Rank 2, then Rank 1)
    final delayMs = widget.rank == 1 ? 500 : (widget.rank == 2 ? 300 : 100);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetHeight = widget.rank == 1 ? 84.0 : (widget.rank == 2 ? 60.0 : 48.0);
    final color = widget.rank == 1
        ? const Color(0xFFFFD700) // Gold
        : widget.rank == 2
            ? const Color(0xFFC0C0C0) // Silver
            : const Color(0xFFCD7F32); // Bronze

    return SizedBox(
      width: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          /// AVATAR & CROWN
          ScaleTransition(
            scale: _scale,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: widget.rank == 1 ? 26 : 22,
                    backgroundColor: const Color(0xFF020B08),
                    child: Text(
                      widget.initials,
                      style: TextStyle(
                        color: color,
                        fontSize: widget.rank == 1 ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (widget.rank == 1)
                  const Positioned(
                    top: -16,
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFFFD700),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          /// USER DETAILS
          Text(
            widget.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.score,
            style: const TextStyle(
              color: Color(0xFF00E676),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          /// PODIUM PILLAR BLOCK (Animated Height)
          AnimatedBuilder(
            animation: _heightFactor,
            builder: (context, child) {
              return Container(
                width: 60,
                height: targetHeight * _heightFactor.value,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.35),
                      color.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(
                    top: BorderSide(color: color.withValues(alpha: 0.5), width: 1.5),
                    left: BorderSide(color: color.withValues(alpha: 0.3), width: 1.5),
                    right: BorderSide(color: color.withValues(alpha: 0.3), width: 1.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Text(
                  "${widget.rank}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

