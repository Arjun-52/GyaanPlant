import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/job_viewmodel.dart';

class JobSearchBar extends StatefulWidget {
  const JobSearchBar({super.key});

  @override
  State<JobSearchBar> createState() => _JobSearchBarState();
}

class _JobSearchBarState extends State<JobSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<JobViewModel>();
    _controller = TextEditingController(text: vm.searchQuery);
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: _isFocused
              ? [const Color(0xFF0C2B22), const Color(0xFF031410)]
              : [const Color(0xFF0B2B23).withOpacity(0.4), const Color(0xFF02100C).withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: _isFocused
              ? const Color(0xFF00E676).withOpacity(0.3)
              : const Color(0xFF00E676).withOpacity(0.1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? const Color(0xFF00E676).withOpacity(0.06)
                : Colors.black.withOpacity(0.2),
            blurRadius: _isFocused ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: _isFocused ? const Color(0xFF00E676) : Colors.white38,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (query) {
                context.read<JobViewModel>().updateSearchQuery(query);
              },
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: const Color(0xFF00E676),
              decoration: const InputDecoration(
                hintText: "Search positions, tech stacks, locations...",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                context.read<JobViewModel>().updateSearchQuery("");
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white38,
                  size: 18,
                ),
              ),
            ),
          const SizedBox(width: 4),
          Container(
            height: 24,
            width: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.tune_rounded,
            color: _isFocused ? const Color(0xFF00E676) : Colors.white38,
            size: 18,
          ),
        ],
      ),
    );
  }
}
