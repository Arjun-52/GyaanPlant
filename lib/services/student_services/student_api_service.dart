import 'dart:convert';
import '../../core/utils/app_logger.dart';
import '../../models/student_role_models/student_model.dart';
import 'base_api_service.dart';

const _tag = 'StudentApiService';

class StudentApiService {
  static Future<StudentModel> getStudentById(String studentId) async {
    final response = await BaseApiService.get('/api/v1/students/$studentId');
    if (response.statusCode == 200) {
      return StudentModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch student: ${response.body}');
  }

  static Future<List<StudentModel>> getAllStudents() async {
    final response = await BaseApiService.get('/api/v1/students');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => StudentModel.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch students: ${response.body}');
  }

  static Future<StudentModel> createStudent(Map<String, dynamic> studentData) async {
    final response = await BaseApiService.post('/api/v1/students', studentData);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return StudentModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create student: ${response.body}');
  }

  static Future<StudentModel> updateStudent(
    String studentId,
    Map<String, dynamic> studentData,
  ) async {
    final response = await BaseApiService.put('/api/v1/students/$studentId', studentData);
    if (response.statusCode == 200) {
      return StudentModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update student: ${response.body}');
  }

  static Future<void> deleteStudent(String studentId) async {
    final response = await BaseApiService.delete('/api/v1/students/$studentId');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete student: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    AppLogger.info(_tag, 'Login attempt for $email');
    final response = await BaseApiService.post('/api/v1/auth/login', {
      'email': email,
      'password': password,
    });
    AppLogger.info(_tag, 'Login response received');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    AppLogger.info(_tag, 'Register attempt for $email');
    final response = await BaseApiService.post('/api/v1/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'role': role.toLowerCase(),
    });
    AppLogger.info(_tag, 'Registration successful');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getStudentCourses(String studentId) async {
    final response = await BaseApiService.get('/api/v1/students/$studentId/courses');
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to fetch courses: ${response.body}');
  }

  static Future<Map<String, dynamic>> getStudentStats(String studentId) async {
    final response = await BaseApiService.get('/api/v1/students/$studentId/stats');
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to fetch stats: ${response.body}');
  }
}
