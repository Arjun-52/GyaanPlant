import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/employee_model.dart';

class FacultyItem extends StatelessWidget {
  final Employee employee;
  const FacultyItem({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF0F3D34),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.greenAccent,
          child: Text(
            employee.name?.isNotEmpty == true ? employee.name![0] : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          employee.name ?? 'Unnamed',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (employee.email != null)
              Text(
                employee.email!,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            if (employee.designation != null)
              Text(
                employee.designation!,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
