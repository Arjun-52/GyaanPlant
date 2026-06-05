import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/api_service.dart';
import '../../models/auth/auth_user_model.dart';
import '../../network/auth_cache.dart';
import '../../core/utils/app_logger.dart';

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
    // 🚧 TEMPORARY DEVELOPMENT BYPASS: Set to true to bypass login validation and mock credentials
    const bool useDevBypass = false;
    if (useDevBypass) {
      print("🚧 DEV BYPASS: Tapped login. Mocking login and moving to student dashboard.");
      await LocalStorageService.saveToken("mock_dev_token");
      await LocalStorageService.saveRole("student");
      await LocalStorageService.saveUser({
        "id": "mock_id",
        "name": "Dev Student",
        "email": email.isNotEmpty ? email : "dev@gyaanplant.com",
        "role": "student",
      });
      AuthCache.token = "mock_dev_token";
      
      if (_disposed || !context.mounted) return;
      context.go('/student-dashboard');
      return;
    }

    if (!_validateLoginFields(context)) return;

    _setLoading(true);
    try {
      print("🕵️‍♂️ [AuthViewModel.login] Sending login request for email: $email");
      final result = await _auth.login(email: email, password: password);
      print("🕵️‍♂️ [AuthViewModel.login] Login API response received. success=${result.isSuccess}, statusCode=${result.statusCode}");

      if (result.isSuccess) {
        final data = result.data!;
        user = data.user;

        print("🕵️‍♂️ [AuthViewModel.login] Raw extracted token: ${data.accessToken}");

        try {
          print("🕵️‍♂️ [AuthViewModel.login] BEFORE AuthCache.token = data.accessToken");
          AuthCache.token = data.accessToken;
          print("🕵️‍♂️ [AuthViewModel.login] AFTER AuthCache.token. In-memory cache is now: ${AuthCache.token}");
        } catch (e) {
          print("🕵️‍♂️ [AuthViewModel.login] ERROR saving token to AuthCache: $e");
        }

        try {
          print("🕵️‍♂️ [AuthViewModel.login] BEFORE LocalStorageService.saveToken()");
          await LocalStorageService.saveToken(data.accessToken);
          print("🕵️‍♂️ [AuthViewModel.login] AFTER LocalStorageService.saveToken()");
          
          final verifyToken = await LocalStorageService.getToken();
          print("🕵️‍♂️ [AuthViewModel.login] VERIFICATION - Token retrieved from local storage: $verifyToken");
        } catch (e) {
          print("🕵️‍♂️ [AuthViewModel.login] ERROR saving token to LocalStorageService: $e");
        }

        try {
          print("🕵️‍♂️ [AuthViewModel.login] BEFORE LocalStorageService.saveUser()");
          await LocalStorageService.saveUser(data.user.toJson());
          print("🕵️‍♂️ [AuthViewModel.login] AFTER LocalStorageService.saveUser()");
        } catch (e) {
          print("🕵️‍♂️ [AuthViewModel.login] ERROR saving user to LocalStorageService: $e");
        }

        try {
          if (data.user.role.isNotEmpty) {
            print("🕵️‍♂️ [AuthViewModel.login] BEFORE LocalStorageService.saveRole()");
            await LocalStorageService.saveRole(data.user.role.toLowerCase());
            print("🕵️‍♂️ [AuthViewModel.login] AFTER LocalStorageService.saveRole()");
          }
        } catch (e) {
          print("🕵️‍♂️ [AuthViewModel.login] ERROR saving role to LocalStorageService: $e");
        }

        AppLogger.info(_tag, 'Login successful for ${data.user.email}');
        
        if (_disposed) {
          print("🕵️‍♂️ [AuthViewModel.login] Navigation cancelled: AuthViewModel is disposed.");
          return;
        }
        if (!context.mounted) {
          print("🕵️‍♂️ [AuthViewModel.login] Navigation cancelled: BuildContext is no longer mounted.");
          return;
        }

        try {
          print("🕵️‍♂️ [AuthViewModel.login] BEFORE context.go('/') navigation");
          context.go('/');
          print("🕵️‍♂️ [AuthViewModel.login] AFTER context.go('/') navigation triggered");
        } catch (e, st) {
          print("🕵️‍♂️ [AuthViewModel.login] ERROR during navigation redirect: $e\n$st");
        }
      } else {
        print("🕵️‍♂️ [AuthViewModel.login] Login failed on server side: ${result.error?.message}");
        _showError(context, result.error?.message ?? 'Login failed');
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Login error', e, st);
      print("🕵️‍♂️ [AuthViewModel.login] EXCEPTION caught during login flow: $e\n$st");
      if (context.mounted) _showError(context, 'An unexpected error occurred');
    } finally {
      print("🕵️‍♂️ [AuthViewModel.login] FINALLY block reached. Resetting loading state to false.");
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
    // 🚧 TEMPORARY DEVELOPMENT BYPASS: Set to true to bypass registration API and mock credentials
    const bool useDevBypass = false;
    if (useDevBypass) {
      print("🚧 DEV BYPASS: Tapped register. Mocking registration and moving to student dashboard.");
      await LocalStorageService.saveToken("mock_dev_token");
      await LocalStorageService.saveRole("student");
      await LocalStorageService.saveUser({
        "id": "mock_id",
        "name": name.isNotEmpty ? name : "Dev Student",
        "email": email.isNotEmpty ? email : "dev@gyaanplant.com",
        "role": "student",
      });
      AuthCache.token = "mock_dev_token";
      
      if (_disposed || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/student-dashboard');
      return;
    }

    _setLoading(true);
    try {
      print("🕵️‍♂️ [AuthViewModel._register] Sending registration request for: $email, role: $role");
      final result = await _auth.register(
        name: name,
        email: email,
        password: password,
        role: role.toLowerCase(),
      );
      print("🕵️‍♂️ [AuthViewModel._register] Registration API response received. success=${result.isSuccess}, statusCode=${result.statusCode}");

      if (result.isSuccess) {
        final data = result.data!;
        user = data.user;

        print("🕵️‍♂️ [AuthViewModel._register] Raw extracted token: ${data.accessToken}");

        try {
          print("🕵️‍♂️ [AuthViewModel._register] BEFORE AuthCache.token = data.accessToken");
          AuthCache.token = data.accessToken;
          print("🕵️‍♂️ [AuthViewModel._register] AFTER AuthCache.token. In-memory cache is now: ${AuthCache.token}");
        } catch (e) {
          print("🕵️‍♂️ [AuthViewModel._register] ERROR saving token to AuthCache: $e");
        }

        try {
          print("🕵️‍♂️ [AuthViewModel._register] BEFORE LocalStorageService.saveToken()");
          await LocalStorageService.saveToken(data.accessToken);
          print("🕵️‍♂️ [AuthViewModel._register] AFTER LocalStorageService.saveToken()");
          
          final verifyToken = await LocalStorageService.getToken();
          print("🕵️‍♂️ [AuthViewModel._register] VERIFICATION - Token retrieved from local storage: $verifyToken");
        } catch (e) {
          print("🕵️‍♂️ [AuthViewModel._register] ERROR saving token to LocalStorageService: $e");
        }

        try {
          print("🕵️‍♂️ [AuthViewModel._register] BEFORE LocalStorageService.saveUser()");
          await LocalStorageService.saveUser(data.user.toJson());
          print("🕵️‍♂️ [AuthViewModel._register] AFTER LocalStorageService.saveUser()");
        } catch (e) {
          print("🕵️‍♂️ [AuthViewModel._register] ERROR saving user to LocalStorageService: $e");
        }

        try {
          if (data.user.role.isNotEmpty) {
            print("🕵️‍♂️ [AuthViewModel._register] BEFORE LocalStorageService.saveRole()");
            await LocalStorageService.saveRole(data.user.role.toLowerCase());
            print("🕵️‍♂️ [AuthViewModel._register] AFTER LocalStorageService.saveRole()");
          }
        } catch (e) {
          print("🕵️‍♂️ [AuthViewModel._register] ERROR saving role to LocalStorageService: $e");
        }

        AppLogger.info(_tag, 'Registration and auto-login successful for $email');
        
        if (_disposed) {
          print("🕵️‍♂️ [AuthViewModel._register] Navigation/SnackBar skipped: AuthViewModel is disposed.");
          return;
        }
        if (!context.mounted) {
          print("🕵️‍♂️ [AuthViewModel._register] Navigation/SnackBar skipped: BuildContext is no longer mounted.");
          return;
        }

        try {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful!'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          print("🕵️‍♂️ [AuthViewModel._register] SnackBar display error: $e");
        }

        try {
          print("🕵️‍♂️ [AuthViewModel._register] BEFORE context.go('/') navigation");
          context.go('/');
          print("🕵️‍♂️ [AuthViewModel._register] AFTER context.go('/') navigation triggered");
        } catch (e, st) {
          print("🕵️‍♂️ [AuthViewModel._register] ERROR during navigation redirect: $e\n$st");
        }
      } else {
        print("🕵️‍♂️ [AuthViewModel._register] Registration failed on server side: ${result.error?.message}");
        _showError(context, result.error?.message ?? 'Registration failed');
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Register error', e, st);
      print("🕵️‍♂️ [AuthViewModel._register] EXCEPTION caught during registration flow: $e\n$st");
      if (context.mounted) _showError(context, 'An unexpected error occurred');
    } finally {
      print("🕵️‍♂️ [AuthViewModel._register] FINALLY block reached. Resetting loading state to false.");
      _setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    print("🔥 LOGOUT: Starting proper logout flow");

    try {
      // ✅ STEP 1: Call API FIRST (token still exists)
      await _auth.logout();
      print("✅ LOGOUT API SUCCESS");
    } catch (e) {
      print("⚠️ LOGOUT API FAILED: $e");
      // Don't block logout if API fails
    }

    // ✅ STEP 2: Now clear local data
    await LocalStorageService.clearToken();
    await LocalStorageService.removeRole();
    AuthCache.token = null;

    print("🔥 LOGOUT: Local data cleared");

    user = null;
    notifyListeners();

    if (context.mounted) {
      context.go('/signin');
    }
  }

  Future<void> forgotPassword(BuildContext context, String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email is required")));
      return;
    }

    try {
      _setLoading(true);

      final result = await _auth.forgotPassword(email: email);

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message ?? "If that email exists, a reset link was sent.",
            ),
            backgroundColor: Colors.green,
          ),
        );
        AppLogger.info(_tag, 'Password reset email sent to $email');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error?.message ?? "Failed to send reset link"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Forgot password error', e, st);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _setLoading(false);
    }
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
