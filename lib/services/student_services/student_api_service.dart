import 'dart:convert';
import 'dart:core';
import '../../models/student_role_models/student_model.dart';
import 'base_api_service.dart';

/// Specific API service for student-related endpoints
class StudentApiService {
  /// Get student by ID
  static Future<StudentModel> getStudentById(
    String studentId, {
    String? authToken,
  }) async {
    final response = await BaseApiService.get('/api/v1/students/$studentId');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return StudentModel.fromJson(data);
    } else {
      throw Exception("Failed to fetch student: ${response.body}");
    }
  }

  /// Get all students
  static Future<List<StudentModel>> getAllStudents({String? authToken}) async {
    final response = await BaseApiService.get('/api/v1/students');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => StudentModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch students: ${response.body}");
    }
  }

  /// Create new student
  static Future<StudentModel> createStudent(
    Map<String, dynamic> studentData, {
    String? authToken,
  }) async {
    final response = await BaseApiService.post('/api/v1/students', studentData);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return StudentModel.fromJson(data);
    } else {
      throw Exception("Failed to create student: ${response.body}");
    }
  }

  /// Update student
  static Future<StudentModel> updateStudent(
    String studentId,
    Map<String, dynamic> studentData, {
    String? authToken,
  }) async {
    final response = await BaseApiService.put(
      '/api/v1/students/$studentId',
      studentData,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return StudentModel.fromJson(data);
    } else {
      throw Exception("Failed to update student: ${response.body}");
    }
  }

  /// Delete student
  static Future<void> deleteStudent(
    String studentId, {
    String? authToken,
  }) async {
    final response = await BaseApiService.delete('/api/v1/students/$studentId');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete student: ${response.body}");
    }
  }

  ///  LOGIN
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await BaseApiService.post('/api/v1/auth/login', {
      "email": email,
      "password": password,
    });
    print("RAW RESPONSE: ${response.body}");
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final response = await BaseApiService.post('/api/v1/auth/register', {
      "name": name,
      "email": email,
      "password": password,
      "role": role.toLowerCase(),
    });

    return jsonDecode(response.body);
  }

  /// Get student courses
  static Future<List<dynamic>> getStudentCourses(String studentId) async {
    final response = await BaseApiService.get(
      '/api/v1/students/$studentId/courses',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch courses: ${response.body}");
    }
  }

  /// Get student stats
  static Future<Map<String, dynamic>> getStudentStats(String studentId) async {
    final response = await BaseApiService.get(
      '/api/v1/students/$studentId/stats',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch stats: ${response.body}");
    }
  }
}
