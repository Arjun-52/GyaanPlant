import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:gyaanplant/models/learning/player_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HTTP HEADERS
// ExoPlayer's default User-Agent ("ExoPlayerLib/…") is blocked with 403 by
// several CDNs (Google Storage, CloudFront, etc.).  Sending a real browser UA
// is the standard fix.
// ─────────────────────────────────────────────────────────────────────────────
const Map<String, String> _kVideoHeaders = {
  'User-Agent':
      'Mozilla/5.0 (Linux; Android 13; Pixel 7) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/124.0.0.0 Mobile Safari/537.36',
  'Accept': '*/*',
  'Accept-Language': 'en-US,en;q=0.9',
  'Connection': 'keep-alive',
  // Add auth header here when your backend requires it:
  // 'Authorization': 'Bearer $token',
};

// ─────────────────────────────────────────────────────────────────────────────
// FALLBACK CHAIN
// Tried in order when the lesson URL is invalid / still fails after 403.
// Each URL is from a different CDN so at least one will succeed.
// ─────────────────────────────────────────────────────────────────────────────
const List<String> _kFallbackUrls = [
  // Flutter official assets (GitHub Pages — very reliable)
  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  // Cloudinary demo
  'https://res.cloudinary.com/demo/video/upload/dog.mp4',
  // W3Schools sample (small, fast)
  'https://www.w3schools.com/html/mov_bbb.mp4',
];

// ─────────────────────────────────────────────────────────────────────────────

/// Returns true when [url] is a plausible http(s) network URL.
bool _isValidNetworkUrl(String url) {
  if (url.isEmpty) return false;
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) return false;
  return uri.scheme == 'http' || uri.scheme == 'https';
}

// ─────────────────────────────────────────────────────────────────────────────

/// Styled Video Player Widget powered by the official video_player package.
class VideoPlayerSection extends StatefulWidget {
  final PlayerLesson lesson;
  final VoidCallback onPlayTapped;

  const VideoPlayerSection({
    super.key,
    required this.lesson,
    required this.onPlayTapped,
  });

  @override
  State<VideoPlayerSection> createState() => _VideoPlayerSectionState();
}

class _VideoPlayerSectionState extends State<VideoPlayerSection> {
  VideoPlayerController? _controller;

  // Loading / error state
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  // Controls overlay
  bool _showControls = true;
  Timer? _controlsTimer;

  // Debounce timer for transient ExoPlayer errors that resolve on their own.
  Timer? _errorDebounceTimer;

