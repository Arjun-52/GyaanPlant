import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../services/mentor_booking_service.dart';

class MentorPaymentScreen extends StatefulWidget {
  final String mentorId;
  final String mentorName;
  final String mentorRole;
  final String mentorAvatar;
  final String mentorPrice;
  final DateTime selectedDate;
  final String selectedTime;
  final String selectedDuration;

  const MentorPaymentScreen({
    super.key,
    required this.mentorId,
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
      backgroundColor: const Color(0xFF030705), // Deep black background
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF00FFA3).withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: ClipRRect(
            child: AppBar(
              backgroundColor: const Color(0xFF030705).withValues(alpha: 0.85),
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C241B).withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              title: const Text(
                'Checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background ambient lights
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.04),
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F3B2E).withValues(alpha: 0.06),
                    blurRadius: 180,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),

          // Main body Scrollable
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Mentor Information Card
                  _StaggeredItem(
                    index: 0,
                    child: _buildMentorInfoCard(),
                  ),

                  const SizedBox(height: 20),

                  // 2. Booking Details Card
                  _StaggeredItem(
                    index: 1,
                    child: _buildBookingDetailsCard(),
                  ),

                  const SizedBox(height: 20),

                  // 3. Payment Breakdown Card
                  _StaggeredItem(
                    index: 2,
                    child: _buildPaymentBreakdownCard(),
                  ),

                  const SizedBox(height: 20),

                  // 4. Payment Method Card
                  _StaggeredItem(
                    index: 3,
                    child: _buildPaymentMethodCard(),
                  ),

                  const SizedBox(height: 20),

                  // 5. Trust & Security Section (New)
                  _StaggeredItem(
                    index: 4,
                    child: const _SecurePaymentCard(),
                  ),

