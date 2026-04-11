import 'package:flutter/material.dart';
import 'package:gyaanplant/views/auth/widgets/auth_redirect_text.dart';
import 'package:gyaanplant/views/auth/widgets/custom_dropdown.dart';
import 'package:gyaanplant/views/auth/widgets/custom_text_field.dart';
import 'package:gyaanplant/views/auth/widgets/form_label.dart';
import 'package:gyaanplant/views/auth/widgets/primary_button.dart';
import 'package:gyaanplant/views/auth/widgets/step_indicator.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../viewmodels/student_viewmodel/auth_viewmodel.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              //  HEADER + STEPPER
              const SizedBox(height: 10),

              const Icon(Icons.auto_awesome, size: 28),

              const SizedBox(height: 10),

              const Text(
                "Join GyaanPlant",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              const Text(
                "PROFESSIONAL DEVELOPMENT, UNIFIED.",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),

              const SizedBox(height: 20),

              StepIndicator(currentStep: vm.currentStep),

              const SizedBox(height: 20),

              //  CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  STEP CONTENT
                    _buildStepContent(vm),

                    const SizedBox(height: 20),

                    //  BUTTON
                    Row(
                      children: [
                        // BACK BUTTON
                        if (vm.currentStep > 1)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: vm.previousStep,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text("Back"),
                            ),
                          ),

                        if (vm.currentStep > 1) const SizedBox(width: 10),

                        // CONTINUE BUTTON
                        Expanded(
                          child: PrimaryButton(
                            text: vm.currentStep == 3
                                ? "Register Now"
                                : "Continue",
                            onPressed: () => vm.nextStep(context),
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

  //  STEP SWITCH UI
  Widget _buildStepContent(AuthViewModel vm) {
    switch (vm.currentStep) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FormLabel(text: "FULL NAME"),
            const SizedBox(height: 6),
            CustomTextField(hint: "e.g. Alan Turing", onChanged: vm.setName),

            const SizedBox(height: 16),

            const FormLabel(text: "EMAIL"),
            const SizedBox(height: 6),
            CustomTextField(
              hint: "name@institution.edu",
              onChanged: vm.setEmail,
            ),

            const SizedBox(height: 16),

            const FormLabel(text: "PASSWORD"),
            const SizedBox(height: 6),
            CustomTextField(
              hint: "Min. 8 chars",
              isPassword: true,
              onChanged: vm.setPassword,
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FormLabel(text: "ROLE"),
            const SizedBox(height: 6),

            CustomDropdown(
              value: vm.role,
              items: const ["Student", "Mentor", "Admin"],
              onChanged: vm.setRole,
            ),

            const SizedBox(height: 16),

            const FormLabel(text: "COLLEGE"),
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
            const FormLabel(text: "BRANCH/STREAM"),
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

            const FormLabel(text: "CAREER PATH / INTEREST"),
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
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }
}
