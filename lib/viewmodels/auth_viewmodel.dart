import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthViewModel extends ChangeNotifier {
  String name = "";
  String email = "";
  String password = "";
  String role = "Student";
  String college = "Select";

  int currentStep = 1;

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

  void nextStep(BuildContext context) {
    //  Validation for Step 1
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

  void login(BuildContext context) {
    // Validation for sign in
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

    // For now, just show success and navigate
    _showError(context, "Login Successful! Redirecting to dashboard...");

    // Navigate to dashboard or home screen
    Future.delayed(const Duration(seconds: 2), () {
      context.go('/dashboard');
    });
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void previousStep() {
    if (currentStep > 1) {
      currentStep--;
      notifyListeners();
    }
  }

  String branch = "Select Branch";
  String careerPath = "Select Career Path";

  void setBranch(String value) {
    branch = value;
    notifyListeners();
  }

  void setCareerPath(String value) {
    careerPath = value;
    notifyListeners();
  }
}
