import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginViewModel {
  void login(BuildContext context) {
    // your validation / API logic (optional)

    context.goNamed('role');
  }
}
