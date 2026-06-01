import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _buttonOffset;
  // Background animation fields
  late final AnimationController _bgController;
  late final Animation<Alignment> _bgAlignment;
  // Logo slide-down animation
  late final Animation<Offset> _logoSlide;
  // Button pulse animation
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Background animation controller
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _bgAlignment = Tween<Alignment>(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
    _bgController.repeat(reverse: true);

    // Main controller drives logo + button entrance
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Logo slides down from top (0.0–0.6) — smooth decelerate
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Logo scale — smooth decelerate (no bounce)
    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.decelerate),
    );

    // Logo fade in (0.0–0.4)
    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    // Button slides up after logo (0.7–1.0)
    _buttonOffset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Button subtle pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Start pulse after main animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.repeat(reverse: true);
      }
    });

    // Start animations
    _controller.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bgController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Stack(
            children: [
              // Moving background image
              AnimatedBuilder(
                animation: _bgAlignment,
                builder: (context, child) {
                  return Positioned.fill(
                    child: Image.asset(
                      'assets/images/splash_bg.png',
                      fit: BoxFit.cover,
                      alignment: _bgAlignment.value,
                    ),
                  );
                },
              ),
              // Optional subtle floating particles (simple circles)
              Positioned(
                top: 80,
                left: 30,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x33FFFFFF),
                  ),
                ),
              ),
              Positioned(
                bottom: 150,
                right: 60,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x33FFFFFF),
                  ),
                ),
              ),
              // Centered branding content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo with slide-down + fade + scale animation
                    SlideTransition(
                      position: _logoSlide,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Soft radial glow behind logo
                              Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF4169E1).withAlpha(60),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 1.0],
                                  ),
                                ),
                              ),
                              // Logo image
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/images/GyaanPlant Latest Logo.png',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Branding tagline
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: const Text(
                        'Empowering Digital Learners',
                        style: TextStyle(
                          fontFamily: 'Gilroy-Semibold',
                          color: Color(0xFFE8FFF0),
                          fontSize: 28,
                          letterSpacing: -1.0,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Premium CTA button at bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: SlideTransition(
                    position: _buttonOffset,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: GestureDetector(
                          onTap: () {
                            context.go('/role');
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00E676),
                                  Color(0xFF00C853),
                                  Color(0xFF009624),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E676).withAlpha(100),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: Colors.black.withAlpha(40),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Let\u2019s Start Your Learning Journey",
                                    style: TextStyle(
                                      fontFamily: 'Gilroy-Semibold',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
