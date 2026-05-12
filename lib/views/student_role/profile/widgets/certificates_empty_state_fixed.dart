import 'package:flutter/material.dart';

class CertificatesEmptyStateFixed extends StatelessWidget {
  const CertificatesEmptyStateFixed({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a simple Column structure that's compatible with both ListView and other contexts
    return Column(
      children: [
        const SizedBox(height: 32),
        // Icon container
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF0F2A22),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Color(0xFF1E4D3D).withOpacity(0.3)),
            ),
            child: Icon(
              Icons.school_outlined,
              size: 36,
              color: Color(0xFF00C853).withOpacity(0.7),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Title
        const Text(
          "No certificates yet",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Subtitle
        const Text(
          "Complete courses to unlock certificates",
          style: TextStyle(color: Colors.white54, fontSize: 14),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
