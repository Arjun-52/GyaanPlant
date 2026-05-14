import 'package:flutter/material.dart';
import '../../../../services/mentor_booking_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class MentorPaymentScreen extends StatefulWidget {
  final String mentorName;
  final String mentorRole;
  final String mentorAvatar;
  final String mentorPrice;
  final DateTime selectedDate;
  final String selectedTime;
  final String selectedDuration;

  const MentorPaymentScreen({
    super.key,
    required this.mentorName,
    required this.mentorRole,
    required this.mentorAvatar,
    required this.mentorPrice,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedDuration,
  });

  @override
  State<MentorPaymentScreen> createState() => _MentorPaymentScreenState();
}

class _MentorPaymentScreenState extends State<MentorPaymentScreen> {
  // Payment calculation
  late double _sessionFee;
  late double _platformFee;
  late double _gst;
  late double _totalAmount;
  late MentorBookingService _mentorBookingService;

  @override
  void initState() {
    super.initState();
    _mentorBookingService = MentorBookingService();
    _calculatePaymentAmounts();

    // Initialize MentorBookingService with callbacks
    _mentorBookingService.init(
      onSuccess: (response) => _handlePaymentSuccess(response),
      onError: (response) => _handlePaymentError(response),
      onExternal: (response) => _handleExternalWallet(response),
    );
  }

  @override
  void dispose() {
    _mentorBookingService.dispose();
    super.dispose();
  }

  void _calculatePaymentAmounts() {
    // Extract base price from mentorPrice (e.g., "₹500/hr" -> 500.0)
    final String priceString = widget.mentorPrice.replaceAll(
      RegExp(r'[^\d.]'),
      '',
    );
    final double basePrice = double.tryParse(priceString) ?? 0.0;

    // Calculate based on duration
    if (widget.selectedDuration.contains('30')) {
      _sessionFee = basePrice * 0.5; // 30 mins = 0.5 hour
    } else if (widget.selectedDuration.contains('60')) {
      _sessionFee = basePrice; // 60 mins = 1 hour
    } else if (widget.selectedDuration.contains('90')) {
      _sessionFee = basePrice * 1.5; // 90 mins = 1.5 hours
    } else {
      _sessionFee = basePrice; // Default to 1 hour
    }

    _platformFee = _sessionFee * 0.05; // 5% platform fee
    _gst = (_sessionFee + _platformFee) * 0.18; // 18% GST
    _totalAmount = _sessionFee + _platformFee + _gst;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020B08),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mentor Information Card
            _buildMentorInfoCard(),

            const SizedBox(height: 20),

            // Booking Details Card
            _buildBookingDetailsCard(),

            const SizedBox(height: 20),

            // Payment Breakdown Card
            _buildPaymentBreakdownCard(),

            const SizedBox(height: 20),

            // Payment Method Card
            _buildPaymentMethodCard(),

            const SizedBox(height: 100), // Space for fixed bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF020B08),
          border: Border(top: BorderSide(color: Color(0xFF12352C), width: 1)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _proceedToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Proceed to Pay',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMentorInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1F19), Color(0xFF0D2F24)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF12352C)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF12352C)),
            ),
            child: Center(
              child: Text(
                widget.mentorAvatar,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Mentor Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mentorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.mentorRole,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.mentorPrice,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1F19), Color(0xFF0D2F24)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF12352C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Date
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: _formatDate(widget.selectedDate),
          ),

          const SizedBox(height: 12),

          // Time
          _buildDetailRow(
            icon: Icons.access_time_outlined,
            label: 'Time',
            value: widget.selectedTime,
          ),

          const SizedBox(height: 12),

          // Duration
          _buildDetailRow(
            icon: Icons.timer_outlined,
            label: 'Duration',
            value: widget.selectedDuration,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1F19), Color(0xFF0D2F24)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF12352C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Session Fee
          _buildPaymentRow(
            label: 'Session Fee',
            value: '₹${_sessionFee.toStringAsFixed(2)}',
            isHighlighted: false,
          ),

          const SizedBox(height: 8),

          // Platform Fee
          _buildPaymentRow(
            label: 'Platform Fee',
            value: '₹${_platformFee.toStringAsFixed(2)}',
            isHighlighted: false,
          ),

          const SizedBox(height: 8),

          // GST
          _buildPaymentRow(
            label: 'GST (18%)',
            value: '₹${_gst.toStringAsFixed(2)}',
            isHighlighted: false,
          ),

          const SizedBox(height: 16),

          // Divider
          Container(height: 1, color: Colors.white.withOpacity(0.1)),

          const SizedBox(height: 16),

