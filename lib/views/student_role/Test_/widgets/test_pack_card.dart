import 'package:flutter/material.dart';
import 'package:gyaanplant/models/assessment/mock_test_models.dart';
import 'package:gyaanplant/views/student_role/Test_/screens/prep_pack_details_screen.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/core/unlocked_packs_cache.dart';

class TestPackCard extends StatefulWidget {
  final PreparationPackModel pack;
  final VoidCallback? onReturn;

  const TestPackCard({super.key, required this.pack, this.onReturn});

  @override
  State<TestPackCard> createState() => _TestPackCardState();
}

class _TestPackCardState extends State<TestPackCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;
  bool _isPressed = false;
  late bool _hasAccess;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _hasAccess = widget.pack.hasAccess || UnlockedPacksCache.contains(widget.pack.id);
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pack = widget.pack;

    // Difficulty Color Mapping
    Color difficultyColor;
    IconData difficultyIcon;
    switch (pack.difficulty.toLowerCase()) {
      case 'easy':
        difficultyColor = const Color(0xFF00E676);
        difficultyIcon = Icons.speed_rounded;
        break;
      case 'medium':
        difficultyColor = const Color(0xFFFFAB40);
        difficultyIcon = Icons.trending_up_rounded;
        break;
      case 'hard':
        difficultyColor = const Color(0xFFFF5252);
        difficultyIcon = Icons.local_fire_department_rounded;
        break;
      case 'mixed':
        difficultyColor = const Color(0xFFB388FF);
        difficultyIcon = Icons.shuffle_rounded;
        break;
      default:
        difficultyColor = const Color(0xFF00E676);
        difficultyIcon = Icons.speed_rounded;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0C2A1F),
                Color(0xFF071F16),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00C853).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.06),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Difficulty + Premium Badge ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          difficultyColor.withOpacity(0.2),
                          difficultyColor.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: difficultyColor.withOpacity(0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(difficultyIcon,
                            size: 12, color: difficultyColor),
                        const SizedBox(width: 5),
                        Text(
                          pack.difficulty.toUpperCase(),
                          style: TextStyle(
                            color: difficultyColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (pack.isPremium)
                    AnimatedBuilder(
                      animation: _shimmerCtrl,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: const [
                                Color(0xFFFFD700),
                                Color(0xFFFFA500),
                                Color(0xFFFFD700),
                              ],
                              stops: [
                                (_shimmerCtrl.value - 0.3).clamp(0.0, 1.0),
                                _shimmerCtrl.value,
                                (_shimmerCtrl.value + 0.3).clamp(0.0, 1.0),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.amber.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.workspace_premium_rounded,
                                  size: 11, color: Colors.black87),
                              SizedBox(width: 4),
                              Text(
                                "PREMIUM",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Title ──
              Text(
                pack.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.3,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),

              // ── Tags ──
              if (pack.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: pack.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 11),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
              ],

              // ── Price Section ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "₹${pack.price}",
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.white30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white24, size: 14),
                    const SizedBox(width: 10),
                    Text(
                      "₹${pack.discountedPrice}",
                      style: TextStyle(
                        color: const Color(0xFF00E676),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF00E676)
                                .withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.redAccent.withOpacity(0.2),
                            Colors.redAccent.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.redAccent.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        "${pack.discountPercentage}% OFF",
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Divider ──
              Container(
                height: 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Stats Grid ──
              Row(
                children: [
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.view_module_rounded,
                      label: "SECTIONS",
                      value: "${pack.sections.length}",
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withOpacity(0.08),
                  ),
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.quiz_outlined,
                      label: "QUESTIONS",
                      value: "${pack.totalQuestions}",
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withOpacity(0.08),
                  ),
                  Expanded(
                    child: _StatColumn(
                      icon: Icons.timer_outlined,
                      label: "DURATION",
                      value: pack.totalDurationMins == 0
                          ? "--"
                          : "${pack.totalDurationMins}m",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Divider ──
              Container(
                height: 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Metric Pills ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMetricPill(
                        Icons.repeat_rounded, "${pack.attempts} ATTEMPTS"),
                    const SizedBox(width: 8),
                    _buildMetricPill(Icons.done_all_rounded,
                        "${pack.completions} COMPLETED"),
                    const SizedBox(width: 8),
                    _buildMetricPill(Icons.bar_chart_rounded,
                        "${pack.avgScore.round()}% AVG SCORE"),
                    const SizedBox(width: 8),
                    _buildMetricPill(Icons.verified_rounded,
                        "Pass ${pack.passingScore.round()}%",
                        isAccent: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Action Button ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _hasAccess
                    ? _buildStartButton(context)
                    : _buildUnlockButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00E676), Color(0xFF00C853), Color(0xFF009624)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.3),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _navigateToDetails(context),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock_open_rounded, size: 18, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  "UNLOCK PACK",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00E676), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _navigateToDetails(context),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.play_arrow_rounded, size: 20, color: Color(0xFF00E676)),
                SizedBox(width: 6),
                Text(
                  "START",
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToDetails(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrepPackDetailsScreen(packId: widget.pack.id),
      ),
    );
    // After returning from details screen, verify access status from backend.
    // If the backend hasn't updated yet, optimistically mark as unlocked
    // because the details screen performs the unlock flow and may force
    // an optimistic unlock when verification completes.
    try {
      final api = ApiService();
      final response = await api.assessment.getPrepPackDetails(widget.pack.id);
      if (response.isSuccess && response.data != null && response.statusCode == 200) {
        setState(() => _hasAccess = true);
        UnlockedPacksCache.add(widget.pack.id);
      } else {
        // Backend may still be syncing; rely on local optimistic unlock.
        // Only flip if the previous state was unlocked in details view.
        setState(() => _hasAccess = widget.pack.hasAccess || _hasAccess);
      }
    } catch (_) {
      // Network or other error: keep existing state but trigger parent
      // callback so list containers can refresh if they choose to.
      setState(() => _hasAccess = widget.pack.hasAccess || _hasAccess);
    }

    widget.onReturn?.call();
  }

  Widget _buildMetricPill(IconData icon, String label, {bool isAccent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAccent
            ? const Color(0xFF00C853).withOpacity(0.12)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAccent
              ? const Color(0xFF00C853).withOpacity(0.3)
              : Colors.white.withOpacity(0.06),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: isAccent ? const Color(0xFF00E676) : Colors.white38,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isAccent ? const Color(0xFF00E676) : Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.white30),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
