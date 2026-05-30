import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/mentor_payment_screen.dart';

class MentorBookingSheet extends StatefulWidget {
  final String mentorId;
  final String mentorName;
  final String mentorRole;
  final String mentorAvatar;
  final String mentorPrice;

  const MentorBookingSheet({
    super.key,
    required this.mentorId,
    required this.mentorName,
    required this.mentorRole,
    required this.mentorAvatar,
    required this.mentorPrice,
  });

  @override
  State<MentorBookingSheet> createState() => _MentorBookingSheetState();
}

class _MentorBookingSheetState extends State<MentorBookingSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  // Form controllers
  final _topicController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedDuration = '30 mins'; // Default duration

  final List<String> _durationOptions = const ['30 mins', '60 mins', '90 mins'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _topicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _isValid() {
    return _topicController.text.isNotEmpty &&
        _notesController.text.isNotEmpty &&
        _selectedDate != null &&
        _selectedTime != null &&
        _selectedDuration != null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E676),
              onPrimary: Color(0xFF020B08),
              surface: Color(0xFF0A1410),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E676),
              onPrimary: Color(0xFF020B08),
              surface: Color(0xFF0A1410),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _onSendRequest() {
    if (!_isValid()) return;

    final formattedTime = _selectedTime!.format(context);

    // Close modal popup
    Navigator.pop(context);

    // Navigate to payment screen preserving identical booking flow
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MentorPaymentScreen(
          mentorId: widget.mentorId,
          mentorName: widget.mentorName,
          mentorRole: widget.mentorRole,
          mentorAvatar: widget.mentorAvatar,
          mentorPrice: widget.mentorPrice,
          selectedDate: _selectedDate!,
          selectedTime: formattedTime,
          selectedDuration: _selectedDuration!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: EdgeInsets.only(bottom: keyboardPadding),
            decoration: BoxDecoration(
              color: const Color(0xFF020B08).withOpacity(0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFF00E676).withOpacity(0.18),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withOpacity(0.06),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Top row: Title & Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "BOOK WITH ${widget.mentorName.toUpperCase()}",
                                style: const TextStyle(
                                  color: Color(0xFF00E676),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.mentorRole,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white60,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Session Topic Input
                    const Text(
                      "Session Topic",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _topicController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration("Enter session topic", Icons.subject_rounded),
                    ),

                    const SizedBox(height: 16),

                    /// Notes Input
                    const Text(
                      "Notes / Discussion Points",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration("Enter notes or points", Icons.note_alt_rounded),
                    ),

                    const SizedBox(height: 16),

                    /// Date & Time Selectors
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Date",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: _selectBoxDecoration(_selectedDate != null),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        color: _selectedDate != null ? const Color(0xFF00E676) : Colors.white24,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _selectedDate != null
                                              ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                              : "Select Date",
                                          style: TextStyle(
                                            color: _selectedDate != null ? Colors.white : Colors.white24,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Time",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _selectTime(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: _selectBoxDecoration(_selectedTime != null),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        color: _selectedTime != null ? const Color(0xFF00E676) : Colors.white24,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _selectedTime != null ? _selectedTime!.format(context) : "Select Time",
                                          style: TextStyle(
                                            color: _selectedTime != null ? Colors.white : Colors.white24,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// Duration Chips Selection
                    const Text(
                      "Session Duration",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: _durationOptions.map((duration) {
                        final isSelected = _selectedDuration == duration;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDuration = duration;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00E676).withOpacity(0.15)
                                    : const Color(0xFF121212).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00E676)
                                      : const Color(0xFF00E676).withOpacity(0.15),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                duration,
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF00E676) : Colors.white54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    /// Fee Information Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C241B).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00E676).withOpacity(0.12),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Consultation Fee",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                widget.mentorPrice,
                                style: const TextStyle(
                                  color: Color(0xFF00E676),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Colors.white10, height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Duration Limit",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _selectedDuration ?? "30 mins",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Bottom Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Colors.white12, width: 1.2),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.white60,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MouseRegion(
                            cursor: _isValid() ? SystemMouseCursors.click : SystemMouseCursors.basic,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: _isValid()
                                    ? const LinearGradient(
                                        colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: _isValid() ? null : const Color(0xFF1A2E26),
                                boxShadow: [
                                  if (_isValid())
                                    BoxShadow(
                                      color: const Color(0xFF00E676).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _isValid() ? _onSendRequest : null,
                                child: Text(
                                  "Send Request",
                                  style: TextStyle(
                                    color: _isValid() ? const Color(0xFF031B15) : Colors.white24,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13, fontWeight: FontWeight.bold),
      prefixIcon: Icon(icon, color: Colors.white24, size: 16),
      filled: true,
      fillColor: const Color(0xFF101C17).withOpacity(0.6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: const Color(0xFF00E676).withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: const Color(0xFF00E676).withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5),
      ),
    );
  }

  BoxDecoration _selectBoxDecoration(bool hasValue) {
    return BoxDecoration(
      color: const Color(0xFF101C17).withOpacity(0.6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: hasValue ? const Color(0xFF00E676) : const Color(0xFF00E676).withOpacity(0.12),
        width: hasValue ? 1.5 : 1,
      ),
    );
  }
}

