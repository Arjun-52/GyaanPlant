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
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back),
              ),

              const SizedBox(height: 20),

              // Header
              const Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF031B15),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Enter your email address and we'll send you a link to reset your password.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormLabel(text: "EMAIL"),
                    const SizedBox(height: 6),
                    CustomTextField(
                      hint: "name@institution.edu",
                      onChanged: (value) {
                        // Text field updates are handled by the controller
                      },
                    ),

                    const SizedBox(height: 30),

                    // Send Reset Link Button
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

                    // Back to Sign In
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/'),
                        child: RichText(
                          text: TextSpan(
                            text: "Remember your password? ",
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign In",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
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
            ],
          ),
        ),
      ),
    );
  }
}
