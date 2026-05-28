import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/data/services/api_service.dart';
import '../../../../models/assessment/mock_test_models.dart';

class QuestionScreen extends StatefulWidget {
  final String sectionTitle;
  final List<PrepPackQuestionModel> questions;
  final MarkingSchemeModel markingScheme;
  final String? packId;

  const QuestionScreen({
    super.key,
    required this.sectionTitle,
    required this.questions,
    required this.markingScheme,
    this.packId,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  static const _tag = 'QuestionScreen';

  int _currentIndex = 0;
  final Map<int, int?> _selectedAnswers = {};

  /// Guard against double-submit
  bool _isSubmitting = false;

  /// Blocks retry button after 24-hour restriction response
  bool _retryBlocked = false;

  @override
  void initState() {
    super.initState();
    // Initialize all to null (unattempted)
    for (int i = 0; i < widget.questions.length; i++) {
      _selectedAnswers[i] = null;
    }
  }

  void _submitAssessment() {
    if (_isSubmitting) {
      AppLogger.warning(_tag, 'Submit already in progress — ignoring');
      return;
    }

    _isSubmitting = true;
    AppLogger.info(_tag, 'Assessment submitted for: ${widget.sectionTitle}');

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

    AppLogger.info(
      _tag,
      'Results: score=$score correct=$correctCount wrong=$wrongCount '
      'unattempted=$unattemptedCount accuracy=$accuracy%',
    );

    // Reset submitting flag — dialog is local, no API call for now
    _isSubmitting = false;

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
          child: _ResultsDialog(
            sectionTitle: widget.sectionTitle,
            score: score,
            correctCount: correctCount,
            wrongCount: wrongCount,
            accuracy: accuracy,
            unattemptedCount: unattemptedCount,
            retryBlocked: _retryBlocked,
            onRetry: () => _handleRetry(context),
            onFinish: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to Details screen
            },
          ),
        );
      },
    );
  }

  /// Handle retry button press — checks backend for retry restriction.
  Future<void> _handleRetry(BuildContext dialogContext) async {
    if (_retryBlocked) {
      _showRetryBlockedSnackBar();
      return;
    }

    // If we have a packId, check with the backend first
    if (widget.packId != null && widget.packId!.isNotEmpty) {
      AppLogger.info(_tag, 'Checking retry eligibility for pack ${widget.packId}');

      try {
        final api = ApiService().learning;
        final result = await api.startAttempt(widget.packId!);

        if (!mounted) return;

        if (result.isFailure) {
          final errorMessage = result.error?.message ?? '';
          AppLogger.error(_tag, 'Retry check failed: $errorMessage');

          // Check for retry restriction
          if (errorMessage.toLowerCase().contains('retry after')) {
            setState(() => _retryBlocked = true);
            Navigator.pop(dialogContext); // Close dialog
            _showRetryBlockedSnackBar();
            return;
          }

          // Network error
          final errorStr = errorMessage.toLowerCase();
          if (errorStr.contains('network') ||
              errorStr.contains('connection') ||
              errorStr.contains('internet')) {
            Navigator.pop(dialogContext);
            _showErrorSnackBar('Unable to connect. Please check internet.');
            return;
          }

          // Other backend error — show the backend message
          Navigator.pop(dialogContext);
          _showErrorSnackBar(
            errorMessage.isNotEmpty
                ? errorMessage
                : 'Something went wrong. Please try again.',
          );
          return;
        }

        AppLogger.info(_tag, 'Retry allowed — resetting quiz');
      } catch (e) {
        AppLogger.error(_tag, 'Retry check exception', e);
        if (!mounted) return;

        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('socket') ||
            errorStr.contains('network') ||
            errorStr.contains('connection')) {
          Navigator.pop(dialogContext);
          _showErrorSnackBar('Unable to connect. Please check internet.');
          return;
        }

        Navigator.pop(dialogContext);
        _showErrorSnackBar('Something went wrong. Please try again.');
        return;
      }
    }

    // Retry allowed — close dialog and reset quiz
    Navigator.pop(dialogContext);
    setState(() {
      _currentIndex = 0;
      for (int i = 0; i < widget.questions.length; i++) {
        _selectedAnswers[i] = null;
      }
    });
  }

  void _showRetryBlockedSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.timer_outlined, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text('You can retry this assessment after 24 hours.'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF57C00),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
                      onPressed: _isSubmitting
                          ? null
                          : () {
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
                        disabledBackgroundColor: const Color(0xFF00C853).withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Color(0xFF020B08)),
                              ),
                            )
                          : Text(
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

/// Extracted results dialog widget for clean separation.
class _ResultsDialog extends StatelessWidget {
  final String sectionTitle;
  final double score;
  final int correctCount;
  final int wrongCount;
  final int accuracy;
  final int unattemptedCount;
  final bool retryBlocked;
  final VoidCallback onRetry;
  final VoidCallback onFinish;

  const _ResultsDialog({
    required this.sectionTitle,
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.accuracy,
    required this.unattemptedCount,
    required this.retryBlocked,
    required this.onRetry,
    required this.onFinish,
  });

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
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
              sectionTitle,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
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
            // Retry blocked message
            if (retryBlocked) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF57C00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF57C00).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.timer_outlined, color: Color(0xFFF57C00), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can retry this assessment after 24 hours.',
                        style: TextStyle(color: Color(0xFFF57C00), fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      actions: [
        OutlinedButton(
          onPressed: retryBlocked ? null : onRetry,
          style: OutlinedButton.styleFrom(
            foregroundColor: retryBlocked ? Colors.white30 : Colors.white70,
            side: BorderSide(
              color: retryBlocked ? Colors.white12 : Colors.white24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text("Retry Pack"),
        ),
        ElevatedButton(
          onPressed: onFinish,
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
    );
  }
}
