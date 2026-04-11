import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/student_api_service.dart';
import '../../services/local_storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  //  FORM FIELDS

  String name = "";
  String email = "";
  String password = "";
  String role = "Student";
  String college = "Select";

  String branch = "Select Branch";
  String careerPath = "Select Career Path";

  //  STATE

  int currentStep = 1;
  bool isLoading = false;
  String? token;

  //  SETTERS

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

  //  STEP NAVIGATION (SIGNUP)

  void nextStep(BuildContext context) {
    // Step 1 validation
    if (currentStep == 1) {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        _showError(context, "Please fill all fields");
        return;
      }

      if (!email.contains('@')) {
        _showError(context, "Enter valid email");
        return;
      }

      if (password.length < 6) {
        _showError(context, "Password must be at least 6 characters");
        return;
      }
    }

    // Step 3 validation
    if (currentStep == 3) {
      if (branch == "Select Branch" || careerPath == "Select Career Path") {
        _showError(context, "Please complete all fields");
        return;
      }
    }

    if (currentStep < 3) {
      currentStep++;
      notifyListeners();
    } else {
      _showError(context, "Signup Complete ✅");
      context.go('/');
    }
  }

  void previousStep() {
    if (currentStep > 1) {
      currentStep--;
      notifyListeners();
    }
  }

  //  LOGIN

  Future<void> login(BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      _showError(context, "Please fill all fields");
      return;
    }

    if (!email.contains('@')) {
      _showError(context, "Enter valid email");
      return;
    }

    if (password.length < 6) {
      _showError(context, "Password must be at least 6 characters");
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await StudentApiService.login(email, password);

      token = response['token'];

      if (token == null) {
        throw Exception("Token not found");
      }

      await LocalStorageService.saveToken(token!);

      print("LOGIN SUCCESS → TOKEN: $token");

      context.goNamed('role');
    } catch (e) {
      print("Login Error: $e");
      _showError(context, "Invalid credentials");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //  ERROR HANDLER

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
