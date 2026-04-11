import 'package:flutter/material.dart';
import 'package:gyaanplant/views/learn/widgets/course_progress_card.dart';
import 'package:gyaanplant/views/learn/widgets/filter_chips.dart';
import 'package:gyaanplant/core/common_widgets/common_bottom_nav.dart';

import 'package:gyaanplant/views/learn/widgets/learning_header.dart';
import 'package:gyaanplant/views/learn/widgets/search_input_field.dart';
import 'package:gyaanplant/views/learn/widgets/sprint_banner_card.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LearningHeader(),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SearchInputField(),
            ),

            const SizedBox(height: 12),

            FilterChips(),

            const SizedBox(height: 16),

            const SprintBannerCard(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1,
                shrinkWrap: true, // IMPORTANT
                physics: const NeverScrollableScrollPhysics(), // IMPORTANT
                children: const [],
              ),
            ),
            Column(
              children: [
                const CourseProgressCard(
                  title: "Data Structures & Algorithms",
                  subtitle: "TCS Pattern",
                  percentText: "68%",
                  progressCount: "24/35",
                  progress: 0.68,
                  progressColor: Colors.green,
                  tag: "Resume of progress",
                  tagColor: Colors.green,
                ),
                const CourseProgressCard(
                  title: "Quantitative Aptitude",
                  subtitle: "All Companies",
                  percentText: "45%",
                  progressCount: "8/18",
                  progress: 0.45,
                  progressColor: Colors.orange,
                  tag: "In Progress",
                  tagColor: Colors.orange,
                ),
                const CourseProgressCard(
                  title: "Core Java Programming",
                  subtitle: "Infosys + TCS",
                  percentText: "32%",
                  progressCount: "6/20",
                  progress: 0.32,
                  progressColor: Colors.blue,
                  tag: "New",
                  tagColor: Colors.blue,
                ),
                const CourseProgressCard(
                  title: "Verbal Communication & GD",
                  subtitle: "HR Rounds",
                  percentText: "70%",
                  progressCount: "14/20",
                  progress: 0.70,
                  progressColor: Colors.green,
                  tag: "In Progress",
                  tagColor: Colors.orange,
                ),

                const CourseProgressCard(
                  title: "DBMS & SQL Fundamentals",
                  subtitle: "Wipro + HCL",
                  percentText: "88%",
                  progressCount: "17/20",
                  progress: 0.88,
                  progressColor: Colors.green,
                  tag: "Nearly done",
                  tagColor: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: currentIndex),
    );
  }
}
