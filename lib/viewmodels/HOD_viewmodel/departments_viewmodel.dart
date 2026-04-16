import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/department_model.dart';

class DepartmentsViewModel extends ChangeNotifier {
  final List<Department> _departments = [
    Department(
      name: "Computer Science Engineering",
      hod: "Dr. K. Ramaiah",
      students: 680,
      readiness: 78,
      icon: "💻",
    ),
    Department(
      name: "Information Technology",
      hod: "Dr. S. Lakshmi",
      students: 520,
      readiness: 72,
      icon: "🌐",
    ),
    Department(
      name: "Electronics & Communication",
      hod: "Dr. M. Chandra",
      students: 480,
      readiness: 61,
      icon: "📡",
    ),
    Department(
      name: "Electrical Engineering",
      hod: "Dr. P. Rao",
      students: 360,
      readiness: 54,
      icon: "⚡",
    ),
    Department(
      name: "Mechanical Engineering",
      hod: "Dr. V. Kumar",
      students: 440,
      readiness: 42,
      icon: "🏗️",
    ),
    Department(
      name: "Civil Engineering",
      hod: "Dr. A. Singh",
      students: 367,
      readiness: 38,
      icon: "🏗️",
    ),
  ];

  List<Department> get departments => _departments;
}
