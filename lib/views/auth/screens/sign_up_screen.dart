import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/views/auth/widgets/auth_redirect_text.dart';
import 'package:gyaanplant/views/auth/widgets/custom_dropdown.dart';
import 'package:gyaanplant/views/auth/widgets/custom_text_field.dart';
import 'package:gyaanplant/views/auth/widgets/form_label.dart';
import 'package:gyaanplant/views/auth/widgets/primary_button.dart';
import 'package:gyaanplant/views/auth/widgets/step_indicator.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/student_viewmodel/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ///  HEADER
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/role'),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Icon(Icons.auto_awesome, size: 28, color: accentGreen),
                        SizedBox(height: 10),
                        Text(
                          "Join GyaanPlant",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "PROFESSIONAL DEVELOPMENT, UNIFIED.",
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// STEP INDICATOR (assumes internal styling ok)
              StepIndicator(currentStep: vm.currentStep),

              const SizedBox(height: 20),

              /// CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primaryGreen.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepContent(vm),

                    const SizedBox(height: 20),

                    /// BUTTONS
                    Row(
                      children: [
                        if (vm.currentStep > 1)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: vm.previousStep,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color: primaryGreen.withOpacity(0.5),
                                ),
                              ),
                              child: const Text(
                                "Back",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                        if (vm.currentStep > 1) const SizedBox(width: 10),

                        Expanded(
                          child: PrimaryButton(
                            text: vm.currentStep == 3
                                ? "Register Now"
                                : "Continue",
                            onPressed: () async => await vm.nextStep(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const AuthRedirectText(
                      normalText: "Already have an account? ",
                      actionText: "Sign in",
                      route: '/',
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

  ///  STEP CONTENT
  Widget _buildStepContent(AuthViewModel vm) {
    switch (vm.currentStep) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FormLabel(text: "FULL NAME", color: Colors.white70),
            const SizedBox(height: 6),
            CustomTextField(hint: "e.g. Alan Turing", onChanged: vm.setName),

            const SizedBox(height: 16),

            const FormLabel(text: "EMAIL", color: Colors.white70),
            const SizedBox(height: 6),
            CustomTextField(
              hint: "name@institution.edu",
              onChanged: vm.setEmail,
            ),

            const SizedBox(height: 16),

            const FormLabel(text: "PASSWORD", color: Colors.white70),
            const SizedBox(height: 6),
            CustomTextField(
              hint: "Min. 8 chars",
              isPassword: !_isPasswordVisible,
              onChanged: vm.setPassword,
              suffix: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FormLabel(text: "ROLE", color: Colors.white70),
            const SizedBox(height: 6),

            CustomDropdown(
              value: vm.role,
              items: const [
                "Student",
                "Mentor",
                "TPO",
                "HOD",
                "College Admin",
                "Employee / Staff",
                "HR Manager",
                "L&D Manager",
                "Department Head",
                "Executive",
              ],
              onChanged: vm.setRole,
            ),

            const SizedBox(height: 16),

            const FormLabel(text: "COLLEGE", color: Colors.white70),
            const SizedBox(height: 6),

            CustomDropdown(
              value: vm.college,
              items: const ["Select", "IIT", "NIT", "Other"],
              onChanged: vm.setCollege,
            ),
          ],
        );

      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FormLabel(text: "BRANCH/STREAM", color: Colors.white70),
            const SizedBox(height: 6),

            CustomDropdown(
              value: vm.branch,
              items: const [
                "Select Branch",
                "CSE",
                "ECE",
                "EEE",
                "Mechanical",
                "Civil",
              ],
              onChanged: vm.setBranch,
            ),

            const SizedBox(height: 16),

            const FormLabel(
              text: "CAREER PATH / INTEREST",
              color: Colors.white70,
            ),
            const SizedBox(height: 6),

            CustomDropdown(
              value: vm.careerPath,
              items: const [
                "Select Career Path",
                "Software",
                "Core Engineering",
                "Management",
                "Research",
              ],
              onChanged: vm.setCareerPath,
            ),

            const SizedBox(height: 16),

            const Center(
              child: Text(
                "Review your details before registration",
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }
}
