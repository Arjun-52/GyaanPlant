import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/test_viewmodel.dart';

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
                          )
                        else
                          const Text(
                            "No filters available",
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                          ),

                        const SizedBox(height: 20),

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

                        const SizedBox(height: 12),

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
    if (vm.availableTests.isEmpty) {
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.availableTests.length,
      itemBuilder: (context, index) {
        final test = vm.availableTests[index];
        final isActive = vm.currentTestIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F2A22),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? const Color(0xFF00C853) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${test.questions} questions • ${test.duration}",
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isActive ? const Color(0xFF00C853) : Colors.white54,
                size: 16,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrepPacksSection(TestViewModel vm) {
    if (vm.packs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: const [
              Icon(
                Icons.quiz,
                size: 50,
                color: Colors.white38,
              ),
              const SizedBox(height: 12),
              Text(
                'No test packs available',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Check back later for new test packs',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: vm.packs.map((pack) {
        return TestPackCard(pack: pack);
      }).toList(),
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
