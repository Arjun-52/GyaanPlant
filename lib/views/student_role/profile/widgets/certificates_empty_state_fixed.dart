import 'package:flutter/material.dart';

class CertificatesEmptyStateFixed extends StatelessWidget {
  const CertificatesEmptyStateFixed({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B2B23), Color(0xFF02100C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF00E676).withOpacity(0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0x1A00E676),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00E676).withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withOpacity(0.1),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 32,
              color: Color(0xFF00E676),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Certificates Yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Complete courses to unlock verified certificates and showcase them to recruiters.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