          // Total Amount
          _buildPaymentRow(
            label: 'Total Amount',
            value: '₹${_totalAmount.toStringAsFixed(2)}',
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1F19), Color(0xFF0D2F24)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF12352C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Razorpay Option
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF00C853).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00C853)),
            ),
            child: Row(
              children: [
                // Razorpay Icon (placeholder)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: Colors.black,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Razorpay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Secure payment gateway',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Selected indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.black, size: 14),
                ),
              ],
            ),
          ),

          // Future payment methods placeholder
          const SizedBox(height: 12),
          Text(
            'More payment methods coming soon',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00C853), size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow({
    required String label,
    required String value,
    required bool isHighlighted,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isHighlighted ? Colors.white : Colors.white70,
            fontSize: isHighlighted ? 16 : 14,
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlighted ? const Color(0xFF00C853) : Colors.white,
            fontSize: isHighlighted ? 16 : 14,
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _proceedToPayment() {
    print(
      '💳 Proceeding to mentor booking payment with amount: ₹${_totalAmount.toStringAsFixed(2)}',
    );

    // Prepare booking data
    final bookingData = {
      'mentorName': widget.mentorName,
      'mentorRole': widget.mentorRole,
      'date': widget.selectedDate,
      'time': widget.selectedTime,
      'duration': widget.selectedDuration,
      'sessionFee': _sessionFee,
      'platformFee': _platformFee,
      'gst': _gst,
      'totalAmount': _totalAmount,
    };

    print('📋 Mentor Booking Data: $bookingData');

    // Open Razorpay checkout using MentorBookingService
    try {
      // Use MentorBookingService for mentor session booking
      // TODO: This mentor-booking flow is mocked end-to-end (fake mentorId,
      // fake orderId, mocked verification). When wired to the real backend,
      // call `PaymentRepository.createOrder(itemType: ItemType.session, ...)`
      // and use the returned `PaidOrder.keyId / orderId / amount` here, the
      // same way the course flow does. Until then the key is read from the
      // build env so no secret is committed to source.
      _mentorBookingService.purchaseMentorSession(
        context: context,
        mentorId:
            'mentor_${widget.mentorName.toLowerCase().replaceAll(' ', '_')}',
        mentorName: widget.mentorName,
        selectedDate: widget.selectedDate,
        selectedTime: widget.selectedTime,
        selectedDuration: widget.selectedDuration,
        totalAmount: _totalAmount,
        keyId: const String.fromEnvironment('RAZORPAY_KEY'),
        bookingDetails: {
          'sessionFee': _sessionFee,
          'platformFee': _platformFee,
          'gst': _gst,
          'mentorRole': widget.mentorRole,
          'mentorAvatar': widget.mentorAvatar,
        },
      );
    } catch (e) {
      print('❌ Error opening mentor booking payment: $e');
      _showErrorDialog('Failed to complete mentor booking: $e');
    }
  }

  void _handlePaymentSuccess(dynamic response) {
    print('✅ Mentor Booking Payment Success: ${response.paymentId}');
    print('📋 Mentor Booking Details: $response');

    // Show success dialog
    _showSuccessDialog(
      'Mentor session booked successfully! Your booking is confirmed.',
    );

    // TODO: Navigate to booking confirmation screen
    // TODO: Save booking data to backend
  }

  void _handlePaymentError(dynamic response) {
    print(
      '❌ Mentor Booking Payment Error: ${response.code} - ${response.message}',
    );

    // Get user-friendly error message
    final errorMessage = _getMentorBookingErrorMessage(
      response.code?.toString(),
    );
    _showErrorDialog(errorMessage);
  }

  void _handleExternalWallet(dynamic response) {
    print('👛 External Wallet: ${response.walletName}');
    _showInfoDialog(
      'Opening ${response.walletName} for mentor booking payment...',
    );
  }

  String _getMentorBookingErrorMessage(String? errorCode) {
    switch (errorCode) {
      case 'BAD_REQUEST_ERROR':
        return 'Invalid mentor booking request. Please try again.';
      case 'NETWORK_ERROR':
        return 'Network error. Please check your connection and try again.';
      case 'INTERNAL_SERVER_ERROR':
        return 'Server error. Please try again in a few minutes.';
      case 'INVALID_SIGNATURE':
        return 'Mentor booking payment verification failed. Please contact support.';
      case 'PAYMENT_CANCELLED':
        return 'Mentor booking payment was cancelled. Please try again.';
      case 'PAYMENT_FAILED':
        return 'Mentor booking payment failed. Please try a different payment method.';
      case 'INVALID_ORDER':
        return 'Invalid mentor booking order. Please try again.';
      default:
        return 'Mentor booking failed. Please try again.';
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF020B08),
        title: const Text(
          'Payment Successful',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to booking confirmation
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF00C853))),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF020B08),
        title: const Text(
          'Payment Error',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Retry',
              style: TextStyle(color: Color(0xFF00C853)),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF020B08),
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFF00C853))),
          ),
        ],
      ),
    );
  }
}
