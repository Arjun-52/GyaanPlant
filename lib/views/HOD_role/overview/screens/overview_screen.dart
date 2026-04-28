import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/hod_dashboard_viewmodel.dart';
import 'package:gyaanplant/views/HOD_role/overview/widgets/dept_progress_card.dart';
import 'package:gyaanplant/views/HOD_role/overview/widgets/stat_card.dart';
import 'package:gyaanplant/views/HOD_role/overview/widgets/syllabus_card.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class OverViewScreen extends StatefulWidget {
  const OverViewScreen({super.key});

  @override
  State<OverViewScreen> createState() => _OverViewScreenState();
}

class _OverViewScreenState extends State<OverViewScreen> {
  late final HodDashboardViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = HodDashboardViewModel();
    _vm.loadDashboard();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Scaffold(
        backgroundColor: const Color(0xFF061A14),
        body: Consumer<HodDashboardViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to Load Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vm.error!,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: vm.loadDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
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
                          const Text(
                            'Principal Dashboard',
                            style: TextStyle(color: Colors.white54),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'GRIET Hyderabad',
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
                                label: 'Total Students',
                                color: Colors.blue,
                              ),
                              HodStatCard(
                                value: vm.departments.toString(),
                                label: 'Departments',
                                color: Colors.blue,
                              ),
                              HodStatCard(
                                value: '${vm.lmsAdoption}%',
                                label: 'LMS Adoption',
                                color: Colors.green,
                              ),
                              HodStatCard(
                                value: vm.naacGrade,
                                label: 'NAAC Grade',
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Dept-wise Skill Readiness',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.push('/depts'),
                                child: const Text(
                                  'Detail',
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Builder(
                            builder: (context) {
                              final deptList = vm.departmentsData
                                  .map((dept) => {
                                        'name': dept.name,
                                        'percent': dept.value,
                                      })
                                  .toList();
                              return DeptProgressCard(departments: deptList);
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Syllabus Mapping Status',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const SyllabusCard(
                            title: 'CSE — GyaanPlant Courses',
                            subtitle: '8/10 courses mapped to electives',
                            progress: 8,
                          ),
                          const SizedBox(height: 12),
                          const SyllabusCard(
                            title: 'IT — GyaanPlant Courses',
                            subtitle: '6/8 courses mapped to electives',
                            progress: 6,
                          ),
                          const SizedBox(height: 12),
                          const SyllabusCard(
                            title: 'ECE — GyaanPlant Courses',
                            subtitle: '3/10 courses mapped to electives',
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
      ),
    );
  }
}
