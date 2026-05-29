import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/assessment/mock_test_models.dart';
import '../../../../viewmodels/student_viewmodel/prep_pack_details_viewmodel.dart';
import '../../../../viewmodels/student_viewmodel/prep_pack_state.dart';
import '../../../../viewmodels/student_viewmodel/auth_viewmodel.dart';
import 'question_screen.dart';

class PrepPackDetailsScreen extends StatelessWidget {
  final String packId;

  const PrepPackDetailsScreen({super.key, required this.packId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PrepPackDetailsViewModel>(
      create: (_) => PrepPackDetailsViewModel(packId: packId)..loadDetails(),
      child: const _PrepPackDetailsScreenContent(),
    );
  }
}

class _PrepPackDetailsScreenContent extends StatelessWidget {
  const _PrepPackDetailsScreenContent();

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF00FFA3);
      case 'medium':
        return Colors.orangeAccent;
      case 'hard':
        return Colors.redAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PrepPackDetailsViewModel>(context);
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: const Color(0xFF030705), // Deep black background
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF00FFA3).withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: ClipRRect(
            child: AppBar(
              backgroundColor: const Color(0xFF030705).withValues(alpha: 0.85),
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C241B).withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              title: const Text(
                "Preparation Pack Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C241B).withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                      onPressed: () => viewModel.loadDetails(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background ambient lights
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.05),
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F3B2E).withValues(alpha: 0.08),
                    blurRadius: 180,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),

          // Main body switch
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.03),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildBodyForState(context, viewModel, state),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyForState(
    BuildContext context,
    PrepPackDetailsViewModel viewModel,
    PrepPackState state,
  ) {
    switch (state) {
      case PreparationLoading():
        return const _ShimmerLoading(key: ValueKey('PreparationLoading'));
      case PreparationError(message: final msg):
        return _buildErrorState(viewModel, msg);
      case PreparationLocked(previewPack: final pack):
        return _buildLockedScreen(context, viewModel, pack, isPurchasing: false);
      case PreparationPurchaseLoading(previewPack: final pack):
        return _buildLockedScreen(context, viewModel, pack, isPurchasing: true);
      case PreparationUnlocked(fullPack: final pack):
        return _buildUnlockedScreen(context, pack);
    }
    return const SizedBox.shrink();
  }

  // ── LOCKED VIEW ─────────────────────────────────────────────────────────

  Widget _buildLockedScreen(
    BuildContext context,
    PrepPackDetailsViewModel viewModel,
    PrepPackDetailsModel pack, {
    required bool isPurchasing,
  }) {
    final user = context.read<AuthViewModel>().user;

    return SingleChildScrollView(
      key: const ValueKey('LockedStateView'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 95, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pack Hero Section
          _StaggeredItem(
            index: 0,
            child: _PackHeroSection(isPremium: pack.isPremium),
          ),
          
          const SizedBox(height: 24),
          
          // Title & Badges
          _StaggeredItem(
            index: 1,
            child: Column(
              children: [
                Text(
                  pack.title,
                  style: const TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Glassmorphism Badge Pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(pack.difficulty).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getDifficultyColor(pack.difficulty).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        pack.difficulty.toUpperCase(),
                        style: TextStyle(
                          color: _getDifficultyColor(pack.difficulty),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (pack.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Text(
                          "⭐️ PREMIUM",
                          style: TextStyle(
                            color: Color(0xFF030705),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Description Card
          if (pack.description.isNotEmpty)
            _StaggeredItem(
              index: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0C241B).withValues(alpha: 0.3),
                      const Color(0xFF030E0A).withValues(alpha: 0.7),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.1),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF00FFA3), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          "ABOUT THIS PACK",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00FFA3).withValues(alpha: 0.7),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pack.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 20),

          // Benefits Section (New)
          _StaggeredItem(
            index: 3,
            child: const _BenefitsSection(),
          ),

          const SizedBox(height: 24),
          
          // Pricing Visual Highlight
          _StaggeredItem(
            index: 4,
            child: _PricingCard(pack: pack),
          ),
          
          const SizedBox(height: 24),
          
          // Large CTA "Unlock Pack"
          _StaggeredItem(
            index: 5,
            child: _UnlockCTAButton(
              isPurchasing: isPurchasing,
              onPressed: () {
                viewModel.unlockPack(
                  user: user,
                  showSuccess: (msg) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: const Color(0xFF00FFA3),
                      ),
                    );
                  },
                  showError: (msg) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          const Center(
            child: Text(
              "Secure Payment gateway powered by Razorpay",
              style: TextStyle(
                color: Colors.white30,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── UNLOCKED VIEW ───────────────────────────────────────────────────────

  Widget _buildUnlockedScreen(BuildContext context, PrepPackDetailsModel pack) {
    final targetTags = [
      ...pack.targetCompanies,
      ...pack.targetRoles,
      ...pack.industries,
    ];

    return SingleChildScrollView(
      key: const ValueKey('UnlockedStateView'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 95, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium Hero Card
          _StaggeredItem(
            index: 0,
            child: _UnlockedHeroCard(pack: pack),
          ),
          
          const SizedBox(height: 20),

          // Success Status Card
          _StaggeredItem(
            index: 1,
            child: const _UnlockedStatusCard(),
          ),
          
          const SizedBox(height: 24),

          // Pack Metrics Section (2x2 Grid)
          _StaggeredItem(
            index: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PACK METRICS",
                  style: TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _UnlockedMetricsGrid(pack: pack),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Scoring System Section
          _StaggeredItem(
            index: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "SCORING SYSTEM",
                  style: TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _UnlockedScoringSystem(pack: pack),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Target Companies Section
          if (targetTags.isNotEmpty)
            _StaggeredItem(
              index: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TARGET SECTORS & COMPANIES",
                    style: TextStyle(
                      fontFamily: 'Gilroy-Bold',
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _UnlockedTargetCompanies(targetTags: targetTags),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Assessment Deck Sections
          _StaggeredItem(
            index: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ASSESSMENT DECK SECTIONS",
                  style: TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _UnlockedAssessmentSections(pack: pack),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SKELETON & HELPERS ───────────────────────────────────────────────────

  Widget _buildErrorState(PrepPackDetailsViewModel viewModel, String error) {
    return Center(
      key: const ValueKey('ErrorStateView'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              "Unable to load details",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.loadDetails(),
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFA3),
                foregroundColor: const Color(0xFF030705),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CUSTOM COMPONENTS ──────────────────────────────────────────────────────

class _StaggeredItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _StaggeredItem({required this.child, required this.index});

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _translate = Tween<double>(begin: 35, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: 100 + widget.index * 90), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _translate.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _PackHeroSection extends StatefulWidget {
  final bool isPremium;

  const _PackHeroSection({required this.isPremium});

  @override
  State<_PackHeroSection> createState() => _PackHeroSectionState();
}

class _PackHeroSectionState extends State<_PackHeroSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background soft radial lighting
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFA3).withValues(alpha: 0.12),
                  blurRadius: 35,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // Animated Gradient rotating ring
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        const Color(0xFF00FFA3).withValues(alpha: 0.8),
                        const Color(0xFF0F3B2E).withValues(alpha: 0.1),
                        const Color(0xFF00FFA3).withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.5),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF030705),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Glowing lock icon area
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              color: const Color(0xFF0C241B).withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00FFA3).withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              widget.isPremium ? Icons.lock : Icons.lock_open,
              color: const Color(0xFF00FFA3),
              size: 42,
            ),
          ),

          // Soft floating floating particles around the icon
          const Positioned(
            top: -15,
            left: 20,
            child: _DriftingDot(size: 6, delayMs: 0),
          ),
          const Positioned(
            bottom: -10,
            right: 15,
            child: _DriftingDot(size: 4, delayMs: 900),
          ),
          const Positioned(
            top: 50,
            left: -20,
            child: _DriftingDot(size: 5, delayMs: 400),
          ),
        ],
      ),
    );
  }
}

class _DriftingDot extends StatefulWidget {
  final double size;
  final int delayMs;

  const _DriftingDot({required this.size, required this.delayMs});

  @override
  State<_DriftingDot> createState() => _DriftingDotState();
}

class _DriftingDotState extends State<_DriftingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(8 * math.sin(_anim.value * math.pi), -25 * _anim.value),
          child: Opacity(
            opacity: 0.8 * (1.0 - (_anim.value - 0.5).abs() * 2),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: const BoxDecoration(
                color: Color(0xFF00FFA3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00FFA3),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BenefitsSection extends StatelessWidget {
  const _BenefitsSection();

  @override
  Widget build(BuildContext context) {
    final benefits = [
      "Practice Questions",
      "Mock Assessments",
      "Placement Preparation",
      "Interview Readiness",
      "Progress Tracking",
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF071C15).withValues(alpha: 0.4),
            const Color(0xFF020705).withValues(alpha: 0.8),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.12),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.stars, color: Color(0xFF00FFA3), size: 18),
              SizedBox(width: 8),
              Text(
                "WHAT YOU'LL GET",
                style: TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00FFA3),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...benefits.map((benefit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FFA3).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00FFA3).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF00FFA3),
                      size: 11,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    benefit,
                    style: const TextStyle(
                      fontFamily: 'Gilroy-Medium',
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final PrepPackDetailsModel pack;

  const _PricingCard({required this.pack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F3B2E).withValues(alpha: 0.35),
            const Color(0xFF030D0A).withValues(alpha: 0.95),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.06),
            blurRadius: 25,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Floating Premium Badge
          Positioned(
            top: -34,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FFA3), Color(0xFF0F3B2E)],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFF00FFA3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                "${pack.discountPercentage}% OFF",
                style: const TextStyle(
                  color: Color(0xFF030705),
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SPECIAL INTRO PRICE",
                    style: TextStyle(
                      fontFamily: 'Gilroy-Bold',
                      color: const Color(0xFF00FFA3).withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "₹${pack.discountedPrice}",
                        style: const TextStyle(
                          fontFamily: 'Gilroy-Bold',
                          color: Color(0xFF00FFA3),
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Color(0xFF00FFA3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "₹${pack.price}",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 18,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.verified, color: Color(0xFF00FFA3), size: 24),
                  const SizedBox(height: 4),
                  Text(
                    "Save ₹${pack.price - pack.discountedPrice}",
                    style: const TextStyle(
                      fontFamily: 'Gilroy-Medium',
                      color: Color(0xFF00FFA3),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnlockCTAButton extends StatefulWidget {
  final bool isPurchasing;
  final VoidCallback onPressed;

  const _UnlockCTAButton({required this.isPurchasing, required this.onPressed});

  @override
  State<_UnlockCTAButton> createState() => _UnlockCTAButtonState();
}

class _UnlockCTAButtonState extends State<_UnlockCTAButton> with SingleTickerProviderStateMixin {
  bool _isTapped = false;
  late AnimationController _pulsateController;

  @override
  void initState() {
    super.initState();
    _pulsateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulsateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isTapped ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: AnimatedBuilder(
        animation: _pulsateController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFA3).withValues(
                    alpha: widget.isPurchasing ? 0.1 : (0.2 + 0.1 * _pulsateController.value),
                  ),
                  blurRadius: widget.isPurchasing ? 12 : (15 + 10 * _pulsateController.value),
                  spreadRadius: widget.isPurchasing ? 0 : (1 + 2 * _pulsateController.value),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.isPurchasing
                  ? null
                  : () async {
                      setState(() {
                        _isTapped = true;
                      });
                      await Future.delayed(const Duration(milliseconds: 150));
                      setState(() {
                        _isTapped = false;
                      });
                      widget.onPressed();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFA3),
                foregroundColor: const Color(0xFF030705),
                disabledBackgroundColor: const Color(0xFF00FFA3).withValues(alpha: 0.35),
                disabledForegroundColor: const Color(0xFF030705).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
              ),
              child: widget.isPurchasing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF030705)),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Processing payment...",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.rocket_launch, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Unlock & Start Learning",
                          style: TextStyle(
                            fontFamily: 'Gilroy-Bold',
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerLoading extends StatefulWidget {
  const _ShimmerLoading({super.key});

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final gradientOffset = _shimmerController.value;
        final shimmerGradient = LinearGradient(
          colors: [
            const Color(0xFF0A1410).withValues(alpha: 0.6),
            const Color(0xFF0F2C21).withValues(alpha: 0.85),
            const Color(0xFF0A1410).withValues(alpha: 0.6),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment(-1.5 + gradientOffset * 3, -0.3),
          end: Alignment(0.0 + gradientOffset * 3, 0.3),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 95, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero ring shimmer
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: shimmerGradient,
                  ),
                ),
              ),
              const SizedBox(height: 35),
              
              // Title shimmer
              Center(
                child: Container(
                  width: 230,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: shimmerGradient,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Chips shimmer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: shimmerGradient,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: shimmerGradient,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // Description card shimmer
              Container(
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: shimmerGradient,
                ),
              ),
              const SizedBox(height: 24),

              // Pricing block shimmer
              Container(
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: shimmerGradient,
                ),
              ),
              const SizedBox(height: 30),

              // CTA shimmer
              Container(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: shimmerGradient,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── UNLOCKED VISUAL SUBCOMPONENTS ───────────────────────────────────────────

class _UnlockedHeroCard extends StatelessWidget {
  final PrepPackDetailsModel pack;

  const _UnlockedHeroCard({required this.pack});

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF00FFA3);
      case 'medium':
        return Colors.orangeAccent;
      case 'hard':
        return Colors.redAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0C241B).withValues(alpha: 0.4),
            const Color(0xFF030D0A).withValues(alpha: 0.9),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.05),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Glowing Circular Icon Container
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFF00FFA3).withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00FFA3).withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFA3).withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Color(0xFF00FFA3),
              size: 38,
            ),
          ),
          
          const SizedBox(height: 18),
          
          Text(
            pack.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Gilroy-Bold',
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          
          const SizedBox(height: 14),

          // Glowing Badge Row
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              // Difficulty
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(pack.difficulty).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getDifficultyColor(pack.difficulty).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  pack.difficulty.toUpperCase(),
                  style: TextStyle(
                    color: _getDifficultyColor(pack.difficulty),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              // Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Text(
                  pack.targetType.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              // Premium Tag
              if (pack.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Text(
                    "PREMIUM",
                    style: TextStyle(
                      color: Color(0xFF030705),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          
          if (pack.description.isNotEmpty) ...[
            const SizedBox(height: 18),
            Divider(color: const Color(0xFF00FFA3).withValues(alpha: 0.1), height: 1),
            const SizedBox(height: 18),
            Text(
              pack.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UnlockedStatusCard extends StatelessWidget {
  const _UnlockedStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C241B).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00FFA3).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.check,
              color: Color(0xFF00FFA3),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "✓ Premium Pack Unlocked",
                  style: TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    color: Color(0xFF00FFA3),
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "You have unlimited access to all practice questions and assessments.",
                  style: TextStyle(
                    fontFamily: 'Gilroy-Medium',
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedMetricsGrid extends StatelessWidget {
  final PrepPackDetailsModel pack;

  const _UnlockedMetricsGrid({required this.pack});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MetricGridItem(
        label: "Questions",
        value: "${pack.totalQuestions}",
        icon: Icons.quiz_outlined,
      ),
      _MetricGridItem(
        label: "Duration",
        value: "${pack.totalDurationMins}m",
        icon: Icons.timer_outlined,
      ),
      _MetricGridItem(
        label: "Attempts",
        value: "${pack.attempts}",
        icon: Icons.history,
      ),
      _MetricGridItem(
        label: "Passing Score",
        value: "${pack.passingScore.toInt()}%",
        icon: Icons.check_circle_outline,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.45,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return items[index];
      },
    );
  }
}

class _MetricGridItem extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricGridItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  State<_MetricGridItem> createState() => _MetricGridItemState();
}

class _MetricGridItemState extends State<_MetricGridItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0C241B).withValues(alpha: 0.3),
                const Color(0xFF030D0A).withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF00FFA3).withValues(alpha: 0.4)
                  : const Color(0xFF00FFA3).withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFA3).withValues(
                  alpha: _isHovered ? 0.08 : 0.02,
                ),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    widget.icon,
                    color: const Color(0xFF00FFA3),
                    size: 20,
                  ),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00FFA3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.value,
                    style: const TextStyle(
                      fontFamily: 'Gilroy-Bold',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontFamily: 'Gilroy-Medium',
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnlockedScoringSystem extends StatelessWidget {
  final PrepPackDetailsModel pack;

  const _UnlockedScoringSystem({required this.pack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ScoringCard(
            label: "Correct",
            value: "+${pack.markingScheme.correct.toInt()}",
            glowColor: const Color(0xFF00FFA3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ScoringCard(
            label: "Wrong",
            value: "-${pack.markingScheme.wrong.toInt()}",
            glowColor: Colors.orangeAccent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ScoringCard(
            label: "Negative",
            value: "-${pack.markingScheme.negative.toInt()}",
            glowColor: Colors.redAccent,
          ),
        ),
      ],
    );
  }
}

class _ScoringCard extends StatelessWidget {
  final String label;
  final String value;
  final Color glowColor;

  const _ScoringCard({
    required this.label,
    required this.value,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0C241B).withValues(alpha: 0.15),
            const Color(0xFF030D0A).withValues(alpha: 0.8),
          ],
        ),
        border: Border.all(
          color: glowColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Gilroy-Bold',
              color: glowColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: glowColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gilroy-Medium',
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedTargetCompanies extends StatelessWidget {
  final List<String> targetTags;

  const _UnlockedTargetCompanies({required this.targetTags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: targetTags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF0C241B).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF00FFA3).withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontFamily: 'Gilroy-Medium',
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _UnlockedAssessmentSections extends StatelessWidget {
  final PrepPackDetailsModel pack;

  const _UnlockedAssessmentSections({required this.pack});

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0A1410).withValues(alpha: 0.4),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.12),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Column(
          children: const [
            Icon(Icons.library_books, size: 48, color: Colors.white30),
            SizedBox(height: 14),
            Text(
              "📚 No Sections Available Yet",
              style: TextStyle(
                fontFamily: 'Gilroy-Bold',
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Assessment sections will appear here once available.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Gilroy-Medium',
                color: Colors.white30,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pack.sections.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pack.sections.length,
      itemBuilder: (context, index) {
        final sec = pack.sections[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _AssessmentCard(
            section: sec,
            markingScheme: pack.markingScheme,
          ),
        );
      },
    );
  }
}

class _AssessmentCard extends StatefulWidget {
  final PrepPackSectionModel section;
  final MarkingSchemeModel markingScheme;

  const _AssessmentCard({
    required this.section,
    required this.markingScheme,
  });

  @override
  State<_AssessmentCard> createState() => _AssessmentCardState();
}

class _AssessmentCardState extends State<_AssessmentCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isTapped ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FFA3).withValues(
                alpha: _isTapped ? 0.12 : 0.03,
              ),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                setState(() => _isTapped = true);
                await Future.delayed(const Duration(milliseconds: 150));
                setState(() => _isTapped = false);

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionScreen(
                        sectionTitle: widget.section.title,
                        questions: widget.section.questions,
                        markingScheme: widget.markingScheme,
                      ),
                    ),
                  );
                }
              },
              splashColor: const Color(0xFF00FFA3).withValues(alpha: 0.15),
              highlightColor: const Color(0xFF00FFA3).withValues(alpha: 0.05),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isTapped
                        ? const Color(0xFF00FFA3).withValues(alpha: 0.6)
                        : const Color(0xFF00FFA3).withValues(alpha: 0.15),
                    width: _isTapped ? 1.5 : 1.2,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isTapped
                        ? [
                            const Color(0xFF0F3B2E).withValues(alpha: 0.45),
                            const Color(0xFF041913).withValues(alpha: 0.9),
                          ]
                        : [
                            const Color(0xFF0C241B).withValues(alpha: 0.35),
                            const Color(0xFF030E0A).withValues(alpha: 0.85),
                          ],
                  ),
                ),
                child: Row(
                  children: [
                    // Glowing circular leading icon container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: _isTapped
                            ? const Color(0xFF00FFA3).withValues(alpha: 0.2)
                            : const Color(0xFF00FFA3).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isTapped
                              ? const Color(0xFF00FFA3).withValues(alpha: 0.7)
                              : const Color(0xFF00FFA3).withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FFA3).withValues(
                              alpha: _isTapped ? 0.35 : 0.08,
                            ),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: Color(0xFF00FFA3),
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 18),

                    // Section Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.section.title,
                            style: TextStyle(
                              fontFamily: 'Gilroy-Bold',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isTapped ? const Color(0xFF00FFA3) : Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${widget.section.questionsCount} Questions  •  ${widget.section.duration} Minutes",
                            style: TextStyle(
                              fontFamily: 'Gilroy-Medium',
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Playful action arrow indicator
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Start",
                          style: TextStyle(
                            fontFamily: 'Gilroy-Bold',
                            color: const Color(0xFF00FFA3),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Icon(
                          Icons.arrow_forward,
                          color: const Color(0xFF00FFA3),
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
