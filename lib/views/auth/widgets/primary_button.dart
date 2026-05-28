import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;

  const PrimaryButton({super.key, required this.text, this.onPressed});

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: (_) {
        if (isEnabled) _controller.forward();
      },
      onTapUp: (_) {
        if (isEnabled) {
          _controller.reverse();
          widget.onPressed?.call();
        }
      },
      onTapCancel: () {
        if (isEnabled) _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: 52, // Unified modern premium height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), // Premium corner radius
            gradient: isEnabled
                ? const LinearGradient(
                    colors: [
                      Color(0xFF00C853), // primaryGreen
                      Color(0xFF00E676), // accentGreen
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isEnabled ? null : const Color(0xFF112E23), // Muted dark green if disabled
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF00C853).withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: TextStyle(
              color: isEnabled ? const Color(0xFF020B08) : Colors.white30, // Premium dark text on neon background
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

