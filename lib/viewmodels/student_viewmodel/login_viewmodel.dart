import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_logger.dart';
import '../../services/student_services/student_api_service.dart';

class LoginViewModel extends ChangeNotifier {
  static const _tag = 'LoginViewModel';

  bool isLoading = false;
  String? token;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> login(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await StudentApiService.login(email, password);
      token = response['token'] as String? ?? response['accessToken'] as String?;

      if (token == null) throw Exception('Token not found in response');

      AppLogger.info(_tag, 'Login successful');

      if (_disposed || !context.mounted) return;
      context.goNamed('role');
    } catch (e, st) {
      AppLogger.error(_tag, 'Login failed', e, st);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login failed')));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
