import 'package:flutter/material.dart';

import 'package:gyaanplant/viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'package:provider/provider.dart';

import 'package:gyaanplant/views/student_role/learn/widgets/course_progress_card.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/filter_chips.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/learning_header.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/search_input_field.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/sprint_banner_card.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCourses();
      }
    });
  }

  void _loadCourses() async {
    if (mounted) {
      context.read<LearningViewModel>().fetchCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: Consumer<LearningViewModel>(
        builder: (context, vm, child) {
          print(
            "🎯 UI REBUILDING - isLoading: ${vm.isLoading}, courses: ${vm.courses.length}",
          );

          if (vm.isLoading) {
            print("⏳ SHOWING LOADING INDICATOR");
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            print("❌ SHOWING ERROR: ${vm.errorMessage}");
            return Center(child: Text("Error: ${vm.errorMessage}"));
          }

          print("🎯 BUILDING UI WITH ${vm.courses.length} COURSES");

          return SingleChildScrollView(
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
                const SizedBox(height: 16),

                if (vm.courses.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.menu_book,
                            size: 50,
                            color: Colors.white38,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No courses available',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Explore courses to start learning',
                            style: TextStyle(color: Colors.white54),
                          ),
                          const SizedBox(height: 14),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C853),
                                ),
                                child: const Text(
                                  'Browse Courses',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: vm.courses.map((course) {
                        // Extract enrolled course IDs for comparison
                        final enrolledIds = vm.enrolledCourses
                            .map((e) => e.id)
                            .toSet();

                        print("🎯 BUILDING COURSE CARD: ${course.title}");
                        print("ENROLLED IDS: $enrolledIds");
                        print("COURSE ID: ${course.id}");
                        print(
                          "IS ENROLLED: ${enrolledIds.contains(course.id)}",
                        );

                        return CourseProgressCard(
                          courseId: course.id,
                          title: course.title,
                          subtitle: 'Modules: ${course.totalModules}',
                          percentText: '0%',
                          progressCount: '0/${course.totalModules}',
                          progress: 0.0,
                          progressColor: Colors.green,
                          tag: 'New',
                          tagColor: Colors.green,

                          // ✅ FIXED LOGIC
                          isEnrolled: enrolledIds.contains(course.id),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
