import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/student_viewmodel/auth_viewmodel.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/form_label.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ///  THEME COLORS
  static const bgColor = Color(0xFF020B08);
  static const cardColor = Color(0xFF0D1F1A);
  static const primaryGreen = Color(0xFF00C853);
  static const accentGreen = Color(0xFF00E676);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      final vm = context.read<AuthViewModel>();
      vm.forgotPassword(context, _emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔙 BACK
              IconButton(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),

              const SizedBox(height: 20),

              ///  HEADER
              const Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Enter your email address and we'll send you a link to reset your password.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              /// CARD
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
                      color: primaryGreen.withValues(alpha: 0.08),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormLabel(text: "EMAIL", color: Colors.white70),
                      const SizedBox(height: 6),

                      CustomTextField(
                        hint: "name@institution.edu",
                        onChanged: (value) {
                          _emailController.text = value;
                        },
                      ),

                      const SizedBox(height: 30),

                      ///  BUTTON
                      Consumer<AuthViewModel>(
                        builder: (context, vm, child) {
                          return PrimaryButton(
                            text: vm.isLoading ? "Sending..." : "Send Link",
                            onPressed: vm.isLoading
                                ? null
                                : _handleForgotPassword,
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      ///  SIGN IN
                      Center(
                        child: GestureDetector(
                          onTap: () => context.go('/'),
                          child: RichText(
                            text: TextSpan(
                              text: "Remember your password? ",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: "Sign In",
                                  style: const TextStyle(
                                    color: accentGreen,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}
