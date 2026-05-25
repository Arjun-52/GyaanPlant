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

  @override
  void initState() {
    super.initState();
    final vm = context.read<JobViewModel>();
    _controller = TextEditingController(text: vm.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F2F27), // slightly smoother green
            Color(0xFF0B2620),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (query) {
                context.read<JobViewModel>().updateSearchQuery(query);
              },
              style: const TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                hintText: "Search roles, companies...",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const Icon(Icons.tune, color: Colors.white54, size: 20),
        ],
      ),
    );
  }
}
