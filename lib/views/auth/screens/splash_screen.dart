import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate after delay — router redirect will handle auth state
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/signin');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // Premium Glowing Logo Container
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1F1A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00C853).withValues(alpha: 0.25),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853).withValues(alpha: 0.15),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 72,
                color: Color(0xFF00E676),
              ),
            ),

            const SizedBox(height: 28),

            // Styled Branding Title
            const Text(
              "GyaanPlant",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            // Branding Subtitle
            const Text(
              "EMPOWERING STUDENTS • ENABLING LEADERS",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00E676),
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 60),

            // Modern, themed progress loader
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
              ),
            ),

            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}
