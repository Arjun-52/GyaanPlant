import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'package:provider/provider.dart';

import '../widgets/course_card.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<LearningViewModel>().fetchMyCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LearningViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: const Text("My Courses", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.enrollments.isEmpty
          ? const Center(
              child: Text(
                "No enrolled courses",
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.enrollments.length,
              itemBuilder: (context, index) {
                final enrollment = vm.enrollments[index];
                final course = enrollment.course;
                final progress = enrollment.progress ?? 0;

                return CourseCard(
                  title: course.title,
                  modules: course.totalModules,
                  progress: progress.toDouble(),
                );
              },
            ),
    );
  }
}
