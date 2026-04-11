import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/common_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/test_viewmodel.dart';

import 'package:gyaanplant/views/student_role/Test_/widgets/test_header.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/stats_row.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/timer_section.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/question_card.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/option_tile.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/upcoming_tests.dart';
import 'package:gyaanplant/views/student_role/Test_/widgets/filter_chip_test.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TestViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // HEADER
            const TestHeader(),

            const SizedBox(height: 16),

            //  FILTER CHIPS
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

            // STATS
            const StatsRow(),

            const SizedBox(height: 20),

            // TIMER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF031E17),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00C853), width: 1),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853).withValues(alpha: 0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  TIMER
                  const TimerSection(),

                  const SizedBox(height: 16),

                  // QUESTION
                  const QuestionCard(),

                  const SizedBox(height: 16),

                  // OPTIONS
                  OptionTile(
                    label: "A  VZDQ",
                    isSelected: vm.selectedOption == 0,
                    onTap: () => vm.selectOption(0),
                  ),
                  OptionTile(
                    label: "B  VZDP",
                    isSelected: vm.selectedOption == 1,
                    onTap: () => vm.selectOption(1),
                  ),
                  OptionTile(
                    label: "C  VZEQ",
                    isSelected: vm.selectedOption == 2,
                    onTap: () => vm.selectOption(2),
                  ),
                  OptionTile(
                    label: "D  VBDP",
                    isSelected: vm.selectedOption == 3,
                    onTap: () => vm.selectOption(3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // NAV BUTTONS
            Row(
              children: [
                //  PREVIOUS BUTTON
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2A22),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {},
                      child: const Center(
                        child: Text(
                          "← Previous",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                //  NEXT BUTTON
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {},
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
                ),
              ],
            ),

            const SizedBox(height: 20),

            //  UPCOMING TESTS
            const UpcomingTests(),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 2),
    );
  }
}
