import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourseProgressCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String percentText;
  final String progressCount;
  final double progress;
  final Color progressColor;
  final String? tag;
  final Color? tagColor;
  final bool isEnrolled;
  final String courseId;
  final String? thumbnail;

  const CourseProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.percentText,
    required this.progressCount,
    required this.progress,
    required this.progressColor,
    required this.courseId,
    required this.isEnrolled,
    this.tag,
    this.tagColor,
    this.thumbnail,
  });

  @override
  State<CourseProgressCard> createState() => _CourseProgressCardState();
}

class _CourseProgressCardState extends State<CourseProgressCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    _progressController.forward();
  }

  @override
  void didUpdateWidget(covariant CourseProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveProgress = widget.progress > 0;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      onTap: () {
        Feedback.forTap(context);
        if (widget.isEnrolled) {
          // Navigating to course progress/learning screen is handled by the parent
        } else {
          context.push('/course-details/${widget.courseId}');
        }
      },
      child: AnimatedScale(
        scale: _isHovered ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered 
                  ? const Color(0xFF00E676).withValues(alpha: 0.5) 
                  : const Color(0xFF163E33).withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF020B08).withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
              if (_isHovered)
                BoxShadow(
                  color: const Color(0xFF00E676).withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF061411).withValues(alpha: 0.8),
                      const Color(0xFF0B211B).withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Top Section: Thumbnail + Text + New Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Glassmorphic Image Container
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFF122C25).withValues(alpha: 0.5),
                            border: Border.all(
                              color: const Color(0xFF1F5A4A).withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Image.network(
                            (widget.thumbnail != null && widget.thumbnail!.isNotEmpty)
                                ? widget.thumbnail!
                                : _getCourseImageUrl(widget.title),
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Color(0xFF00E676)),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.menu_book_rounded,
                                color: Color(0xFF00E676),
                                size: 24,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Subtitle Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Gilroy-Semibold',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontFamily: 'Gilroy-Semibold',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Animated Glowing New Badge
                        if (widget.tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF00E676).withValues(alpha: 0.2),
                                  const Color(0xFF00B0FF).withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF00E676).withValues(alpha: 0.6),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E676).withValues(alpha: 0.2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              widget.tag!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontFamily: 'Gilroy-Semibold',
                                color: Color(0xFF00E676),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Bottom Section: Thin glowing progress bar OR premium Details action
                    Row(
                      children: [
                        if (hasActiveProgress) ...[
                          // Progress visualizer
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Progress: ${widget.percentText}",
                                      style: const TextStyle(
                                        color: Color(0xFF00E676),
                                        fontFamily: 'Gilroy-Semibold',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      widget.progressCount,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.55),
                                        fontFamily: 'Gilroy-Semibold',
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: AnimatedBuilder(
                                    animation: _progressAnimation,
                                    builder: (context, child) {
                                      return Container(
                                        height: 5,
                                        width: double.infinity,
                                        color: Colors.white12,
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF00E676).withValues(alpha: 0.5),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ] else
                          const Expanded(child: SizedBox()), // Push CTA to the right

                        // Premium Action Button
                        GestureDetector(
                          onTap: () {
                            Feedback.forTap(context);
                            if (widget.isEnrolled) {
                              // resume logic
                            } else {
                              context.push('/course-details/${widget.courseId}');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              gradient: widget.isEnrolled
                                  ? const LinearGradient(
                                      colors: [Color(0xFF00E676), Color(0xFF00C853)],
                                    )
                                  : null,
                              color: widget.isEnrolled
                                  ? null
                                  : const Color(0xFF00E676).withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF00E676).withValues(alpha: 0.8),
                                width: 1.2,
                              ),
                              boxShadow: widget.isEnrolled
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF00E676).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                widget.isEnrolled ? 'Resume →' : 'Details →',
                                style: TextStyle(
                                  color: widget.isEnrolled ? const Color(0xFF020B08) : const Color(0xFF00E676),
                                  fontFamily: 'Gilroy-Semibold',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getCourseImageUrl(String title) {
    final t = title.toLowerCase();
    if (t.contains('rust')) {
      return 'https://img.icons8.com/color/144/rust.png';
    }
    if (t.contains('javascript') || t.contains('js')) {
      return 'https://img.icons8.com/color/144/javascript--v1.png';
    }
    if (t.contains('flutter') || t.contains('dart')) {
      return 'https://img.icons8.com/color/144/flutter.png';
    }
    if (t.contains('python')) {
      return 'https://img.icons8.com/color/144/python--v1.png';
    }
    if (t.contains('sql') || t.contains('database') || t.contains('db')) {
      return 'https://img.icons8.com/fluency/144/database.png';
    }
    if (t.contains('azure') || t.contains('cloud') || t.contains('aws')) {
      return 'https://img.icons8.com/color/144/azure-1.png';
    }
    if (t.contains('dsa') || t.contains('data structure') || t.contains('algorithm') || t.contains('coding')) {
      return 'https://img.icons8.com/fluency/144/code.png';
    }
    if (t.contains('aptitude') || t.contains('math') || t.contains('quant')) {
      return 'https://img.icons8.com/fluency/144/math.png';
    }
    if (t.contains('verbal') || t.contains('english') || t.contains('communication')) {
      return 'https://img.icons8.com/fluency/144/speech-bubble.png';
    }
    if (t.contains('hr') || t.contains('interview') || t.contains('career')) {
      return 'https://img.icons8.com/color/144/briefcase.png';
    }
    return 'https://img.icons8.com/fluency/144/education.png';
  }
}

