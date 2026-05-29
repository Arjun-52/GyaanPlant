import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/test_viewmodel.dart';
import 'package:gyaanplant/models/assessment/problem_model.dart';
import 'package:gyaanplant/views/student_role/Test_/screens/problem_details_screen.dart';

import 'package:gyaanplant/views/student_role/Test_/widgets/test_header.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/stats_row.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/timer_section.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/question_card.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/option_tile.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/filter_chip_test.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/test_pack_card.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchFocused = false;

  // Staggered entrance animations (matching dashboard pattern)
  late final AnimationController _staggerCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  // Shimmer pulse for loading
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Stagger controller
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    const sectionCount = 8;
    _fadeAnims = List.generate(sectionCount, (index) {
      final double start = index * 0.08;
      final double end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(sectionCount, (index) {
      final double start = index * 0.08;
      final double end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0.0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.fastOutSlowIn),
        ),
      );
    });

    // Shimmer pulse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.45, end: 0.75).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Focus listener for search glow
    _searchFocus.addListener(() {
      setState(() => _isSearchFocused = _searchFocus.hasFocus);
    });

    Future.microtask(() {
      if (mounted) {
        context.read<TestViewModel>().fetchTests().then((_) {
          if (mounted) _staggerCtrl.forward(from: 0.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _staggerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Widget _staggeredSection(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[index],
      child: SlideTransition(
        position: _slideAnims[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TestViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: Stack(
        children: [
          // ── Ambient Background (matching dashboard) ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF02120F), Color(0xFF020907)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0A00E676),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x0800E676),
                ),
              ),
            ),
          ),

          // ── Main Content ──
          SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFF00C853),
              backgroundColor: const Color(0xFF020B08),
              onRefresh: () async {
                await vm.fetchTests();
                if (mounted) _staggerCtrl.forward(from: 0.0);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: vm.isLoading
                    ? _buildSkeletonLoader()
                    : vm.errorMessage != null
                        ? _buildErrorState(vm)
                        : _buildContent(vm),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────── CONTENT ──────────────────────

  Widget _buildContent(TestViewModel vm) {
    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        const SizedBox(height: 20),

        /// HEADER
        _staggeredSection(0, const TestHeader()),
        const SizedBox(height: 16),

        /// FILTER CHIPS
        if (vm.companies.isNotEmpty)
          _staggeredSection(
            1,
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: vm.companies.map((company) {
                return FilterChipTest(
                  label: company.name,
                  isSelected: vm.selectedCompany == company.name,
                  onTap: () => vm.selectCompany(company.name),
                );
              }).toList(),
            ),
          ),

        /// STATS
        _staggeredSection(2, const StatsRow()),
        const SizedBox(height: 20),

        /// TEST CARD
        _staggeredSection(3, _buildAssessmentCard(vm)),
        const SizedBox(height: 20),

        /// NAV BUTTONS
        _staggeredSection(4, _buildNavigationButtons(vm)),
        const SizedBox(height: 24),

        /// AVAILABLE TESTS TITLE
        _staggeredSection(
          5,
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00E676).withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Available Tests",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        /// SEARCH BAR & FILTERS
        _staggeredSection(6, _buildSearchAndFilters(context, vm)),
        const SizedBox(height: 16),

        _buildAvailableTestsSection(vm),
        const SizedBox(height: 28),

        /// PREP PACKS TITLE
        _staggeredSection(
          7,
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00E676).withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Prep Packs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        _buildPrepPacksSection(vm),
        const SizedBox(height: 40),
      ],
    );
  }

  // ────────────────────── ERROR STATE ──────────────────────

  Widget _buildErrorState(TestViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 1,
              ),
            ),
            child: const Icon(Icons.cloud_off_rounded,
                size: 44, color: Colors.white30),
          ),
          const SizedBox(height: 20),
          Text(
            vm.errorMessage ?? "An error occurred",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildPremiumButton(
            label: "Retry",
            icon: Icons.refresh_rounded,
            onTap: () => vm.fetchTests(),
          ),
        ],
      ),
    );
  }

  // ────────────────────── ASSESSMENT CARD ──────────────────────

  Widget _buildAssessmentCard(TestViewModel vm) {
    final hasAssessment = vm.currentAssessment?.hasAssessment == true;
    final hasAvailable = vm.availableTests.isNotEmpty;

    if (!hasAssessment && !hasAvailable) {
      return _buildEmptyAssessmentCard(vm);
    }

    String title = "";
    String subtitle = "";

    if (hasAssessment) {
      final curr = vm.currentAssessment!;
      title = curr.title ?? "Aptitude Round";
      subtitle = "Question ${curr.questionNumber} of ${curr.totalQuestions}";
    } else {
      final activeTest = vm.availableTests[vm.currentTestIndex];
      title = activeTest.title;
      subtitle = "${activeTest.questions} questions • ${activeTest.duration}";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C2A1F), Color(0xFF071A14)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Color(0xFF00C853).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00E676).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TimerSection(),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF00E676),
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          QuestionCard(question: title),
          const SizedBox(height: 16),
          ...List.generate(4, (index) {
            return OptionTile(
              label: "Option ${index + 1}",
              isSelected: vm.selectedOption == index,
              onTap: () => vm.selectOption(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyAssessmentCard(TestViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C2A1F), Color(0xFF071A14)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Color(0xFF00C853).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated pulsing icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.9, end: 1.1),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              // Restart the animation by using a key trick
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF00E676).withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Icon(
                Icons.quiz_outlined,
                size: 48,
                color: Color(0xFF00E676),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No assessments available",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Assessments will appear here once available",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildPremiumButton(
            label: "Refresh",
            icon: Icons.refresh_rounded,
            onTap: () => vm.fetchTests(),
          ),
        ],
      ),
    );
  }

  // ────────────────────── NAVIGATION BUTTONS ──────────────────────

  Widget _buildNavigationButtons(TestViewModel vm) {
    final showNav = vm.availableTests.isNotEmpty;
    if (!showNav) return const SizedBox.shrink();

    final isFirst = vm.currentTestIndex == 0;
    final isLast = vm.currentTestIndex == vm.availableTests.length - 1;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: isFirst ? null : () => vm.previousTest(),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 52,
              decoration: BoxDecoration(
                gradient: isFirst
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF0C241E), Color(0xFF0F2A22)],
                      ),
                color: isFirst ? Colors.white.withOpacity(0.04) : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFirst
                      ? Colors.transparent
                      : Color(0xFF00C853).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios_rounded,
                        size: 14,
                        color: isFirst ? Colors.white24 : Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      "Previous",
                      style: TextStyle(
                        color: isFirst ? Colors.white24 : Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: InkWell(
            onTap: isLast ? null : () => vm.nextTest(),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 52,
              decoration: BoxDecoration(
                gradient: isLast
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF00E676), Color(0xFF00C853)],
                      ),
                color: isLast ? Colors.white.withOpacity(0.04) : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isLast
                    ? []
                    : [
                        BoxShadow(
                          color: Color(0xFF00E676).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Next",
                      style: TextStyle(
                        color: isLast ? Colors.white24 : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: isLast ? Colors.white24 : Colors.black87),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────── AVAILABLE TESTS ──────────────────────

  Widget _buildAvailableTestsSection(TestViewModel vm) {
    final problemsList = vm.filteredProblems;

    if (vm.isProblemsLoading && vm.problems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
              strokeWidth: 2.5,
              backgroundColor: Color(0xFF00C853).withOpacity(0.15),
            ),
          ),
        ),
      );
    }

    if (problemsList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_rounded,
                  size: 36,
                  color: Colors.white.withOpacity(0.15)),
              const SizedBox(height: 10),
              const Text(
                "No tests available",
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: problemsList.length,
          itemBuilder: (context, index) {
            final problem = problemsList[index];
            return _buildProblemCard(context, problem);
          },
        ),
        if (vm.totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: vm.currentPage > 1
                        ? () => vm.changeProblemsPage(vm.currentPage - 1)
                        : null,
                    icon:
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                    color: const Color(0xFF00C853),
                    disabledColor: Colors.white24,
                  ),
                  Text(
                    "Page ${vm.currentPage} of ${vm.totalPages}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: vm.currentPage < vm.totalPages
                        ? () => vm.changeProblemsPage(vm.currentPage + 1)
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    color: const Color(0xFF00C853),
                    disabledColor: Colors.white24,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ────────────────────── PROBLEM CARD ──────────────────────

  Widget _buildProblemCard(BuildContext context, ProblemModel problem) {
    Color difficultyColor;
    IconData difficultyIcon;
    switch (problem.difficulty.toLowerCase()) {
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
      default:
        difficultyColor = const Color(0xFF00E676);
        difficultyIcon = Icons.speed_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C241E), Color(0xFF081A14)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Color(0xFF00C853).withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Green accent bar on left
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      difficultyColor.withOpacity(0.8),
                      difficultyColor.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
              // Card content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
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
                                    size: 11, color: difficultyColor),
                                const SizedBox(width: 4),
                                Text(
                                  problem.difficulty.toUpperCase(),
                                  style: TextStyle(
                                    color: difficultyColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "+${problem.points}",
                              style: const TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        problem.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Description
                      Text(
                        problem.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tags
                      if (problem.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: problem.tags.map((tag) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white
                                          .withOpacity(0.06),
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
                          ),
                        ),

                      // Gradient divider
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
                      const SizedBox(height: 12),

                      // Metadata
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${problem.totalTestCases} / ${problem.totalTestCases} CASES",
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                problem.solved
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: problem.solved
                                    ? const Color(0xFF00E676)
                                    : Colors.white30,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                problem.solved ? "Solved ✓" : "Unsolved",
                                style: TextStyle(
                                  color: problem.solved
                                      ? const Color(0xFF00E676)
                                      : Colors.white30,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Progress bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Progress",
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 11)),
                              Text(
                                problem.solved ? "100%" : "0%",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: problem.solved ? 1.0 : 0.0,
                              minHeight: 5,
                              backgroundColor:
                                  Colors.white.withOpacity(0.08),
                              valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFF00E676)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Action button
                      Builder(builder: (context) {
                        final vm = context.read<TestViewModel>();
                        final isSolved = problem.solved ||
                            vm.localSolvedIds.contains(problem.id);

                        Future<void> openProblem() async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProblemDetailsScreen(problemId: problem.id),
                            ),
                          );
                          if (context.mounted) {
                            if (result == true) {
                              context
                                  .read<TestViewModel>()
                                  .markSolved(problem.id);
                            }
                            context
                                .read<TestViewModel>()
                                .fetchProblems(page: 1);
                          }
                        }

                        return SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: isSolved
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B5E20),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFF00E676),
                                        width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00E676)
                                            .withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: openProblem,
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle_rounded,
                                            size: 16,
                                            color: Color(0xFF00E676)),
                                        SizedBox(width: 6),
                                        Text(
                                          "Solved ✓",
                                          style: TextStyle(
                                            color: Color(0xFF00E676),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00E676),
                                        Color(0xFF00C853),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00E676)
                                            .withOpacity(0.25),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: openProblem,
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Start Solving",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Icon(Icons.arrow_forward_rounded,
                                              size: 16, color: Colors.black87),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────── SEARCH & FILTERS ──────────────────────

  Widget _buildSearchAndFilters(BuildContext context, TestViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar row
        Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0C241E), Color(0xFF0F2A22)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isSearchFocused
                        ? Color(0xFF00C853).withOpacity(0.5)
                        : Color(0xFF00C853).withOpacity(0.12),
                    width: _isSearchFocused ? 1.5 : 1,
                  ),
                  boxShadow: _isSearchFocused
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00E676)
                                .withOpacity(0.1),
                            blurRadius: 16,
                            spreadRadius: 0,
                          ),
                        ]
                      : [],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: _isSearchFocused
                          ? const Color(0xFF00E676)
                          : Colors.white38,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "Find a challenge...",
                          hintStyle:
                              TextStyle(color: Colors.white38, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (val) => vm.setSearchQuery(val),
                        onSubmitted: (val) => vm.searchProblems(val),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0C241E), Color(0xFF0A1F19)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Color(0xFF00C853).withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () =>
                        vm.searchProblems(_searchController.text),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Center(
                        child: Text(
                          "SEARCH",
                          style: TextStyle(
                            color: Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Difficulty chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['ALL', 'EASY', 'MEDIUM', 'HARD'].map((diff) {
              final isSelected = vm.selectedDifficulty == diff;
              return Container(
                margin: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => vm.setSelectedDifficulty(diff),
                  child: AnimatedScale(
                    scale: isSelected ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF00E676),
                                  Color(0xFF00C853),
                                ],
                              )
                            : null,
                        color: isSelected ? null : const Color(0xFF0A1F19),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFF00C853)
                                  .withOpacity(0.12),
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF00E676)
                                      .withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          diff,
                          style: TextStyle(
                            color: isSelected ? Colors.black87 : Colors.white60,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ────────────────────── PREP PACKS ──────────────────────

  Widget _buildPrepPacksSection(TestViewModel vm) {
    if (vm.isPrepPacksLoading && vm.packs.isEmpty) {
      return _PrepPacksShimmer(pulseAnim: _pulseAnim);
    }

    if (vm.errorMessage != null && vm.packs.isEmpty) {
      return Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  size: 36, color: Colors.white30),
            ),
            const SizedBox(height: 12),
            const Text("Failed to load prep packs",
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            _buildPremiumButton(
              label: "Retry",
              icon: Icons.refresh_rounded,
              onTap: () => vm.fetchPrepPacks(page: 1),
            ),
          ],
        ),
      );
    }

    if (vm.packs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 36,
                  color: Colors.white.withOpacity(0.15)),
              const SizedBox(height: 10),
              const Text(
                "No preparation packs available",
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vm.packs.length,
          itemBuilder: (context, index) {
            final pack = vm.packs[index];
            return TestPackCard(
              pack: pack,
              onReturn: () => vm.fetchPrepPacks(page: vm.currentPrepPackPage),
            );
          },
        ),
        if (vm.totalPrepPackPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: vm.currentPrepPackPage > 1
                        ? () => vm.changePrepPacksPage(
                            vm.currentPrepPackPage - 1)
                        : null,
                    icon:
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                    color: const Color(0xFF00C853),
                    disabledColor: Colors.white24,
                  ),
                  Text(
                    "Page ${vm.currentPrepPackPage} of ${vm.totalPrepPackPages}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: vm.currentPrepPackPage < vm.totalPrepPackPages
                        ? () => vm.changePrepPacksPage(
                            vm.currentPrepPackPage + 1)
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    color: const Color(0xFF00C853),
                    disabledColor: Colors.white24,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ────────────────────── SHARED WIDGETS ──────────────────────

  Widget _buildPremiumButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00E676), Color(0xFF00C853)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00E676).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────── SKELETON LOADER ──────────────────────

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBlock(height: 60, radius: 16),
          const SizedBox(height: 16),
          _skeletonBlock(height: 44, radius: 24, width: 280),
          const SizedBox(height: 18),
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 3 ? 0 : 8),
                  child: _skeletonBlock(height: 90, radius: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _skeletonBlock(height: 200, radius: 22),
          const SizedBox(height: 18),
          _skeletonBlock(height: 52, radius: 16),
          const SizedBox(height: 24),
          _skeletonBlock(height: 28, radius: 8, width: 160),
          const SizedBox(height: 16),
          _skeletonBlock(height: 50, radius: 14),
          const SizedBox(height: 16),
          _skeletonBlock(height: 200, radius: 18),
        ],
      ),
    );
  }

  Widget _skeletonBlock(
      {required double height, required double radius, double? width}) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Opacity(
          opacity: _pulseAnim.value,
          child: Container(
            height: height,
            width: width ?? double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: const LinearGradient(
                colors: [Color(0xFF0C241E), Color(0xFF02100C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Color(0xFF00E676).withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════
//  PREP PACKS SHIMMER (accepts pulse animation from parent)
// ════════════════════════════════════════════════════════════

class _PrepPacksShimmer extends StatelessWidget {
  final Animation<double> pulseAnim;

  const _PrepPacksShimmer({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, child) {
        final opacity = pulseAnim.value;
        return Column(
          children: List.generate(
            2,
            (index) => Opacity(
              opacity: opacity,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 220,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0C241E), Color(0xFF02100C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(0xFF00E676).withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
