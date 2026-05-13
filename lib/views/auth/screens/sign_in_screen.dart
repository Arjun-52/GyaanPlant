import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/views/auth/widgets/custom_text_field.dart';
import 'package:gyaanplant/views/auth/widgets/primary_button.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/student_viewmodel/auth_viewmodel.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isPasswordVisible = false;

  ///  THEME COLORS
  static const bgColor = Color(0xFF020B08);
  static const cardColor = Color(0xFF0D1F1A);
  static const primaryGreen = Color(0xFF00C853);
  static const accentGreen = Color(0xFF00E676);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: bgColor,

      ///  APPBAR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.push('/role'),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    ///  LOGO
                    const Icon(
                      Icons.auto_awesome,
                      size: 28,
                      color: accentGreen,
                    ),

                    const SizedBox(height: 10),

                    ///  TITLE
                    const Text(
                      "GyaanPlant",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                    ///  SUBTITLE
                    const Text(
                      "EMPOWERING STUDENTS TO LEARN, ENABLING STAFF TO LEAD.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),

                    const SizedBox(height: 140),

                    ///  CARD
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: primaryGreen.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryGreen.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// EMAIL
                          const Text(
                            "EMAIL",
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),

                          CustomTextField(
                            hint: "name@institution.edu",
                            onChanged: vm.setEmail,
                          ),

                          const SizedBox(height: 16),

                          /// PASSWORD LABEL
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "PASSWORD",
                                style: TextStyle(color: Colors.white70),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.go('/forgot-password');
                                },
                                child: const Text(
                                  "Forgot?",
                                  style: TextStyle(
                                    color: accentGreen,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// PASSWORD FIELD
                          CustomTextField(
                            hint: "********",
                            isPassword: !_isPasswordVisible,
                            onChanged: vm.setPassword,
                            suffix: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 18,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// BUTTON
                          PrimaryButton(
                            text: vm.isLoading
                                ? "Loading..."
                                : "Login to Dashboard",
                            onPressed: vm.isLoading
                                ? null
                                : () {
                                    vm.login(context);
                                  },
                          ),

                          const SizedBox(height: 18),

                          /// SIGNUP
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "New here? ",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                InkWell(
                                  onTap: () {
                                    context.go('/signup');
                                  },
                                  child: const Text(
                                    "Create account",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
