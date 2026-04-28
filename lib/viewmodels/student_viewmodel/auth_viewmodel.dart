import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/student_services/student_api_service.dart';
import '../../services/student_services/local_storage_service.dart';
import '../../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel() {
    loadUser();
  }
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

  Map<String, dynamic>? user;

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

  Future<void> nextStep(BuildContext context) async {
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
      await _register(context);
    }
  }

  void previousStep() {
    if (currentStep > 1) {
      currentStep--;
      notifyListeners();
    }
  }

  //  LOGIN

  String? userName;

  Future<void> login(BuildContext context) async {
    //  Basic validation
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

      //  API call
      final response = await StudentApiService.login(email, password);

      print("🔵 FULL LOGIN RESPONSE: $response");

      //  Extract data safely
      final accessToken = response['accessToken'];
      final userData = response['user'];

      if (accessToken == null || accessToken.toString().isEmpty) {
        throw Exception("Token missing from response");
      }

      print("🟢 TOKEN AFTER LOGIN: $accessToken");

      //  Save to memory
      token = accessToken;
      user = userData;

      //  Store token globally using AuthService
      await AuthService.saveToken(accessToken);

      //  Extract username safely
      userName =
          userData?['name'] ??
          userData?['fullName'] ??
          userData?['username'] ??
          "User";

      //  Save locally
      await LocalStorageService.saveToken(token!);
      await LocalStorageService.saveUser(user!);

      print("✅ LOGIN SUCCESS");
      print("👤 USER: $user");
      print("📛 USER NAME: $userName");

      //  Save role from backend response
      final backendRole = userData?['role']?.toString();
      if (backendRole != null && backendRole.isNotEmpty) {
        await LocalStorageService.saveRole(backendRole);
        print("💾 BACKEND ROLE SAVED: $backendRole");
      }

      print("🎯 USER ROLE FROM RESPONSE: ${userData?['role']}");

      //  Navigate - let GoRouter handle role-based redirection
      context.go('/');
    } catch (e) {
      print("❌ LOGIN ERROR: $e");

      _showError(context, "Login failed. Please check your credentials.");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUser() async {
    user = await LocalStorageService.getUser();
    notifyListeners();
  }
  //  REGISTER

  Future<void> _register(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await StudentApiService.register(
        name,
        email,
        password,
        role,
      );

      print("REGISTER RESPONSE: $response");

      _showError(context, "Account created successfully! Please login.");

      context.go('/');
    } catch (e) {
      print("Register Error: $e");
      _showError(context, e.toString());
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
