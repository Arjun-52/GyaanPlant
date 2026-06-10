import 'package:flutter/material.dart';

/// A premium Google Sign‑In button that matches the app's design language.
///
/// * White background with subtle elevation.
/// * Google logo on the left (expects the asset at `assets/images/google_logo.png`).
/// * Black text reading "Continue with Google".
/// * Rounded corners (16dp) – same radius as the primary button.
/// * Full‑width, fixed height (52dp) to align with other action buttons.
/// * Handles a tap via the provided [onPressed] callback.
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleSignInButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFCCCCCC),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  const BoxShadow(
                    color: Color(0x33000000), // subtle shadow
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google logo – ensure the asset exists in `assets/images/`
            Image.asset(
              'assets/images/google_logo.png',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
