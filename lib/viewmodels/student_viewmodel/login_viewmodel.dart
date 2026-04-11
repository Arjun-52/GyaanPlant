import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/student_api_service.dart';

class LoginViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? token;

  /// Login function
  Future<void> login(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // CALL API
      final response = await StudentApiService.login(email, password);

      // HANDLE TOKEN (VERY IMPORTANT)
      token = response['token'] ?? response['accessToken'];

      if (token == null) {
        throw Exception("Token not found in response");
      }

      print("LOGIN SUCCESS → TOKEN: $token");

      // Navigate ONLY AFTER SUCCESS
      context.goNamed('role');
    } catch (e) {
      print("Login Error: $e");

      // Optional: show error snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed")));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
