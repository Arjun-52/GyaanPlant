import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SessionCard extends StatefulWidget {
  final String initials;
  final String name;
  final String detail;
  final String time;
  final String topic;
  final String? meetingLink;

  const SessionCard({
    super.key,
    required this.initials,
    required this.name,
    required this.detail,
    required this.time,
    required this.topic,
    this.meetingLink,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  bool _isLoading = false;
  bool _isRescheduling = false;

  Future<void> _joinSession() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final rawLink = widget.meetingLink;

      Future<void> _openGoogleMeetOrError() async {
        final meetUri = Uri.parse('https://meet.google.com');
        if (await canLaunchUrl(meetUri)) {
          await launchUrl(meetUri, mode: LaunchMode.externalApplication);
        } else {
          _showError("Unable to open Google Meet. Please contact the administrator.");
        }
      }

      if (rawLink == null || rawLink.trim().isEmpty) {
        await _openGoogleMeetOrError();
        return;
      }

      final uri = Uri.tryParse(rawLink.trim());
      if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        await _openGoogleMeetOrError();
        return;
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await _openGoogleMeetOrError();
      }
    } catch (e) {
      _showError("Unable to open meeting. Please contact the administrator.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _rescheduleSession() async {
    if (_isRescheduling) return;

    setState(() {
      _isRescheduling = true;
    });

    try {
      final rawLink = widget.meetingLink;

      Future<void> _openCalendarOrError() async {
        final calUri = Uri.parse('https://calendar.google.com');
        if (await canLaunchUrl(calUri)) {
          await launchUrl(calUri, mode: LaunchMode.externalApplication);
        } else {
          _showError("Unable to open Calendar. Please contact the administrator.");
        }
      }

      if (rawLink == null || rawLink.trim().isEmpty) {
        await _openCalendarOrError();
        return;
      }

      final uri = Uri.tryParse(rawLink.trim());
      if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        await _openCalendarOrError();
        return;
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await _openCalendarOrError();
      }
    } catch (e) {
      _showError("Unable to open reschedule options. Please contact the administrator.");
    } finally {
      if (mounted) {
        setState(() {
          _isRescheduling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F3D34).withOpacity(0.25),
            const Color(0xFF020B08).withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF00E676).withOpacity(0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.03),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW (avatar + name)
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00E676),
                    width: 1.5,
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0C2D24), Color(0xFF041410)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E676).withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.detail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// TIME + TOPIC
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_filled_rounded,
                  color: Color(0xFF00E676),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.time,
                  style: const TextStyle(
                    color: Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.topic,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /// BUTTONS
          Row(
            children: [
              /// JOIN BUTTON
              Expanded(
                child: MouseRegion(
                  cursor: _isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _joinSession,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E676).withOpacity(0.25),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF031B15),
                                ),
                              )
                            : const Text(
                                "Join Session",
                                style: TextStyle(
                                  color: Color(0xFF031B15),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              /// RESCHEDULE BUTTON
              Expanded(
                child: MouseRegion(
                  cursor: _isRescheduling ? SystemMouseCursors.basic : SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _isRescheduling ? null : _rescheduleSession,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                          width: 1.2,
                        ),
                        color: Colors.white.withOpacity(0.04),
                      ),
                      child: Center(
                        child: _isRescheduling
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Reschedule",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
