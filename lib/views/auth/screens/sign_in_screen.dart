import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/views/auth/widgets/custom_text_field.dart';
import 'package:gyaanplant/views/auth/widgets/primary_button.dart';
import 'package:provider/provider.dart';

import '../../../network/auth_cache.dart';
import '../../../viewmodels/student_viewmodel/auth_viewmodel.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isPasswordVisible = false;
  late final TextEditingController roleController;

  @override
  void initState() {
    super.initState();
    final initialRole = _mapRoleToDropdownOption(AuthCache.role ?? 'student');
    roleController = TextEditingController(text: initialRole);
  }

  @override
  void dispose() {
    roleController.dispose();
    super.dispose();
  }

  String _mapRoleToHeading(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return "Logging in as Student";
      case 'hod':
        return "Logging in as HOD";
      case 'mentor':
        return "Logging in as Mentor";
      case 'tpo':
        return "Logging in as TPO";
      default:
        return "Logging in as Student";
    }
  }

  String _mapRoleToDropdownOption(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return "Student";
      case 'hod':
        return "HOD";
      case 'mentor':
        return "Mentor";
      case 'tpo':
        return "TPO";
      default:
        return "Student";
    }
  }

  ///  THEME COLORS
  static const bgColor = Color(0xFF020B08);
  static const cardColor = Color(0xFF0D1F1A);
  static const primaryGreen = Color(0xFF00C853);
  static const accentGreen = Color(0xFF00E676);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        context.go('/role');
        return false;
      },
      child: Scaffold(
        backgroundColor: bgColor,

      ///  APPBAR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/role');
          },
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - AppBar().preferredSize.height - 50,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    ///  LOGO
                    const Icon(
                      Icons.auto_awesome,
                      size: 32,
                      color: accentGreen,
                    ),

                    const SizedBox(height: 12),

                    ///  TITLE
                    const Text(
                      "GyaanPlant",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    ///  SUBTITLE
                    const Text(
                      "EMPOWERING STUDENTS TO LEARN, ENABLING STAFF TO LEAD.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white60,
                        letterSpacing: 1.0,
                      ),
                    ),

                    const SizedBox(height: 48), // Reduced vertical dead space

                    ///  CARD WITH ENTRANCE ANIMATION
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1.0 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18), // Modern rounded corners
                          border: Border.all(
                            color: primaryGreen.withOpacity(0.15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryGreen.withOpacity(0.08),
                              blurRadius: 30,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// DYNAMIC ROLE HEADING
                            Text(
                              _mapRoleToHeading(roleController.text),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 20),

                            /// EMAIL LABEL
                            const Text(
                              "EMAIL",
                              style: TextStyle(
                                color: Color(0xA8FFFFFF),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),

                            CustomTextField(
                              hint: "name@institution.edu",
                              onChanged: vm.setEmail,
                            ),

                            const SizedBox(height: 20),

                            /// PASSWORD LABEL
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "PASSWORD",
                                  style: TextStyle(
                                    color: Color(0xA8FFFFFF),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.go('/forgot-password');
                                  },
                                  child: const Text(
                                    "Forgot?",
                                    style: TextStyle(
                                      color: accentGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            /// PASSWORD FIELD
                            CustomTextField(
                              hint: "••••••••",
                              isPassword: !_isPasswordVisible,
                              onChanged: vm.setPassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 20,
                                  color: const Color(0x9900E676), // Brand matching themed icon color
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 28),

                            /// BUTTON
                            PrimaryButton(
                              text: vm.isLoading
                                  ? "Loading..."
                                  : "Login to Dashboard",
                              onPressed: vm.isLoading
                                  ? null
                                  : () {
                                      vm.login(context, selectedRole: roleController.text);
                                    },
                            ),

                            const SizedBox(height: 20),

                            /// SIGNUP
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "New here? ",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 13,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      context.go('/signup');
                                    },
                                    child: const Text(
                                      "Create account",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: accentGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}

