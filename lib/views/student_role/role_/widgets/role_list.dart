import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/role_viewmodel.dart';

import 'role_card.dart';

class RoleList extends StatelessWidget {
  final List<RoleModel> roles;

  const RoleList({super.key, required this.roles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row: Student and TPO
        Row(
          children: [
            Expanded(child: RoleCard(role: roles[0])),
            const SizedBox(width: 16),
            Expanded(child: RoleCard(role: roles[1])),
          ],
        ),
        const SizedBox(height: 16),
        // Second row: HOD/Principal and Alumni Mentor
        Row(
          children: [
            Expanded(child: RoleCard(role: roles[2])),
            const SizedBox(width: 16),
            Expanded(child: RoleCard(role: roles[3])),
          ],
        ),
      ],
    );
  }
}
