import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Helper to generate the premium curved cutout combined path.
Path getCurvedPath(Size size, double animatedX) {
  final double width = size.width;
  final double height = size.height;
  const double borderRadius = 24.0;
  const double cutoutWidth = 76.0;
  const double curveHeight = 26.0;
  const double shoulderRadius = 12.0;
  const double bottomRadius = 16.0;

  // 1. Base rounded rectangle pill
  final Path background = Path()
    ..addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      Radius.circular(borderRadius),
    ));

  // 2. The dip U-shape cutout
  final Path cutout = Path();
  final double leftX = animatedX - cutoutWidth / 2;
  final double rightX = animatedX + cutoutWidth / 2;

  cutout.moveTo(leftX - shoulderRadius, -20);
  cutout.lineTo(leftX - shoulderRadius, 0);

  // Top-left shoulder
  cutout.quadraticBezierTo(leftX, 0, leftX, shoulderRadius);

  // Descent & bottom left curve
  cutout.lineTo(leftX, curveHeight - bottomRadius);
  cutout.quadraticBezierTo(leftX, curveHeight, leftX + bottomRadius, curveHeight);

  // Floor to bottom right curve
  cutout.lineTo(rightX - bottomRadius, curveHeight);
  cutout.quadraticBezierTo(rightX, curveHeight, rightX, curveHeight - bottomRadius);

  // Ascent & top right shoulder
  cutout.lineTo(rightX, shoulderRadius);
  cutout.quadraticBezierTo(rightX, 0, rightX + shoulderRadius, 0);

  // Close above top plane
  cutout.lineTo(rightX + shoulderRadius, -20);
  cutout.close();

  // 3. Combined subtraction path
  return Path.combine(PathOperation.difference, background, cutout);
}

/// Custom clipper to clip the glass body using the curved cutout path.
class CurvedNavbarClipper extends CustomClipper<Path> {
  final double animatedX;

  CurvedNavbarClipper({required this.animatedX});

  @override
  Path getClip(Size size) {
    return getCurvedPath(size, animatedX);
  }

  @override
  bool shouldReclip(CurvedNavbarClipper oldClipper) {
    return oldClipper.animatedX != animatedX;
  }
}

/// Custom painter to paint the neon aura, drop shadows, and green borders.
class CurvedNavbarPainter extends CustomPainter {
  final double animatedX;

  CurvedNavbarPainter({required this.animatedX});

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = getCurvedPath(size, animatedX);

    // 1. Draw glowing neon green aura behind
    final Paint shadowPaint1 = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.03)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path.shift(const Offset(0, -2)), shadowPaint1);

    // 2. Draw standard dark drop shadow
    final Paint shadowPaint2 = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path.shift(const Offset(0, 6)), shadowPaint2);

    // 3. Draw neon green subtle border highlight
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF00C853).withValues(alpha: 0.16)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CurvedNavbarPainter oldDelegate) {
    return oldDelegate.animatedX != animatedX;
  }
}

class MentorBottomNav extends StatelessWidget {
  final int currentIndex;

  const MentorBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/mentor-dashboard');
        break;
      case 1:
        context.go('/mentor-bookings');
        break;
      case 2:
        context.go('/mentor-sessions');
        break;
      case 3:
        context.go('/mentor-earnings');
        break;
      case 4:
        context.go('/mentor-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<IconData> inactiveIcons = [
      Icons.home_outlined,
      Icons.calendar_month_outlined,
      Icons.chat_bubble_outline_rounded,
      Icons.monetization_on_outlined,
      Icons.person_outline_rounded,
    ];

