// lib/models/HOD_models/employee_model.dart
// Employee model used for Department Details Faculty Registry

class Employee {
  final String id;
  final String name;
  final String? designation;
  final String? email;
  final String? department;

  Employee({
    required this.id,
    required this.name,
    this.designation,
    this.email,
    this.department,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        designation: json['designation']?.toString(),
        email: json['email']?.toString(),
        department: json['department']?.toString(),
      );
}
