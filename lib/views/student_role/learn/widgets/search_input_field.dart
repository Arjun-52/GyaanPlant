import 'package:flutter/material.dart';

class SearchInputField extends StatefulWidget {
  final Function(String) onChanged;

  const SearchInputField({super.key, required this.onChanged});

  @override
  State<SearchInputField> createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends State<SearchInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: _isFocused
              ? [const Color(0xFF0A1F19), const Color(0xFF0D2D24)]
              : [const Color(0xFF061310), const Color(0xFF0A1D18)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(
          color: _isFocused ? const Color(0xFF00E676) : const Color(0xFF163E33),
          width: 1.5,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Center(
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Gilroy-Semibold',
          ),
          cursorColor: const Color(0xFF00E676),
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),

            // Search Icon with animated glow
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isFocused ? const Color(0xFF00E676) : const Color(0xFF1D5244),
              size: 22,
            ),

            // Hint Text
            hintText: "Search courses, topics...",
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
              fontFamily: 'Gilroy-Semibold',
            ),
          ),
        ),
      ),
    );
  }
}

