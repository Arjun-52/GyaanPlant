import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            // Spacer to push the content slightly above center
            const Spacer(flex: 3),
            
            // Logo
            SvgPicture.asset(
              'assets/images/gyaanplant_svg_logo.svg',
              width: 180,
              height: 180,
            ),
            
            const SizedBox(height: 24),
            
           
            
            // Spacer to keep the balance
            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}
