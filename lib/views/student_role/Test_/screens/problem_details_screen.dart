import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import 'package:gyaanplant/models/assessment/problem_model.dart';
import 'package:gyaanplant/network/api_endpoints.dart';
import 'package:gyaanplant/network/api_manager.dart';

class ProblemDetailsScreen extends StatefulWidget {
  final String problemId;

  const ProblemDetailsScreen({super.key, required this.problemId});

  @override
  State<ProblemDetailsScreen> createState() => _ProblemDetailsScreenState();
}

class _ProblemDetailsScreenState extends State<ProblemDetailsScreen>
    with SingleTickerProviderStateMixin {
  static const _tag = 'ProblemDetailsScreen';

  late TabController _tabController;
  final _assessment = ApiService().assessment;
  
  ProblemDetailModel? _problem;
  bool _isLoading = true;
  String? _errorMessage;

  // Code editor state variables
  String _selectedLanguage = 'JS';
  final TextEditingController _codeController = TextEditingController();
  bool _isSubmitting = false;

  // Console state variables
  String _consoleOutput = "Terminal initialized. Ready to execute code.\n";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _assessment.getProblemDetail(widget.problemId);
      if (res.isSuccess && res.data != null) {
        setState(() {
          _problem = res.data;
          _isLoading = false;
        });
        
        // Setup listener and restore draft once problem loads
        await _loadDraftCode();
        _codeController.addListener(_onCodeChanged);
      } else {
        setState(() {
          _errorMessage = res.error?.message ?? "Failed to load problem details";
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error(_tag, "Error loading problem detail: $e");
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Load starter templates or restore draft saved in SharedPreferences
  Future<void> _loadDraftCode() async {
    if (_problem == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = "draft_problem_${widget.problemId}_$_selectedLanguage";
      final savedDraft = prefs.getString(key);

      if (savedDraft != null && savedDraft.trim().isNotEmpty) {
        _codeController.text = savedDraft;
      } else {
        _codeController.text = _getStarterTemplate(_selectedLanguage);
      }
    } catch (e) {
      AppLogger.error(_tag, "Failed to load draft code: $e");
      _codeController.text = _getStarterTemplate(_selectedLanguage);
    }
  }

  // Listener called when text is typed in the editor to auto-save draft
  void _onCodeChanged() async {
    if (_problem == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = "draft_problem_${widget.problemId}_$_selectedLanguage";
      await prefs.setString(key, _codeController.text);
    } catch (e) {
      AppLogger.error(_tag, "Failed to save draft code: $e");
    }
  }

  String _getStarterTemplate(String language) {
    if (_problem == null) return '';

    final starter = _problem!.starterCode;
    switch (language) {
      case 'JS':
        return starter.javascript.isNotEmpty
            ? starter.javascript
            : "function solve(head) {\n    // Write your JavaScript code here\n}";
      case 'Python':
        return starter.python.isNotEmpty
            ? starter.python
            : "def solve(head):\n    # Write your Python code here\n    pass";
      case 'Java':
        return starter.java.isNotEmpty
            ? starter.java
            : "class Solution {\n    public boolean solve(ListNode head) {\n        // Write your Java code here\n        return false;\n    }\n}";
      default:
        return '';
    }
  }

  // Action triggered when selecting a different language from dropdown
  void _onLanguageChanged(String newLanguage) async {
    // 1. Remove listener temporarily to avoid overwriting during text replacement
    _codeController.removeListener(_onCodeChanged);

    // 2. Update selected language
    setState(() {
      _selectedLanguage = newLanguage;
    });

    // 3. Load/restore code for the newly selected language
    await _loadDraftCode();

    // 4. Re-attach listener
    _codeController.addListener(_onCodeChanged);
  }

  // Call the real execution sandbox API
  Future<void> _runCode() async {
    if (_problem == null) return;

    setState(() {
      _consoleOutput = "Running code in backend environment...\n";
      _tabController.index = 2; // Auto shift to Console tab
    });

    try {
      final res = await NetworkAPIManager.instance.post<dynamic>(
        ApiEndpoints.problemsRun,
        data: {
          "problemId": widget.problemId,
          "language": _selectedLanguage.toLowerCase(),
          "code": _codeController.text,
        },
      );

      if (res.isSuccess) {
        final data = res.data;
        final output = data is Map<String, dynamic> ? data['output']?.toString() : data?.toString();
        setState(() {
          _consoleOutput += "\n[Success] Code compilation executed successfully.\n\nOutput:\n${output ?? 'No standard output.'}";
        });
      } else {
        // Fallback placeholder notice if endpoint is offline or unavailable
        setState(() {
          _consoleOutput += "\n⚠️ Execution Service Placeholder:\n"
              "Backend returned code (${res.statusCode}): ${res.error?.message ?? 'Service Unavailable.'}\n\n"
              "The execution server is currently offline or undergoing maintenance.";
        });
      }
    } catch (e) {
      setState(() {
        _consoleOutput += "\n❌ Connection Failed:\n"
            "Execution service returned error: $e\n\n"
            "[Placeholder] Execution service is currently offline.";
      });
    }
  }

  // Call the submission API
  Future<void> _submitCode() async {
    if (_problem == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final res = await NetworkAPIManager.instance.post<dynamic>(
        "${ApiEndpoints.problems}/${widget.problemId}/submit",
        data: {
          "problemId": widget.problemId,
          "language": _selectedLanguage.toLowerCase(),
          "code": _codeController.text,
        },
      );

      setState(() {
        _isSubmitting = false;
      });

      if (res.isSuccess) {
        _showDialog(
          title: "Submission Passed! 🎉",
          message: "All test cases executed successfully.\nPoints earned: +${_problem!.points} PTS!",
          isSuccess: true,
        );
      } else {
        // Handle unavailable backend endpoint gracefully with a simple placeholder warning
        _showDialog(
          title: "Submission Offline",
          message: "The backend submission endpoint returned: ${res.error?.message ?? 'Service Unavailable.'}\n\n"
              "Submission service is currently offline.",
          isSuccess: false,
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showDialog(
        title: "Connection Error",
        message: "Failed to connect to the submission server:\n$e\n\nSubmission service is currently offline.",
        isSuccess: false,
      );
    }
  }

  void _showDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F2A22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSuccess ? Colors.green.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSuccess ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "OK",
                style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _ProblemDetailsShimmer();
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF020B08),
        appBar: AppBar(
          backgroundColor: const Color(0xFF020B08),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 50, color: Colors.white38),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? "An error occurred",
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.black,
                ),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (_problem == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF020B08),
        appBar: AppBar(
          backgroundColor: const Color(0xFF020B08),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty, size: 50, color: Colors.white38),
              const SizedBox(height: 12),
              const Text(
                "No problem details available",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.black,
                ),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final problem = _problem!;
    Color difficultyColor;
    switch (problem.difficulty.toLowerCase()) {
      case 'easy':
        difficultyColor = Colors.green;
        break;
      case 'medium':
        difficultyColor = Colors.orange;
        break;
      case 'hard':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.green;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020B08),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          problem.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: difficultyColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: difficultyColor.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Text(
                problem.difficulty.toUpperCase(),
                style: TextStyle(
                  color: difficultyColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "+${problem.points} PTS",
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00C853),
          labelColor: const Color(0xFF00E676),
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: "Problem"),
            Tab(text: "Code"),
            Tab(text: "Console"),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildProblemTab(problem, difficultyColor),
              _buildCodeTab(problem),
              _buildConsoleTab(),
            ],
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProblemTab(ProblemDetailModel problem, Color difficultyColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description section
          const Text(
            "Description",
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            problem.description,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Examples section
          if (problem.examples.isNotEmpty) ...[
            const Text(
              "Examples",
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...problem.examples.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final ex = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2A22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Example $idx",
                      style: const TextStyle(
                        color: Color(0xFF00E676),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCodeField("Input", ex.input),
                    const SizedBox(height: 8),
                    _buildCodeField("Output", ex.output),
                    if (ex.explanation != null && ex.explanation!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        "Explanation:",
                        style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ex.explanation!,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Constraints section
          const Text(
            "Constraints",
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2A22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.8),
            ),
            child: problem.constraints.isEmpty
                ? const Text(
                    "No constraints available",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: problem.constraints.map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("• ", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                c,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 24),

          // Horizontal Tags chips row
          if (problem.tags.isNotEmpty) ...[
            const Text(
              "Tags",
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: problem.tags.map((tag) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Limits section
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Time Limit", style: TextStyle(color: Colors.white38, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                        "${problem.timeLimit} ms",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: Colors.white12),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Memory Limit", style: TextStyle(color: Colors.white38, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                        "${problem.memoryLimit} MB",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCodeField(String label, String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            code,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeTab(ProblemDetailModel problem) {
    return Column(
      children: [
        // Language Selector Dropdown Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFF031E17),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Select Language:",
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2A22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00C853).withValues(alpha: 0.3), width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    dropdownColor: const Color(0xFF0F2A22),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E676)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'JS', child: Text('JS')),
                      DropdownMenuItem(value: 'Python', child: Text('Python')),
                      DropdownMenuItem(value: 'Java', child: Text('Java')),
                    ],
                    onChanged: (String? val) {
                      if (val != null) {
                        _onLanguageChanged(val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Monospace Multiline Editor box
        Expanded(
          child: Container(
            color: const Color(0xFF030D0A), // High contrast IDE background
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.topLeft,
            child: TextField(
              controller: _codeController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Colors.white70,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "// Start coding your solution...",
                hintStyle: TextStyle(color: Colors.white24, fontFamily: 'monospace', fontSize: 13),
              ),
            ),
          ),
        ),

        // Sticky Bottom Row: Run & Submit buttons
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF031E17),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _runCode,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00E676),
                      side: const BorderSide(color: Color(0xFF00C853), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "RUN",
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "SUBMIT",
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsoleTab() {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E676),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "CONSOLE OUTPUT",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _consoleOutput,
              style: const TextStyle(
                color: Color(0xFF00FF66), // Retro matrix terminal green
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProblemDetailsShimmer extends StatefulWidget {
  const _ProblemDetailsShimmer();

  @override
  State<_ProblemDetailsShimmer> createState() => _ProblemDetailsShimmerState();
}

class _ProblemDetailsShimmerState extends State<_ProblemDetailsShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.3 + (_controller.value * 0.35);
        return Scaffold(
          backgroundColor: const Color(0xFF020B08),
          appBar: AppBar(
            backgroundColor: const Color(0xFF020B08),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white24, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Opacity(
              opacity: opacity,
              child: Container(
                width: 140,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description title
                Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Description lines
                ...List.generate(4, (index) {
                  final widths = [double.infinity, double.infinity, 250.0, 180.0];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: widths[index],
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                // Examples title
                Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Example Card
                Opacity(
                  opacity: opacity,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2A22).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Constraints title
                Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 90,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Constraints Card
                Opacity(
                  opacity: opacity,
                  child: Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2A22).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
