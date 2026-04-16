import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/HOD_bottom_nav.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/hod_viewmodel.dart';
import 'package:gyaanplant/views/HOD_role/overview/widgets/dept_progress_card.dart';
import 'package:gyaanplant/views/HOD_role/overview/widgets/stat_card.dart';
import 'package:gyaanplant/views/HOD_role/overview/widgets/syllabus_card.dart';
import 'package:provider/provider.dart';

class OverViewScreen extends StatelessWidget {
  const OverViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HodViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFF061A14),

        body: Consumer<HodViewModel>(
          builder: (context, vm, _) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),

                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0A1F3D), Color(0xFF071E17)],
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Principal Dashboard",
                            style: TextStyle(color: Colors.white54),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            "GRIET Hyderabad 🏛",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.2,
                            children: const [
                              HodStatCard(
                                value: "2,847",
                                label: "Total Students",
                                color: Colors.blue,
                              ),
                              HodStatCard(
                                value: "6",
                                label: "Departments",
                                color: Colors.blue,
                              ),
                              HodStatCard(
                                value: "73%",
                                label: "LMS Adoption",
                                color: Colors.green,
                              ),
                              HodStatCard(
                                value: "A+",
                                label: "NAAC Grade",
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          /// DEPT READINESS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Dept-wise Skill Readiness",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Detail",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          DeptProgressCard(departments: vm.departments),

                          const SizedBox(height: 20),

                          /// SYLLABUS
                          const Text(
                            "Syllabus Mapping Status",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const SyllabusCard(
                            title: "CSE — GyaanPlant Courses",
                            subtitle: "8/10 courses mapped to electives",
                            progress: 8,
                          ),

                          const SizedBox(height: 12),

                          const SyllabusCard(
                            title: "IT — GyaanPlant Courses",
                            subtitle: "6/8 courses mapped to electives",
                            progress: 6,
                          ),
                          const SizedBox(height: 12),
                          const SyllabusCard(
                            title: "ECE — GyaanPlant Courses",
                            subtitle: "3/10 courses mapped to electives",
                            progress: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        bottomNavigationBar: HODBottomNav(currentIndex: 0),
      ),
    );
  }
}