  // Race-condition guard – tracks which URL *this* init cycle was requested
  // for; a slow previous init will abort if a newer one started.
  String? _initializingUrl;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lesson.videoUrl != widget.lesson.videoUrl ||
        oldWidget.lesson.id != widget.lesson.id) {
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _errorDebounceTimer?.cancel();
    _disposeController();
    super.dispose();
  }

  // ── Controller helpers ────────────────────────────────────────────────────

  Future<void> _disposeController() async {
    final old = _controller;
    _controller = null;
    if (old != null) {
      old.removeListener(_videoListener);
      await old.dispose();
    }
  }

  // ── Core initialization (with sequential fallback) ────────────────────────

  Future<void> _initializePlayer() async {
    // Build the priority-ordered list of URLs to try:
    //   [0] Lesson URL from backend  (if valid)
    //   [1..N] Fallbacks in order
    final rawUrl = widget.lesson.videoUrl.trim();
    final List<String> urlsToTry = [
      if (_isValidNetworkUrl(rawUrl)) rawUrl,
      ..._kFallbackUrls,
    ];

    // ── Debug dump ───────────────────────────────────────────────────────────
    debugPrint('══════════════════════════════════════════════════════');
    debugPrint('[VideoPlayer] Lesson   : ${widget.lesson.id} — ${widget.lesson.title}');
    debugPrint('[VideoPlayer] Raw URL  : $rawUrl  (${rawUrl.runtimeType})');
    debugPrint('[VideoPlayer] Is valid : ${_isValidNetworkUrl(rawUrl)}');
    debugPrint('[VideoPlayer] Queue    : $urlsToTry');
    debugPrint('══════════════════════════════════════════════════════');

    // Race-condition token
    final token = rawUrl.isEmpty ? 'empty_${DateTime.now().millisecondsSinceEpoch}' : rawUrl;
    _initializingUrl = token;

    // Cancel any pending error debounce from a previous initialization cycle.
    _errorDebounceTimer?.cancel();

    // Reset to loading state; tear down old controller.
    if (mounted) {
      setState(() {
        _isLoading = true;
        _isError = false;
        _errorMessage = '';
      });
    }
    await _disposeController();

    // ── Try each URL in sequence ─────────────────────────────────────────────
    for (final url in urlsToTry) {
      if (_initializingUrl != token || !mounted) return; // aborted

      debugPrint('[VideoPlayer] Trying   : $url');

      final Uri? uri = Uri.tryParse(url);
      if (uri == null) {
        debugPrint('[VideoPlayer] Skip     : malformed URI');
        continue;
      }

      bool success = false;
      try {
        final controller = VideoPlayerController.networkUrl(
          uri,
          httpHeaders: _kVideoHeaders,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );

        if (_initializingUrl != token || !mounted) {
          await controller.dispose();
          return;
        }

        _controller = controller;
        controller.addListener(_videoListener);

        await controller.initialize();

        if (_initializingUrl != token || !mounted) {
          await _disposeController();
          return;
        }

        // ── Initialized successfully ─────────────────────────────────────
        debugPrint('[VideoPlayer] ✓ OK     : $url');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isError = false;
          });
          controller.play();
          _startControlsTimer();
        }
        success = true;
      } catch (e) {
        debugPrint('[VideoPlayer] ✗ FAIL   : $url');
        debugPrint('[VideoPlayer] Error    : $e');
        await _disposeController();
      }

      if (success) return; // done — no need to try next fallback
    }

    // All URLs exhausted
    debugPrint('[VideoPlayer] ✗ All URLs failed — showing error UI');
    _setError('All video sources failed. '
        'Check your internet connection or try again later.');
  }

  void _setError(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = message;
      });
    }
  }

  // ── Listener ─────────────────────────────────────────────────────────────

  void _videoListener() {
    if (!mounted) return;
    final value = _controller?.value;
    if (value == null) return;

    // If the video is actually playing, clear any pending/showing error –
    // this means a transient ExoPlayer error resolved on its own.
    if (value.isPlaying && !value.hasError) {
      _errorDebounceTimer?.cancel();
      if (_isError) {
        setState(() {
          _isError = false;
          _isLoading = false;
          _errorMessage = '';
        });
      }
    }

    // Catch ExoPlayer errors surfaced through the value notifier.
    // Use a debounce to avoid flashing the error UI for transient errors
    // that resolve on their own within ~1.5 seconds.
    if (value.hasError && !_isError) {
      debugPrint('[VideoPlayer] Listener error (debouncing): ${value.errorDescription}');
      _errorDebounceTimer?.cancel();
      _errorDebounceTimer = Timer(const Duration(milliseconds: 1500), () {
        // Re-check: only show error if the controller still has an error
        // and the video is not playing.
        if (!mounted) return;
        final currentValue = _controller?.value;
        if (currentValue != null &&
            currentValue.hasError &&
            !currentValue.isPlaying) {
          debugPrint('[VideoPlayer] Listener error confirmed: ${currentValue.errorDescription}');
          _setError(currentValue.errorDescription ?? 'Playback error');
        }
      });
      return;
    }

    setState(() {});
  }

  // ── Controls helpers ──────────────────────────────────────────────────────

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startControlsTimer();
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _controlsTimer?.cancel();
      } else {
        _controller!.play();
        _startControlsTimer();
      }
    });
    widget.onPlayTapped();
  }

  String _formatDuration(Duration d) {
    String pad(int n) => n.toString().padLeft(2, '0');
    final mm = pad(d.inMinutes.remainder(60));
    final ss = pad(d.inSeconds.remainder(60));
    return d.inHours > 0 ? '${pad(d.inHours)}:$mm:$ss' : '$mm:$ss';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isInitialized =
        _controller != null && _controller!.value.isInitialized;

    final Widget content;
    if (_isError) {
      content = _buildErrorWidget();
    } else if (_isLoading || !isInitialized) {
      content = _buildLoadingWidget();
    } else {
      content = _buildPlayerWidget();
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF030D0A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FFA3).withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }

  // ── Content widgets ───────────────────────────────────────────────────────

  Widget _buildPlayerWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),

        // Tap-to-toggle controls layer
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleControls,
            child: const SizedBox.expand(),
          ),
        ),

        // Controls overlay
        AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: !_showControls,
            child: Stack(
              children: [
                // Frosted premium gradient backplate
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Centre play/pause
                Center(
                  child: AnimatedScale(
                    scale: _showControls ? 1.0 : 0.8,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF030D0A).withValues(alpha: 0.75),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00FFA3).withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        iconSize: 52,
                        icon: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: const Color(0xFF00FFA3),
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    ),
                  ),
                ),

                // Top: title + duration badge
                Positioned(
                  top: 14,
                  left: 18,
                  right: 18,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.lesson.title,
                          style: const TextStyle(
                            fontFamily: 'Gilroy-Bold',
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FFA3).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF00FFA3).withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${widget.lesson.durationMins}m',
                          style: const TextStyle(
                            fontFamily: 'Gilroy-Bold',
                            color: Color(0xFF00FFA3),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom: progress + time + mini controls
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: VideoProgressIndicator(
                            _controller!,
                            allowScrubbing: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            colors: VideoProgressColors(
                              playedColor: const Color(0xFF00FFA3),
                              bufferedColor:
                                  Colors.white.withValues(alpha: 0.3),
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  _controller!.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onPressed: _togglePlayPause,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                '${_formatDuration(_controller!.value.position)} / '
                                '${_formatDuration(_controller!.value.duration)}',
                                style: const TextStyle(
                                  fontFamily: 'Gilroy-Medium',
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                _controller!.value.volume > 0
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 14),
                              const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 22,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF0C241B), Color(0xFF030705)],
          radius: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FFA3)),
              strokeWidth: 3.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading ${widget.lesson.title}…',
            style: const TextStyle(
              fontFamily: 'Gilroy-Medium',
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: const Color(0xFF030705),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.broken_image_outlined,
                size: 38,
                color: Colors.redAccent.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Unable to load video',
              style: TextStyle(
                fontFamily: 'Gilroy-Bold',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'All video sources failed.\n'
              'Check your internet connection or try again.',
              style: TextStyle(
                fontFamily: 'Gilroy-Medium',
                color: Colors.white38,
                fontSize: 11.5,
                height: 1.55,
              ),
              textAlign: TextAlign.center,
            ),

            // Collapsed error detail
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.white24,
                    fontSize: 10,
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Retry button
            ElevatedButton.icon(
              onPressed: _initializePlayer,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFA3),
                foregroundColor: const Color(0xFF030705),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
