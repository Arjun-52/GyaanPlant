import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final bool isPassword;
  final Function(String) onChanged;
  final Widget? suffix;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.isPassword = false,
    this.suffix,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          // Semi-transparent deep dark green/black surface (glassmorphic tint)
          color: const Color(0xFF061410).withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFocused
                ? const Color(0xFF00E676) // neon green accent on focus
                : const Color(0xFF132B22), // subtle dark inactive green border
            width: _isFocused ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (_isFocused)
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.12),
                blurRadius: 10,
                spreadRadius: 0.5,
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                obscureText: widget.isPassword,
                onChanged: widget.onChanged,
                style: const TextStyle(
                  color: Color(0xE6FFFFFF), // elegant off-white
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    color: Color(0xFF4A6B5D), // soft gray-green hint text
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            if (widget.suffix != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: widget.suffix,
              ),
          ],
        ),
      ),
    );
  }
}
