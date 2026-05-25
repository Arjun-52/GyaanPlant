import 'package:flutter/material.dart';

class TpoDashboardShimmer extends StatefulWidget {
  const TpoDashboardShimmer({super.key});

  @override
  State<TpoDashboardShimmer> createState() => _TpoDashboardShimmerState();
}

class _TpoDashboardShimmerState extends State<TpoDashboardShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.05, end: 0.22).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stat Cards Shimmer
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: List.generate(4, (index) => _buildStatCardShimmer()),
        ),
        const SizedBox(height: 25),
        // Upcoming drives title placeholder
        _buildShimmerBlock(width: 140, height: 18),
        const SizedBox(height: 12),
        // Horizontal list shimmer
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _buildDriveCardShimmer(),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerBlock({required double width, required double height, double borderRadius = 8}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }

  Widget _buildStatCardShimmer() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final double opacityVal = _animation.value;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(opacityVal * 0.4),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 70,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacityVal),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 50,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacityVal),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                width: 90,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacityVal),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDriveCardShimmer() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final double opacityVal = _animation.value;
        final double cardWidth = MediaQuery.of(context).size.width - 32;
        return Container(
          width: cardWidth,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(opacityVal * 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(opacityVal),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(opacityVal),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 80,
                          height: 11,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(opacityVal),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 55,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(opacityVal),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(opacityVal),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 60,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(opacityVal),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 110,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(opacityVal),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(opacityVal),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
