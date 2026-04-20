
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/views/auth/widgets/custom_text_field.dart';
import 'package:gyaanplant/views/auth/widgets/primary_button.dart';
import 'package:gyaanplant/views/auth/widgets/quick_login_section.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/student_viewmodel/auth_viewmodel.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
              const SizedBox(height: 20),

              const Icon(Icons.auto_awesome, size: 28),

              const SizedBox(height: 10),

              const Text(
                "GyaanPlant",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              const Text(
                "EMPOWERING STUDENTS TO LEARN, ENABLING STAFF TO LEAD.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),

              const SizedBox(height: 25),

              // CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("EMAIL"),
                    const SizedBox(height: 6),

                    CustomTextField(
                      hint: "name@institution.edu",
                      onChanged: vm.setEmail,
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("PASSWORD"),
                        Text("Forgot?", style: TextStyle(color: Colors.grey)),
                      ],
                    ),

                    const SizedBox(height: 6),

                    CustomTextField(
                      hint: "********",
                      isPassword: true,
                      onChanged: vm.setPassword,
                      suffix: const Icon(Icons.visibility_off, size: 18),
                    ),

                    const SizedBox(height: 20),

                    PrimaryButton(
                      text: vm.isLoading ? "Loading..." : "Login to Dashboard",
                      onPressed: vm.isLoading
                          ? null
                          : () {
                              vm.login(context);
                            },
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "QUICK LOGIN",
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    QuickLoginSection(
                      title: "PLATFORM",
                      items: [
                        {"icon": Icons.admin_panel_settings, "text": "ADMIN"},
                      ],
                    ),

                    const SizedBox(height: 16),

                    QuickLoginSection(
                      title: "ACADEMIC",
                      items: [
                        {"icon": Icons.business, "text": "ORG ADMIN"},
                        {"icon": Icons.rocket_launch, "text": "TTD"},
                        {"icon": Icons.badge, "text": "HOD"},
                        {"icon": Icons.groups, "text": "MENTOR"},
                        {"icon": Icons.school, "text": "STUDENT"},
                      ],
                    ),

                    const SizedBox(height: 16),

                    QuickLoginSection(
                      title: "CORPORATE",
                      items: [
                        {"icon": Icons.workspace_premium, "text": "EXEC"},
                        {"icon": Icons.account_tree, "text": "DEPT HEAD"},
                        {"icon": Icons.person, "text": "HR"},
                        {"icon": Icons.menu_book, "text": "L&D"},
                        {"icon": Icons.apartment, "text": "EMPLOYEE"},
                      ],
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("New here? "),
                          InkWell(
                            onTap: () {
                              context.go('/signup');
                            },
                            child: const Text(
                              "Create account",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
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
    );
  }
}