    final List<IconData> activeIcons = [
      Icons.home_rounded,
      Icons.calendar_month_rounded,
      Icons.chat_bubble_rounded,
      Icons.monetization_on_rounded,
      Icons.person_rounded,
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        height: 68,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;
            final double tabWidth = width / inactiveIcons.length;

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: currentIndex.toDouble(), end: currentIndex.toDouble()),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack, // Beautiful overshoot slide bounce physics
              builder: (context, animValue, child) {
                final double animatedX = (animValue + 0.5) * tabWidth;
                final int activeCircleIndex = animValue.round().clamp(0, activeIcons.length - 1);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Shadow and premium neon green border layer
                    CustomPaint(
                      size: Size(width, height),
                      painter: CurvedNavbarPainter(animatedX: animatedX),
                    ),

                    // 2. Glassmorphism backdrop blur base
                    ClipPath(
                      clipper: CurvedNavbarClipper(animatedX: animatedX),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: width,
                          height: height,
                          decoration: const BoxDecoration(
                            color: Color(0xEE020B08), // Premium dark translucent fill
                          ),
                        ),
                      ),
                    ),

                    // 3. Transparent distributed Row for inactive icons
                    Positioned.fill(
                      child: Row(
                        children: List.generate(inactiveIcons.length, (i) {
                          return _buildInactiveIcon(context, i, inactiveIcons[i], animValue);
                        }),
                      ),
                    ),

                    // 4. Elevated floating neon green active circle (centered on animatedX)
                    Positioned(
                      left: animatedX - 24, // 24 is the circle radius (diameter 48)
                      top: -12, // elevated upwards above the top edge
                      child: GestureDetector(
                        onTap: () => _onTap(context, activeCircleIndex),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00E676),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E676).withValues(alpha: 0.35),
                                blurRadius: 16,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: activeCircleIndex == 0
                                ? CustomHomeIcon(
                                    isActive: true,
                                    color: const Color(0xFF031B15), // Dark charcoal contrast
                                    size: 22,
                                    key: const ValueKey<int>(0),
                                  )
                                : Icon(
                                    activeIcons[activeCircleIndex],
                                    key: ValueKey<int>(activeCircleIndex),
                                    color: const Color(0xFF031B15), // Dark charcoal contrast
                                    size: 22,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInactiveIcon(BuildContext context, int i, IconData iconData, double animValue) {
    // Opacity is 0.0 at the active center, graduating up to 1.0 as the active circle moves away.
    final double distance = (animValue - i).abs();
    final double opacity = distance.clamp(0.0, 1.0);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(context, i),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 68,
          alignment: Alignment.center,
          child: Opacity(
            opacity: opacity,
            child: i == 0
                ? CustomHomeIcon(
                    isActive: false,
                    color: Colors.white38,
                    size: 22,
                  )
                : Icon(
                    iconData,
                    color: Colors.white38,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Helper to generate outer rounded house contour
Path getHousePath(double s) {
  final Path path = Path();
  final double r = s * 0.16;
  path.moveTo(s * 0.1 + r, s * 0.9);
  path.quadraticBezierTo(s * 0.1, s * 0.9, s * 0.1, s * 0.9 - r);
  path.lineTo(s * 0.1, s * 0.45 + r);
  path.quadraticBezierTo(s * 0.1, s * 0.45, s * 0.1 + r, s * 0.45 - r * 0.6);
  path.lineTo(s * 0.5 - r, s * 0.15 + r * 0.6);
  path.quadraticBezierTo(s * 0.5, s * 0.15, s * 0.5 + r, s * 0.15 + r * 0.6);
  path.lineTo(s * 0.9 - r, s * 0.45 - r * 0.6);
  path.quadraticBezierTo(s * 0.9, s * 0.45, s * 0.9, s * 0.45 + r);
  path.lineTo(s * 0.9, s * 0.9 - r);
  path.quadraticBezierTo(s * 0.9, s * 0.9, s * 0.9 - r, s * 0.9);
  path.close();
  return path;
}

Path getDoorPath(double s) {
  final Path path = Path();
  final double doorWidth = s * 0.065;
  final double doorHeight = s * 0.16;
  final double doorLeft = s * 0.5 - doorWidth / 2;
  final double doorTop = s * 0.62;
  path.addRRect(RRect.fromRectAndRadius(
    Rect.fromLTWH(doorLeft, doorTop, doorWidth, doorHeight),
    Radius.circular(doorWidth / 2),
  ));
  return path;
}

class CustomHomeIcon extends StatelessWidget {
  final bool isActive;
  final Color color;
  final double size;

  const CustomHomeIcon({
    super.key,
    required this.isActive,
    required this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HomeIconPainter(
          isActive: isActive,
          color: color,
        ),
      ),
    );
  }
}

class _HomeIconPainter extends CustomPainter {
  final bool isActive;
  final Color color;

  _HomeIconPainter({required this.isActive, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Paint paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    if (!isActive) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(getHousePath(s), paint);

      final Paint doorPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawPath(getDoorPath(s), doorPaint);
    } else {
      paint.style = PaintingStyle.fill;
      final Path combined = getHousePath(s);
      combined.fillType = PathFillType.evenOdd;
      combined.addPath(getDoorPath(s), Offset.zero);
      canvas.drawPath(combined, paint);
    }
  }

  @override
  bool shouldRepaint(_HomeIconPainter oldDelegate) {
    return oldDelegate.isActive != isActive || oldDelegate.color != color;
  }
}
