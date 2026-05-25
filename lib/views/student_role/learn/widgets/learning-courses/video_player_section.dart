import 'package:flutter/material.dart';
import 'package:gyaanplant/models/learning/player_models.dart';

/// Styled Video Player Mock Widget containing the video_player package structure.
class VideoPlayerSection extends StatelessWidget {
  final PlayerLesson lesson;
  final VoidCallback onPlayTapped;

  const VideoPlayerSection({
    super.key,
    required this.lesson,
    required this.onPlayTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Use the lesson's video URL if available, otherwise fall back to a standard public Google API test video
    final String videoUrl = lesson.videoUrl.isNotEmpty
        ? lesson.videoUrl
        : "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
    final bool hasVideo = videoUrl.isNotEmpty;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1F1A), // Dark emerald container background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00C853).withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C853).withValues(alpha: 0.05),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Preview Background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xFF103A2B), Color(0xFF051711)],
                    radius: 1.2,
                  ),
                ),
              ),
            ),

            // Video Controller Overlay Mock
            if (hasVideo)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 64,
                    icon: const Icon(
                      Icons.play_circle_fill,
                      color: Color(0xFF00E676),
                    ),
                    onPressed: onPlayTapped,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Press Play to watch (${lesson.durationMins}m)",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            else
              // No Video Placeholder state
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_off_outlined,
                      size: 44,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "No video available",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Upload a video URL in course editor",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Mock Progress Bar representing video_player timeline controller
            if (hasVideo)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Row(
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: const LinearProgressIndicator(
                          value: 0.0,
                          minHeight: 4,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation(Color(0xFF00E676)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "0:00 / 12:00",
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.fullscreen, color: Colors.white, size: 18),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
