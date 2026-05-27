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

class _TestScreenState extends State<TestScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<TestViewModel>().fetchTests();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TestViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: RefreshIndicator(
        color: const Color(0xFF00C853),
        backgroundColor: const Color(0xFF020B08),
        onRefresh: () => vm.fetchTests(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: vm.isLoading
              ? const _TestShimmer()
              : vm.errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 50, color: Colors.white38),
                          const SizedBox(height: 12),
                          Text(
                            vm.errorMessage ?? "An error occurred",
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => vm.fetchTests(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 20),

                        /// HEADER
                        const TestHeader(),

                        const SizedBox(height: 16),

                        /// FILTER CHIPS
                        if (vm.companies.isNotEmpty)
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: vm.companies.map((company) {
                              return FilterChipTest(
                                label: company.name,
                                isSelected: vm.selectedCompany == company.name,
                                onTap: () {
                                  vm.selectCompany(company.name);
                                },
                              );
                            }).toList(),
                          ),


                        /// STATS
                        const StatsRow(),

                        const SizedBox(height: 20),

                        /// TEST CARD
                        _buildAssessmentCard(vm),

                        const SizedBox(height: 20),

                        /// NAV BUTTONS
                        _buildNavigationButtons(vm),

                        const SizedBox(height: 20),

                        /// AVAILABLE TESTS
                        const Text(
                          "Available Tests",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// SEARCH BAR & FILTERS
                        _buildSearchAndFilters(context, vm),

                        const SizedBox(height: 16),

                        _buildAvailableTestsSection(vm),

                        const SizedBox(height: 24),

                        /// PREP PACKS SECTION
                        const Text(
                          'Prep Packs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildPrepPacksSection(vm),

                        const SizedBox(height: 40),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildAssessmentCard(TestViewModel vm) {
    final hasAssessment = vm.currentAssessment?.hasAssessment == true;
    final hasAvailable = vm.availableTests.isNotEmpty;

    if (!hasAssessment && !hasAvailable) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF031E17),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00C853).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.quiz_outlined,
                size: 50,
                color: Colors.white38,
              ),
              const SizedBox(height: 12),
              const Text(
                "No assessments available",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                "Assessments will appear here once available",
                style: TextStyle(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => vm.fetchTests(),
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF031E17),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00C853),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TimerSection(),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF00C853),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          QuestionCard(question: title),
          const SizedBox(height: 16),

          /// OPTIONS
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
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: isFirst ? Colors.white10 : const Color(0xFF0F2A22),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFirst ? Colors.transparent : const Color(0xFF00C853).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  "← Previous",
                  style: TextStyle(
                    color: isFirst ? Colors.white24 : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
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
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: isLast ? Colors.white10 : const Color(0xFF00C853),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  "Next →",
                  style: TextStyle(
                    color: isLast ? Colors.white24 : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableTestsSection(TestViewModel vm) {
    final problemsList = vm.filteredProblems;

    if (vm.isProblemsLoading && vm.problems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
          ),
        ),
      );
    }

    if (problemsList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            "No tests available",
            style: TextStyle(color: Colors.white38, fontSize: 14),
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
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: vm.currentPage > 1
                      ? () => vm.changeProblemsPage(vm.currentPage - 1)
                      : null,
                  icon: const Icon(Icons.arrow_back_ios_new, size: 16),
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
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  color: const Color(0xFF00C853),
                  disabledColor: Colors.white24,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProblemCard(BuildContext context, ProblemModel problem) {
    Color difficultyColor;
    switch (problem.difficulty.toLowerCase()) {
      case 'easy':
        difficultyColor = Colors.green;
        break;
      case 'medium':
        difficultyColor = Colors.orange;
        break;
      case 'hard':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2A22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00C853).withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Difficulty and Points badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: difficultyColor.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  problem.difficulty.toUpperCase(),
                  style: TextStyle(
                    color: difficultyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withValues(alpha: 0.15),
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
          const SizedBox(height: 12),

          // Title
          Text(
            problem.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            problem.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),

          // Tags Row
          if (problem.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: problem.tags.map((tag) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Divider
          Container(
            height: 0.8,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 12),

          // Metadata row: cases, solved state
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${problem.totalTestCases} / ${problem.totalTestCases} CASES",
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    problem.solved ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: problem.solved ? const Color(0xFF00E676) : Colors.white30,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    problem.solved ? "Solved ✓" : "Unsolved",
                    style: TextStyle(
                      color: problem.solved ? const Color(0xFF00E676) : Colors.white30,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress line
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Progress", style: TextStyle(color: Colors.white54, fontSize: 11)),
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
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: problem.solved ? 1.0 : 0.0,
                  minHeight: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF00E676)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Start Solving / Solved button
          Builder(builder: (context) {
            final vm = context.read<TestViewModel>();
            final isSolved = problem.solved || vm.localSolvedIds.contains(problem.id);

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
                  // Immediately mark solved locally so the card flips right away
                  context.read<TestViewModel>().markSolved(problem.id);
                }
                // Also refresh backend list in background
                context.read<TestViewModel>().fetchProblems(page: 1);
              }
            }

            return SizedBox(
              width: double.infinity,
              height: 44,
              child: isSolved
                  ? Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: const Color(0xFF00E676), width: 1),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: openProblem,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle,
                                size: 16, color: Color(0xFF00E676)),
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
                  : ElevatedButton(
                      onPressed: openProblem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Start Solving",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, TestViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2A22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00C853).withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white38, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "Find a challenge...",
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (val) {
                          vm.setSearchQuery(val);
                        },
                        onSubmitted: (val) {
                          vm.searchProblems(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  vm.searchProblems(_searchController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: const Color(0xFF00E676),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF00C853), width: 1.2),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  "SEARCH",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Difficulty chips row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['ALL', 'EASY', 'MEDIUM', 'HARD'].map((diff) {
              final isSelected = vm.selectedDifficulty == diff;
              return Container(
                margin: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    vm.setSelectedDifficulty(diff);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00C853) : const Color(0xFF0F2A22),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00C853) : const Color(0xFF00C853).withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        diff,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
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

  Widget _buildPrepPacksSection(TestViewModel vm) {
    if (vm.isPrepPacksLoading && vm.packs.isEmpty) {
      return const _PrepPacksShimmer();
    }

    if (vm.errorMessage != null && vm.packs.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 40, color: Colors.white38),
            const SizedBox(height: 8),
            const Text("Failed to load prep packs", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => vm.fetchPrepPacks(page: 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.black,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (vm.packs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            "No preparation packs available",
            style: TextStyle(color: Colors.white38, fontSize: 14),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: vm.currentPrepPackPage > 1
                      ? () => vm.changePrepPacksPage(vm.currentPrepPackPage - 1)
                      : null,
                  icon: const Icon(Icons.arrow_back_ios_new, size: 16),
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
                      ? () => vm.changePrepPacksPage(vm.currentPrepPackPage + 1)
                      : null,
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  color: const Color(0xFF00C853),
                  disabledColor: Colors.white24,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TestShimmer extends StatefulWidget {
  const _TestShimmer();

  @override
  State<_TestShimmer> createState() => _TestShimmerState();
}

class _TestShimmerState extends State<_TestShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
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
        final opacity = 0.3 + (_controller.value * 0.35);
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header placeholder
              Opacity(
                opacity: opacity,
                child: Container(
                  width: 200,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Chips placeholder
              Opacity(
                opacity: opacity,
                child: Row(
                  children: List.generate(
                    3,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 80,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Stats placeholder
              Opacity(
                opacity: opacity,
                child: Row(
                  children: List.generate(
                    4,
                    (index) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Quiz Card placeholder
              Opacity(
                opacity: opacity,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PrepPacksShimmer extends StatefulWidget {
  const _PrepPacksShimmer();

  @override
  State<_PrepPacksShimmer> createState() => _PrepPacksShimmerState();
}

class _PrepPacksShimmerState extends State<_PrepPacksShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
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
        final opacity = 0.3 + (_controller.value * 0.35);
        return Column(
          children: List.generate(
            2,
            (index) => Opacity(
              opacity: opacity,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
