import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_logger.dart';
import '../../data/services/local_storage_service.dart';
import '../../services/student_services/student_api_service.dart';

class AuthViewModel extends ChangeNotifier {
  static const _tag = 'AuthViewModel';
  bool _disposed = false;

  AuthViewModel() {
    loadUser();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  // FORM FIELDS
  String name = '';
  String email = '';
  String password = '';
  String role = 'Student';
  String college = 'Select';
  String branch = 'Select Branch';
  String careerPath = 'Select Career Path';

  // STATE
  int currentStep = 1;
  bool isLoading = false;
  String? token;
  String? userName;
  Map<String, dynamic>? user;

  // SETTERS
  void setName(String value) => name = value;
  void setEmail(String value) => email = value;
  void setPassword(String value) => password = value;

  void setRole(String value) {
    role = value;
    notifyListeners();
  }

  void setCollege(String value) {
    college = value;
    notifyListeners();
  }

  void setBranch(String value) {
    branch = value;
    notifyListeners();
  }

  void setCareerPath(String value) {
    careerPath = value;
    notifyListeners();
  }

  // STEP NAVIGATION (SIGNUP)
  Future<void> nextStep(BuildContext context) async {
    if (currentStep == 1) {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        _showError(context, 'Please fill all fields');
        return;
      }
      if (!email.contains('@')) {
        _showError(context, 'Enter valid email');
        return;
      }
      if (password.length < 6) {
        _showError(context, 'Password must be at least 6 characters');
        return;
      }
    }

    if (currentStep == 3) {
      if (branch == 'Select Branch' || careerPath == 'Select Career Path') {
        _showError(context, 'Please complete all fields');
        return;
      }
    }

    if (currentStep < 3) {
      currentStep++;
      notifyListeners();
    } else {
      await _register(context);
    }
  }

  void previousStep() {
    if (currentStep > 1) {
      currentStep--;
      notifyListeners();
    }
  }

  // LOGIN
  Future<void> login(BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      _showError(context, 'Please fill all fields');
      return;
    }
    if (!email.contains('@')) {
      _showError(context, 'Enter valid email');
      return;
    }
    if (password.length < 6) {
      _showError(context, 'Password must be at least 6 characters');
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await StudentApiService.login(email, password);

      final accessToken = response['accessToken'];
      final userData = response['user'] as Map<String, dynamic>?;

      if (accessToken == null) throw Exception('Token missing from response');
      if (userData == null) throw Exception('User data missing from response');

      token = accessToken as String;
      user = userData;
      userName = userData['name'] ?? userData['fullName'] ?? userData['username'];

      await LocalStorageService.saveToken(token!);
      await LocalStorageService.saveUser(user!);

      AppLogger.info(_tag, 'Login successful for ${userData['name'] ?? email}');

      if (_disposed || !context.mounted) return;
      context.go('/student-dashboard');
    } catch (e, st) {
      AppLogger.error(_tag, 'Login failed', e, st);
      if (!context.mounted) return;
      _showError(context, 'Login failed. Check credentials.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUser() async {
    user = await LocalStorageService.getUser();
    notifyListeners();
  }

  // REGISTER
  Future<void> _register(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      await StudentApiService.register(name, email, password);

      AppLogger.info(_tag, 'Registration successful for $email');

      if (_disposed || !context.mounted) return;
      _showError(context, 'Account created successfully! Please login.');
      context.go('/');
    } catch (e, st) {
      AppLogger.error(_tag, 'Registration failed', e, st);
      if (!context.mounted) return;
      _showError(context, e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
