import 'package:flutter/material.dart';
import '../../../../data/services/api_service.dart';
import '../../../../models/learning/learning_model.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final _learning = ApiService().learning;

  CourseModel? course;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchCourse();
  }

  Future<void> _fetchCourse() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      course = await _learning.getCourseById(widget.courseId);
      print(" COURSE TITLE: ${course?.title}");
    } catch (e) {
      error = e.toString();
      print(" ERROR FETCHING COURSE: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("All Courses", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C853)),
            )
          : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading course",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                    ),
                    child: const Text(
                      "Retry",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            )
          : course == null
          ? const Center(
              child: Text(
                "Course not found",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    course!.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Info cards
                  Row(
                    children: [
                      _infoCard("Modules", "${course!.totalModules}"),
                      const SizedBox(width: 10),
                      _infoCard("Duration", "${course!.durationMins}m"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _infoCard("Points", "50"),
                      const SizedBox(width: 10),
                      _infoCard("XP", "100"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Curriculum
                  _sectionCard(
                    title: "Curriculum Overview",
                    child: Column(
                      children: const [
                        ListTile(
                          leading: Icon(Icons.lock, color: Colors.white),
                          title: Text(
                            "Intro",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "10 mins",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Requirements
                  _sectionCard(
                    title: "Requirements",
                    child: Column(
                      children: const [
                        _rowItem("Passing Score", "70%"),
                        _rowItem("Target Audience", "Student"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Students
                  _sectionCard(
                    title: "Enrolled Students",
                    child: const Text(
                      "0 Learners",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Price + enroll
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "PRICE",
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course!.category ?? "Free",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                            ),
                            child: const Text(
                              "ENROLL NOW",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _rowItem extends StatelessWidget {
  final String title;
  final String value;

  const _rowItem(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
