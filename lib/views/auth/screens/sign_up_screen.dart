import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/views/auth/widgets/auth_redirect_text.dart';
import 'package:gyaanplant/views/auth/widgets/custom_dropdown.dart';
import 'package:gyaanplant/views/auth/widgets/custom_text_field.dart';
import 'package:gyaanplant/views/auth/widgets/form_label.dart';
import 'package:gyaanplant/views/auth/widgets/primary_button.dart';
import 'package:gyaanplant/views/auth/widgets/step_indicator.dart';
import 'package:provider/provider.dart';

import '../../../models/auth/college_dropdown_model.dart';
import '../../../viewmodels/student_viewmodel/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  late TextEditingController _customBranchController;
  late TextEditingController _customPathController;
  late TextEditingController _customCollegeController;

  ///  THEME COLORS
  static const bgColor = Color(0xFF020B08);
  static const cardColor = Color(0xFF0D1F1A);
  static const primaryGreen = Color(0xFF00C853);
  static const accentGreen = Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    _customBranchController = TextEditingController();
    _customPathController = TextEditingController();
    _customCollegeController = TextEditingController();
    
    // Ensure colleges are fetched and initial controller values are set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<AuthViewModel>(context, listen: false);
      _customBranchController.text = vm.branch;
      _customPathController.text = vm.careerPath;
      if (vm.selectedCollege?.id == 'other_college') {
        _customCollegeController.text = vm.college;
      }
      vm.fetchColleges();
    });
  }

  @override
  void dispose() {
    _customBranchController.dispose();
    _customPathController.dispose();
    _customCollegeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);
    return WillPopScope(
      onWillPop: () async {
        if (vm.currentStep > 1) {
          vm.previousStep();
          return false;
        }
        context.go('/role');
        return false;
      },
      child: Scaffold(
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

              // STEP INDICATOR
              StepIndicator(currentStep: vm.currentStep),

              const SizedBox(height: 20),

              // CARD
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

                    // BUTTONS
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
          ],
        );

      case 2:
        final dropdownColleges = List<CollegeDropdownModel>.from(vm.colleges);

        if (!dropdownColleges.any((c) => c.id == 'other_college')) {
          dropdownColleges.add(const CollegeDropdownModel(id: 'other_college', name: 'Other', city: ''));
        }

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
                "Employee / Staff",
              ],
              onChanged: vm.setRole,
            ),

            const SizedBox(height: 16),

            const FormLabel(text: "COLLEGE", color: Colors.white70),
            const SizedBox(height: 6),

            // Dynamic College Dropdown – shows loading spinner while fetching
            vm.isCollegeLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator(color: accentGreen)),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 52, // Same premium height as other fields
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF061410).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF132B22),
                        width: 1.0,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CollegeDropdownModel?>(
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0x9900E676), // Opacity-reduced accent green
                          size: 24,
                        ),
                        dropdownColor: const Color(0xFF0D1F1A), // Premium dark surface
                        hint: const Text(
                          'Select College',
                          style: TextStyle(
                            color: Color(0xFF4A6B5D), // Soft gray-green hint text
                            fontSize: 14,
                          ),
                        ),
                        value: vm.selectedCollege,
                        items: dropdownColleges
                            .map((c) => DropdownMenuItem<CollegeDropdownModel?>(
                                  value: c,
                                  child: Text(
                                    c.name,
                                    style: const TextStyle(
                                      color: Color(0xE6FFFFFF),
                                      fontSize: 15,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (CollegeDropdownModel? c) {
                          vm.setSelectedCollege(c);
                          if (c?.id == 'other_college') {
                            _customCollegeController.text = "";
                            vm.setCollege(""); // Reset typed college to blank
                          }
                        },
                      ),
                    ),
                  ),

            if (vm.selectedCollege?.id == 'other_college') ...[
              const SizedBox(height: 16),
              const FormLabel(text: "COLLEGE NAME", color: Colors.white70),
              const SizedBox(height: 6),
              CustomTextField(
                hint: "Enter name",
                controller: _customCollegeController,
                onChanged: (val) {
                  vm.setCollege(val);
                },
              ),
            ],
          ],
        );

      case 3:
        final isStudent = vm.role.toLowerCase() == 'student';

        if (isStudent) {
          final standardBranches = [
            "Select Branch",
            "CSE",
            "ECE",
            "EEE",
            "Mechanical",
            "Civil",
            "Other (Type custom)",
          ];

          final standardPaths = [
            "Select Career Path",
            "Software",
            "Core Engineering",
            "Management",
            "Research",
            "Other (Type custom)",
          ];

          // Determine current selected dropdown branch value
          final isBranchCustom = vm.branch.isNotEmpty && 
              !["Select Branch", "CSE", "ECE", "EEE", "Mechanical", "Civil"].contains(vm.branch) &&
              vm.branch != "Other (Type custom)";
          
          final dropdownBranchValue = isBranchCustom ? vm.branch : (vm.branch.isEmpty ? "Select Branch" : vm.branch);

          final dropdownBranchItems = List<String>.from(standardBranches);
          if (isBranchCustom && !dropdownBranchItems.contains(vm.branch)) {
            dropdownBranchItems.insert(dropdownBranchItems.length - 1, vm.branch);
          }

          // Determine current selected dropdown career path value
          final isPathCustom = vm.careerPath.isNotEmpty && 
              !["Select Career Path", "Software", "Core Engineering", "Management", "Research"].contains(vm.careerPath) &&
              vm.careerPath != "Other (Type custom)";

          final dropdownPathValue = isPathCustom ? vm.careerPath : (vm.careerPath.isEmpty ? "Select Career Path" : vm.careerPath);

          final dropdownPathItems = List<String>.from(standardPaths);
          if (isPathCustom && !dropdownPathItems.contains(vm.careerPath)) {
            dropdownPathItems.insert(dropdownPathItems.length - 1, vm.careerPath);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormLabel(text: "BRANCH/STREAM", color: Colors.white70),
              const SizedBox(height: 6),

              CustomDropdown(
                value: dropdownBranchValue,
                items: dropdownBranchItems,
                onChanged: (val) {
                  if (val == "Other (Type custom)") {
                    _customBranchController.text = "";
                    vm.setBranch(""); // Require user to type something
                  } else {
                    vm.setBranch(val);
                  }
                },
              ),

              if (vm.branch == "Other (Type custom)" || isBranchCustom || vm.branch.isEmpty) ...[
                const SizedBox(height: 10),
                CustomTextField(
                  hint: "Type your Branch / Stream",
                  controller: _customBranchController,
                  onChanged: (val) {
                    vm.setBranch(val);
                  },
                ),
              ],

              const SizedBox(height: 16),

              const FormLabel(
                text: "CAREER PATH / INTEREST",
                color: Colors.white70,
              ),
              const SizedBox(height: 6),

              CustomDropdown(
                value: dropdownPathValue,
                items: dropdownPathItems,
                onChanged: (val) {
                  if (val == "Other (Type custom)") {
                    _customPathController.text = "";
                    vm.setCareerPath(""); // Require user to type something
                  } else {
                    vm.setCareerPath(val);
                  }
                },
              ),

              if (vm.careerPath == "Other (Type custom)" || isPathCustom || vm.careerPath.isEmpty) ...[
                const SizedBox(height: 10),
                CustomTextField(
                  hint: "Type your Career Path / Interest",
                  controller: _customPathController,
                  onChanged: (val) {
                    vm.setCareerPath(val);
                  },
                ),
              ],

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  "Review your details before registration",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
            ],
          );
        } else {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    "Review your details before registration",
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
              ),
            ],
          );
        }

      default:
        return const SizedBox();
    }
  }
}
