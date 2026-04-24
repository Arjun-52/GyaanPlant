import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/departments_viewmodel.dart';
import 'package:gyaanplant/views/HOD_role/depts/widgets/department_card.dart';
import 'package:gyaanplant/core/common_widgets/hod_bottom_nav.dart';

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DepartmentsViewModel()..loadDepartments(), // 🔥 CALL API
      child: Scaffold(
        backgroundColor: const Color(0xFF061A14),

        body: Consumer<DepartmentsViewModel>(
          builder: (context, vm, _) {
            ///  LOADING
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            /// 🔥 ERROR
            if (vm.error != null) {
              return Center(
                child: Text(
                  vm.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            /// 🔥 EMPTY
            if (vm.departments.isEmpty) {
              return const Center(
                child: Text(
                  "No Departments Found",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            /// 🔥 SUCCESS UI
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Departments 📐",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: ListView.separated(
                        itemCount: vm.departments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final dept = vm.departments[i];

                          return DepartmentCard(dept: dept);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        bottomNavigationBar: const HODBottomNav(currentIndex: 1),
      ),
    );
  }
}
