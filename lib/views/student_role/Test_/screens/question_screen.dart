import 'package:flutter/material.dart';
import '../../../../models/assessment/mock_test_models.dart';

class QuestionScreen extends StatefulWidget {
  final String sectionTitle;
  final List<PrepPackQuestionModel> questions;
  final MarkingSchemeModel markingScheme;

  const QuestionScreen({
    super.key,
    required this.sectionTitle,
    required this.questions,
    required this.markingScheme,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _currentIndex = 0;
  final Map<int, int?> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    // Initialize all to null (unattempted)
    for (int i = 0; i < widget.questions.length; i++) {
      _selectedAnswers[i] = null;
    }
  }

  void _submitAssessment() {
    int correctCount = 0;
    int wrongCount = 0;
    int unattemptedCount = 0;
    double score = 0.0;

    for (int i = 0; i < widget.questions.length; i++) {
      final q = widget.questions[i];
      final selected = _selectedAnswers[i];
      if (selected == null) {
        unattemptedCount++;
      } else if (selected == q.correctIndex) {
        correctCount++;
        score += widget.markingScheme.correct;
      } else {
        wrongCount++;
        score -= (widget.markingScheme.negative.abs() + widget.markingScheme.wrong);
      }
    }

    final totalAttempted = correctCount + wrongCount;
    final int accuracy = totalAttempted > 0 
        ? ((correctCount / totalAttempted) * 100).toInt() 
        : 0;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Results",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final scale = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: scale,
          child: AlertDialog(
            backgroundColor: const Color(0xFF0F2A22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF00C853), width: 1.5),
            ),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0x1F00C853),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Color(0xFF00C853),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Practice Completed!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.sectionTitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Score box
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020B08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "YOUR SCORE",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          score.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFF00C853),
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Details row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("Accuracy", "$accuracy%", Colors.blueAccent),
                      _buildStatItem("Correct", "$correctCount", const Color(0xFF00C853)),
                      _buildStatItem("Wrong", "$wrongCount", Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (unattemptedCount > 0)
                    Text(
                      "Unattempted questions: $unattemptedCount",
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actionsPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            actions: [
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  setState(() {
                    _currentIndex = 0;
                    for (int i = 0; i < widget.questions.length; i++) {
                      _selectedAnswers[i] = null;
                    }
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text("Retry Pack"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to Details screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: const Color(0xFF020B08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text("Finish"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF020B08),
        appBar: AppBar(
          backgroundColor: const Color(0xFF020B08),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.sectionTitle, style: const TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text(
            "No questions available in this section.",
            style: TextStyle(color: Colors.white38),
          ),
        ),
      );
    }

    final currentQuestion = widget.questions[_currentIndex];
    final selectedOption = _selectedAnswers[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020B08),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            // Confirm quit
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF0F2A22),
                title: const Text("Quit Practice?", style: TextStyle(color: Colors.white)),
                content: const Text(
                  "Your progress in this section will be lost. Are you sure you want to exit?",
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Color(0xFF00C853))),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Pop question screen
                    },
                    child: const Text("Quit", style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(
          widget.sectionTitle,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar & Counter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question ${_currentIndex + 1} of ${widget.questions.length}",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${((_currentIndex + 1) / widget.questions.length * 100).toInt()}%",
                        style: const TextStyle(
                          color: Color(0xFF00C853),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Question body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question text
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2A22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentQuestion.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                          ),
                          if (currentQuestion.description != null && currentQuestion.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              currentQuestion.description!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "SELECT ONE OPTION",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Options list
                    ...List.generate(currentQuestion.options.length, (index) {
                      final optionText = currentQuestion.options[index];
                      final isSelected = selectedOption == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedAnswers[_currentIndex] = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0x1F00C853) : const Color(0xFF0F2A22),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF00C853) : Colors.white10,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Selection circle
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF00C853) : Colors.white30,
                                      width: isSelected ? 6 : 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    optionText,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Sticky Navigation Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF020B08),
                border: Border(
                  top: BorderSide(color: Colors.white10),
                ),
              ),
              child: Row(
                children: [
                  // Back / Prev Button
                  if (_currentIndex > 0) ...[
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                    const SizedBox(width: 12),
                  ],
                  // Next / Submit Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentIndex < widget.questions.length - 1) {
                          setState(() {
                            _currentIndex++;
                          });
                        } else {
                          _submitAssessment();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: const Color(0xFF020B08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                      ),
                      child: Text(
                        _currentIndex < widget.questions.length - 1 ? "NEXT" : "SUBMIT ANSWERS",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
