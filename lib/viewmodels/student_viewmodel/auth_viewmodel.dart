import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_logger.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../models/auth/auth_user_model.dart';

class AuthViewModel extends ChangeNotifier {
  static const _tag = 'AuthViewModel';

  final _auth = ApiService().auth;

  bool _disposed = false;

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
  String? errorMessage;
  AuthUser? user;

  String? get userName => user?.name;

  AuthViewModel() {
    _loadUser();
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

  // SETTERS
  void setName(String v) => name = v;
  void setEmail(String v) => email = v;
  void setPassword(String v) => password = v;

  void setRole(String v) {
    role = v;
    notifyListeners();
  }

  void setCollege(String v) {
    college = v;
    notifyListeners();
  }

  void setBranch(String v) {
    branch = v;
    notifyListeners();
  }

  void setCareerPath(String v) {
    careerPath = v;
    notifyListeners();
  }

  // LOGIN
  Future<void> login(BuildContext context) async {
    if (!_validateLoginFields(context)) return;

    _setLoading(true);
    try {
      final result = await _auth.login(email: email, password: password);

      if (result.isSuccess) {
        final data = result.data!;
        user = data.user;
        await LocalStorageService.saveToken(data.accessToken);
        await LocalStorageService.saveUser(data.user.toJson());
        AppLogger.info(_tag, 'Login successful for ${data.user.email}');
        if (_disposed || !context.mounted) return;
        context.goNamed('role');
      } else {
        _showError(context, result.error?.message ?? 'Login failed');
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Login error', e, st);
      if (context.mounted) _showError(context, 'An unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  // SIGNUP STEP NAVIGATION
  Future<void> nextStep(BuildContext context) async {
    if (currentStep == 1) {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        _showError(context, 'Please fill all fields');
        return;
      }
      if (!email.contains('@')) {
        _showError(context, 'Enter a valid email');
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

  // REGISTER
  Future<void> _register(BuildContext context) async {
    _setLoading(true);
    try {
      final result = await _auth.register(
        name: name,
        email: email,
        password: password,
        role: role.toLowerCase(),
      );

      if (result.isSuccess) {
        AppLogger.info(_tag, 'Registration successful for $email');
        if (_disposed || !context.mounted) return;
        _showError(context, 'Account created! Please log in.');
        context.go('/');
      } else {
        _showError(context, result.error?.message ?? 'Registration failed');
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Register error', e, st);
      if (context.mounted) _showError(context, 'An unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.logout();
    await LocalStorageService.clearToken();
    user = null;
    notifyListeners();
    if (context.mounted) context.go('/');
  }

  // PRIVATE HELPERS
  Future<void> _loadUser() async {
    final raw = await LocalStorageService.getUser();
    if (raw != null) {
      try {
        user = AuthUser.fromJson(raw);
        notifyListeners();
      } catch (_) {}
    }
  }

  bool _validateLoginFields(BuildContext context) {
    if (email.isEmpty || password.isEmpty) {
      _showError(context, 'Please fill all fields');
      return false;
    }
    if (!email.contains('@')) {
      _showError(context, 'Enter a valid email');
      return false;
    }
    if (password.length < 6) {
      _showError(context, 'Password must be at least 6 characters');
      return false;
    }
    return true;
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    errorMessage = message;
    notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
