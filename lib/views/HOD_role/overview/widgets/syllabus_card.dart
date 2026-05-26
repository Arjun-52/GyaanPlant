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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0F3D34),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          ///  ICON
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "📐",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _currentSubtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),

                const SizedBox(height: 8),

                ///PROGRESS BAR
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _currentProgress / 10,
                    minHeight: 6,
                    color: const Color(0xFF00C853),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: _isMapped
                      ? Colors.green.withValues(alpha: 0.6)
                      : _isMapping
                          ? Colors.blueAccent.withValues(alpha: 0.3)
                          : Colors.blueAccent.withValues(alpha: 0.6),
                ),
                color: _isMapped
                    ? Colors.green.withValues(alpha: 0.1)
                    : _isMapping
                        ? Colors.blueAccent.withValues(alpha: 0.05)
                        : Colors.blueAccent.withValues(alpha: 0.1),
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
                        color: _isMapped ? Colors.green : Colors.blueAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
