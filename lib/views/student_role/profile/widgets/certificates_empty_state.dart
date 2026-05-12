import 'package:flutter/material.dart';

class CertificatesEmptyState extends StatelessWidget {
  const CertificatesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1F19), Color(0xFF0D2F24)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF12352C)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
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

          const SizedBox(height: 20),

          // Title
          const Text(
            "No certificates yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          const Text(
            "Complete courses to unlock certificates",
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
