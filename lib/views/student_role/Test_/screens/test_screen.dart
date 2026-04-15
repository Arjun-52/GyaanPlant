import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/common_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/test_viewmodel.dart';

import 'package:gyaanplant/views/student_role/Test_/widgets/test_header.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/stats_row.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/timer_section.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/question_card.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/option_tile.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/filter_chip_test.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Move API call out of build method to prevent setState error
    Future.microtask(() {
      final vm = Provider.of<TestViewModel>(context, listen: false);
      if (vm.tests.isEmpty && !vm.isLoading) {
        vm.fetchTests();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TestViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF020B08),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const SizedBox(height: 20),

                  /// HEADER
                  const TestHeader(),

                  const SizedBox(height: 16),

                  /// FILTER CHIPS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChipTest(
                          label: "TCS",
                          isSelected: selectedIndex == 0,
                          onTap: () => setState(() => selectedIndex = 0),
                        ),
                        const SizedBox(width: 10),
                        FilterChipTest(
                          label: "Infosys",
                          isSelected: selectedIndex == 1,
                          onTap: () => setState(() => selectedIndex = 1),
                        ),
                        const SizedBox(width: 10),
                        FilterChipTest(
                          label: "Wipro",
                          isSelected: selectedIndex == 2,
                          onTap: () => setState(() => selectedIndex = 2),
                        ),
                        const SizedBox(width: 10),
                        FilterChipTest(
                          label: "Amazon",
                          isSelected: selectedIndex == 3,
                          onTap: () => setState(() => selectedIndex = 3),
                        ),
                        FilterChipTest(
                          label: "Accenture",
                          isSelected: selectedIndex == 4,
                          onTap: () => setState(() => selectedIndex = 4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// STATS (still static for now)
                  const StatsRow(),

                  const SizedBox(height: 20),

                  /// TEST CARD
                  Container(
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

                        /// QUESTION
                        vm.tests.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                      onPressed: () {
                                        // TODO: Navigate to assessment library
                                      },
                                      icon: const Icon(Icons.refresh),
                                      label: const Text("Refresh"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF00C853,
                                        ),
                                        foregroundColor: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : QuestionCard(question: vm.tests[0].title),

                        const SizedBox(height: 16),

                        /// OPTIONS (TEMPORARY)
                        if (vm.tests.isNotEmpty)
                          ...List.generate(4, (index) {
                            return OptionTile(
                              label: "Option ${index + 1}",
                              isSelected: vm.selectedOption == index,
                              onTap: () => vm.selectOption(index),
                            );
                          }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// NAV BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F2A22),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              "← Previous",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              "Next →",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ///  UPCOMING TESTS (DYNAMIC)
                  const Text(
                    "Upcoming Test Packs",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (vm.tests.isEmpty)
                    const Text(
                      "No tests available",
                      style: TextStyle(color: Colors.white54),
                    )
                  else
                    Column(
                      children: vm.tests.map((test) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F2A22),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                test.title,
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                test.skill,
                                style: const TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
      ),

      bottomNavigationBar: const CommonBottomNav(currentIndex: 2),
    );
  }
}
