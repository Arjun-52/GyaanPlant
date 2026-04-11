import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/role_viewmodel.dart';

import 'role_card.dart';

class RoleList extends StatelessWidget {
  final List<RoleModel> roles;

  const RoleList({super.key, required this.roles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        roles.length,
        (index) => RoleCard(role: roles[index]),
      ),
    );
  }
}
