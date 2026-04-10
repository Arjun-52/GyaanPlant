import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthRedirectText extends StatelessWidget {
  final String normalText;
  final String actionText;
  final String route;

  const AuthRedirectText({
    super.key,
    required this.normalText,
    required this.actionText,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(normalText),
        GestureDetector(
          onTap: () => context.go(route),
          child: Text(
            actionText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
