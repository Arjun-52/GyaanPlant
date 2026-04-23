import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/HOD_bottom_nav.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/hod_dashboard_viewmodel.dart';
import 'package:gyaanplant/views/HOD_role/overview/widgets/dept_progress_card.dart';
import 'package:gyaanplant/views/HOD_role/overview/widgets/stat_card.dart';
import 'package:gyaanplant/views/HOD_role/overview/widgets/syllabus_card.dart';
import 'package:provider/provider.dart';

class OverViewScreen extends StatelessWidget {
  final String token;
  const OverViewScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HodDashboardViewModel()..loadDashboard(token),
      child: Scaffold(
        backgroundColor: const Color(0xFF061A14),

        body: Consumer<HodDashboardViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (vm.error != null) {
              return Center(
                child: Text(vm.error!, style: TextStyle(color: Colors.red)),
              );
            }

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
                          Text(
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
                            children: [
                              HodStatCard(
                                value: vm.totalStudents.toString(),
                                label: "Total Students",
                                color: Colors.blue,
                              ),
                              HodStatCard(
                                value: vm.departments.toString(),
                                label: "Departments",
                                color: Colors.blue,
                              ),
                              HodStatCard(
                                value: "${vm.lmsAdoption}%",
                                label: "LMS Adoption",
                                color: Colors.green,
                              ),
                              HodStatCard(
                                value: vm.naacGrade,
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
                            children: [
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

                          DeptProgressCard(
                            departments: vm.departmentsData
                                .map(
                                  (dept) => {
                                    'name': dept.name,
                                    'percent': dept.value,
                                  },
                                )
                                .toList(),
                          ),

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
