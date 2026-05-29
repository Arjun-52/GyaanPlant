import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/helpers.dart';

class SyllabusCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final int progress;

  const SyllabusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  @override
  State<SyllabusCard> createState() => _SyllabusCardState();
}

class _SyllabusCardState extends State<SyllabusCard> {
  bool _isMapping = false;
  bool _isMapped = false;
  late int _currentProgress;
  late String _currentSubtitle;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.progress;
    _currentSubtitle = widget.subtitle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0C221B), Color(0xFF05100C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          ///  ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.greenAccent.withOpacity(0.15),
              ),
            ),
            child: const Text(
              "📐",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _currentSubtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),

                const SizedBox(height: 8),

                ///PROGRESS BAR
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _currentProgress / 10,
                    minHeight: 5,
                    color: const Color(0xFF00E676),
                    backgroundColor: Colors.white.withOpacity(0.08),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          GestureDetector(
            onTap: _isMapping
                ? null
                : () async {
                    if (_isMapped) {
                      Helpers.showInfoSnackBar(
                        context,
                        '${widget.title.split(' ')[0]} courses are already mapped!',
                      );
                      return;
                    }

                    setState(() {
                      _isMapping = true;
                    });

                    // Premium simulated mapping delay
                    await Future.delayed(const Duration(milliseconds: 1200));

                    if (!context.mounted) return;

                    setState(() {
                      _isMapping = false;
                      _isMapped = true;
                      // Increment progress
                      if (_currentProgress < 10) {
                        _currentProgress++;
                        // Dynamically update subtitle string
                        final parts = _currentSubtitle.split(' ');
                        if (parts.isNotEmpty && parts[0].contains('/')) {
                          final slashes = parts[0].split('/');
                          final total = slashes.length > 1 ? slashes[1] : '10';
                          _currentSubtitle =
                              '$_currentProgress/$total courses mapped to electives';
                        } else {
                          _currentSubtitle =
                              '$_currentProgress/10 courses mapped to electives';
                        }
                      }
                    });

                    Helpers.showSuccessSnackBar(
                      context,
                      'Successfully mapped GyaanPlant courses for ${widget.title.split(' ')[0]}!',
                    );
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isMapped
                      ? const Color(0xFF00C853).withOpacity(0.5)
                      : _isMapping
                          ? Colors.blueAccent.withOpacity(0.3)
                          : const Color(0xFF00E676).withOpacity(0.4),
                ),
                color: _isMapped
                    ? const Color(0xFF00C853).withOpacity(0.12)
                    : _isMapping
                        ? Colors.blueAccent.withOpacity(0.05)
                        : const Color(0xFF00E676).withOpacity(0.12),
              ),
              child: _isMapping
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blueAccent,
                        ),
                      ),
                    )
                  : Text(
                      _isMapped ? "Mapped ✓" : "Map",
                      style: TextStyle(
                        color: _isMapped ? const Color(0xFF00E676) : const Color(0xFF00E676),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
