import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/departments_viewmodel.dart';
import 'package:gyaanplant/views/HOD_role/depts/widgets/department_card.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/core/common_widgets/hod_bottom_nav.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  late final DepartmentsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = DepartmentsViewModel();
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
        body: Consumer<DepartmentsViewModel>(
          builder: (context, vm, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Departments',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: vm.departments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            DepartmentCard(dept: vm.departments[i]),
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
