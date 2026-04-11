import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/role_viewmodel.dart';

import '../widgets/header_section.dart';
import '../widgets/role_list.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = RoleViewModel();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeaderSection(),
                RoleList(roles: viewModel.roles),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
