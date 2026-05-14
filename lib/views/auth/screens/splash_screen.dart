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
    // Navigate to role screen after a delay
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/role');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF020B08),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spacer to push the content slightly above center
            Spacer(flex: 3),
            
            // Logo
            Image(
              image: AssetImage('assets/images/logo.png'),
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            
            SizedBox(height: 24),
            
           
            
            // Spacer to keep the balance
            Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}
