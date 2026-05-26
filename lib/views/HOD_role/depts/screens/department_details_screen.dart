import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/department_details_viewmodel.dart';
import 'package:gyaanplant/views/HOD_role/depts/widgets/header_card.dart';
import 'package:gyaanplant/views/HOD_role/depts/widgets/faculty_registry_section.dart';

class DepartmentDetailsScreen extends StatefulWidget {
  final String departmentId;
  const DepartmentDetailsScreen({Key? key, required this.departmentId}) : super(key: key);

  @override
  State<DepartmentDetailsScreen> createState() => _DepartmentDetailsScreenState();
}

class _DepartmentDetailsScreenState extends State<DepartmentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load department data after the first frame to avoid dirty flag issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<DepartmentDetailsViewModel>(context, listen: false);
      vm.loadDepartment(widget.departmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Details', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F3D34), 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<DepartmentDetailsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(child: Text('Error: ${vm.error}', style: const TextStyle(color: Colors.red)));
          }
          final dept = vm.department!;
          final faculty = vm.faculty;
          final totalMembers = vm.totalEmployees ?? faculty.length;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderCard(dept: dept),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 16),
                  FacultyRegistrySection(faculty: faculty, totalMembers: totalMembers),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFF021B15), 
    );
  }
}
