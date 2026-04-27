import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'package:gyaanplant/services/student_services/local_storage_service.dart';
import 'package:provider/provider.dart';

import 'package:gyaanplant/core/common_widgets/common_bottom_nav.dart';

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
    loadEnrollments();
  }

  void loadEnrollments() async {
    final token = await LocalStorageService.getToken();
    if (token != null && mounted) {
      final vm = Provider.of<LearningViewModel>(context, listen: false);
      vm.fetchEnrollments(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),

      body: Consumer<LearningViewModel>(
        builder: (context, vm, child) {
          print("UI RECEIVED IN LEARN: ${vm.enrollments}");
          print("UI ENROLLMENTS COUNT IN LEARN: ${vm.enrollments.length}");

          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

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

                ///  EMPTY STATE
                if (vm.enrollments.isEmpty)
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
                            "No courses available",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "Explore courses to start learning",
                            style: TextStyle(color: Colors.white54),
                          ),

                          const SizedBox(height: 14),

                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                            ),
                            child: Text(
                              "Browse Courses",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                /// COURSES LIST
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: vm.enrollments.map((enrollment) {
                      final course = enrollment['course'] ?? {};
                      return CourseProgressCard(
                        title: course['title'] ?? 'Unknown Course',
                        subtitle: "Modules: ${course['totalModules'] ?? 0}",

                        // Temporary values (backend doesn't give progress yet)
                        percentText: "0%",
                        progressCount: "0/${course['totalModules'] ?? 0}",
                        progress: 0.0,

                        progressColor: Colors.green,
                        tag: "New",
                        tagColor: Colors.green,
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

      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }
}