                  const SizedBox(height: 90), // Space for floating bottom CTA
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF030705).withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF00FFA3).withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.of(context).padding.bottom + 14,
        ),
        child: SizedBox(
          width: double.infinity,
          child: _ProceedToPayButton(
            onPressed: _proceedToPayment,
          ),
        ),
      ),
    );
  }

  Widget _buildMentorInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0C241B).withValues(alpha: 0.45),
            const Color(0xFF030D0A).withValues(alpha: 0.9),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Glowing Avatar Container
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF00FFA3).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF00FFA3).withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.mentorAvatar,
                style: const TextStyle(
                  color: Color(0xFF00FFA3),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),

          const SizedBox(width: 18),

          // Mentor Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.mentorName,
                        style: const TextStyle(
                          fontFamily: 'Gilroy-Bold',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Verified Badge Row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FFA3).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00FFA3).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Color(0xFF00FFA3), size: 10),
                          SizedBox(width: 4),
                          Text(
                            "Verified",
                            style: TextStyle(
                              color: Color(0xFF00FFA3),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  widget.mentorRole,
                  style: TextStyle(
                    fontFamily: 'Gilroy-Medium',
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.mentorPrice,
                  style: const TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    color: Color(0xFF00FFA3),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0C241B).withValues(alpha: 0.35),
            const Color(0xFF030D0A).withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.02),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.stars, color: Color(0xFF00FFA3), size: 16),
              SizedBox(width: 8),
              Text(
                'BOOKING DETAILS',
                style: TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  color: Color(0xFF00FFA3),
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

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
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F3B2E).withValues(alpha: 0.3),
            const Color(0xFF030D0A).withValues(alpha: 0.95),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.payment, color: Color(0xFF00FFA3), size: 16),
              SizedBox(width: 8),
              Text(
                'PAYMENT BREAKDOWN',
                style: TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  color: Color(0xFF00FFA3),
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Session Fee
          _buildPaymentRow(
            label: 'Session Fee',
            value: '₹${_sessionFee.toStringAsFixed(2)}',
            isHighlighted: false,
          ),

          const SizedBox(height: 10),

          // Platform Fee
          _buildPaymentRow(
            label: 'Platform Fee',
            value: '₹${_platformFee.toStringAsFixed(2)}',
            isHighlighted: false,
          ),

          const SizedBox(height: 10),

          // GST
          _buildPaymentRow(
            label: 'GST (18%)',
            value: '₹${_gst.toStringAsFixed(2)}',
            isHighlighted: false,
          ),

          const SizedBox(height: 18),

          // Divider
          Divider(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
            thickness: 1.2,
          ),

          const SizedBox(height: 18),

          // Total Amount (Primary Visual Focus)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  color: Color(0xFF00FFA3),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Color(0xFF00FFA3),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0C241B).withValues(alpha: 0.35),
            const Color(0xFF030D0A).withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFA3).withValues(alpha: 0.02),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.credit_card, color: Color(0xFF00FFA3), size: 16),
              SizedBox(width: 8),
              Text(
                'PAYMENT METHOD',
                style: TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  color: Color(0xFF00FFA3),
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Razorpay Active Option
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFA3).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00FFA3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                // Razorpay Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFA3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.black,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Razorpay Checkout',
                        style: TextStyle(
                          fontFamily: 'Gilroy-Bold',
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Secure payments including Cards & UPI',
                        style: TextStyle(
                          fontFamily: 'Gilroy-Medium',
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Custom Check Indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FFA3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.black, size: 15),
                ),
              ],
            ),
          ),

          // Placeholders for visual scalability
          const SizedBox(height: 18),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPaymentPlaceholder("UPI", Icons.qr_code),
              _buildPaymentPlaceholder("Cards", Icons.credit_card),
              _buildPaymentPlaceholder("Netbanking", Icons.account_balance),
              _buildPaymentPlaceholder("Wallets", Icons.wallet),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPlaceholder(String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white38,
            size: 16,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00FFA3), size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Gilroy-Medium',
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Gilroy-Bold',
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
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
            fontFamily: isHighlighted ? 'Gilroy-Bold' : 'Gilroy-Medium',
            color: isHighlighted ? Colors.white : Colors.white70,
            fontSize: isHighlighted ? 16 : 14,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Gilroy-Bold',
            color: isHighlighted ? const Color(0xFF00FFA3) : Colors.white,
            fontSize: isHighlighted ? 16 : 14,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
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
      _mentorBookingService.purchaseMentorSession(
        context: context,
        mentorId: widget.mentorId,
        mentorName: widget.mentorName,
        selectedDate: widget.selectedDate,
        selectedTime: widget.selectedTime,
        selectedDuration: widget.selectedDuration,
        totalAmount: _totalAmount,
        keyId: dotenv.env['RAZORPAY_KEY_ID'] ?? '',
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
        backgroundColor: const Color(0xFF030705),
        title: const Text(
          'Payment Successful',
          style: TextStyle(color: Colors.white, fontFamily: 'Gilroy-Bold'),
        ),
        content: Text(message, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontFamily: 'Gilroy-Medium')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF00FFA3), fontFamily: 'Gilroy-Bold')),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF030705),
        title: const Text(
          'Payment Error',
          style: TextStyle(color: Colors.white, fontFamily: 'Gilroy-Bold'),
        ),
        content: Text(message, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontFamily: 'Gilroy-Medium')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Retry',
              style: TextStyle(color: Color(0xFF00FFA3), fontFamily: 'Gilroy-Bold'),
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
        backgroundColor: const Color(0xFF030705),
        title: const Text('Payment', style: TextStyle(color: Colors.white, fontFamily: 'Gilroy-Bold')),
        content: Text(message, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontFamily: 'Gilroy-Medium')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFF00FFA3), fontFamily: 'Gilroy-Bold')),
          ),
        ],
      ),
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _StaggeredItem({required this.child, required this.index});

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _translate = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: 50 + widget.index * 80), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _translate.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _SecurePaymentCard extends StatelessWidget {
  const _SecurePaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C241B).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFA3).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock,
              color: Color(0xFF00FFA3),
              size: 16,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Secure Payment",
                  style: TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Your payment is protected using Razorpay's secure payment gateway and encrypted transactions.",
                  style: TextStyle(
                    fontFamily: 'Gilroy-Medium',
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProceedToPayButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ProceedToPayButton({required this.onPressed});

  @override
  State<_ProceedToPayButton> createState() => _ProceedToPayButtonState();
}

class _ProceedToPayButtonState extends State<_ProceedToPayButton> with SingleTickerProviderStateMixin {
  bool _isTapped = false;
  late AnimationController _pulsateController;

  @override
  void initState() {
    super.initState();
    _pulsateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulsateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isTapped ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: AnimatedBuilder(
        animation: _pulsateController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFA3).withValues(
                    alpha: 0.2 + 0.1 * _pulsateController.value,
                  ),
                  blurRadius: 15 + 10 * _pulsateController.value,
                  spreadRadius: 1 + 2 * _pulsateController.value,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
                setState(() => _isTapped = true);
                await Future.delayed(const Duration(milliseconds: 150));
                setState(() => _isTapped = false);
                widget.onPressed();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFA3),
                foregroundColor: const Color(0xFF030705),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock, size: 18),
                  SizedBox(width: 10),
                  Text(
                    "Pay Securely",
                    style: TextStyle(
                      fontFamily: 'Gilroy-Bold',
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
