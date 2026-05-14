import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../services/payment_service.dart';
import '../../../../models/payment/item_type.dart';
import '../../../../data/services/api_service.dart';

/// MentorPaymentScreen
///
/// Displays a payment summary for a mentor session booking and triggers
/// Razorpay checkout via the backend create-order API.
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
  // Payment amounts
  late double _sessionFee;
  late double _platformFee;
  late double _gst;
  late double _totalAmount;

  // Payment service
  late final PaymentService _paymentService;
  bool _isProcessing = false;

  // API service for verification
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _calculatePaymentAmounts();

    _paymentService = PaymentService();
    _paymentService.initialize(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  // ─── Payment Amount Calculation ──────────────────────────────────────────

  void _calculatePaymentAmounts() {
    final String priceString = widget.mentorPrice.replaceAll(
      RegExp(r'[^\d.]'),
      '',
    );
    final double basePrice = double.tryParse(priceString) ?? 0.0;

    if (widget.selectedDuration.contains('30')) {
      _sessionFee = basePrice * 0.5;
    } else if (widget.selectedDuration.contains('90')) {
      _sessionFee = basePrice * 1.5;
    } else {
      _sessionFee = basePrice; // Default: 60 mins = 1 hour
    }

    _platformFee = _sessionFee * 0.05; // 5% platform fee
    _gst = (_sessionFee + _platformFee) * 0.18; // 18% GST
    _totalAmount = _sessionFee + _platformFee + _gst;
  }

  // ─── Razorpay Callbacks ───────────────────────────────────────────────────

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('✅ Mentor booking payment SUCCESS: ${response.paymentId}');

    if (!mounted) return;
    setState(() => _isProcessing = false);

    try {
      // Verify payment with backend
      await _apiService.payment.verifyPayment(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        itemId: widget.mentorId,
        itemType: ItemType.session,
      );
      debugPrint('✅ Mentor booking payment verified');

      if (mounted) {
        _showSuccessDialog(
          'Mentor session booked successfully! Your booking is confirmed.',
        );
      }
    } catch (e) {
      debugPrint('❌ Mentor booking verification failed: $e');
      if (mounted) {
        _showErrorDialog(
          'Payment received but verification failed. Please contact support.',
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint(
      '❌ Mentor booking payment ERROR: ${response.code} — ${response.message}',
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _showErrorDialog(_friendlyErrorMessage(response.code?.toString()));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('👛 External wallet selected: ${response.walletName}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${response.walletName}...'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  // ─── Initiate Payment ────────────────────────────────────────────────────

  Future<void> _proceedToPayment() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    await _paymentService.createOrderAndOpenCheckout(
      context: context,
      itemId: widget.mentorId,
      itemType: ItemType.session,
      itemDescription:
          '${widget.selectedDuration} session with ${widget.mentorName} '
          'on ${_formatDate(widget.selectedDate)} at ${widget.selectedTime}',
    );

    // Reset processing state if checkout was not opened (error case)
    if (mounted && _isProcessing) {
      setState(() => _isProcessing = false);
    }
  }

  // ─── UI ──────────────────────────────────────────────────────────────────

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
            _buildMentorInfoCard(),
            const SizedBox(height: 20),
            _buildBookingDetailsCard(),
            const SizedBox(height: 20),
            _buildPaymentBreakdownCard(),
            const SizedBox(height: 20),
            _buildPaymentMethodCard(),
            const SizedBox(height: 100),
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
            onPressed: _isProcessing ? null : _proceedToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isProcessing ? Colors.grey : const Color(0xFF00C853),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const Text(
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
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: _formatDate(widget.selectedDate),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.access_time_outlined,
            label: 'Time',
            value: widget.selectedTime,
          ),
          const SizedBox(height: 12),
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
          _buildPaymentRow(
            label: 'Session Fee',
            value: '₹${_sessionFee.toStringAsFixed(2)}',
            highlighted: false,
          ),
          const SizedBox(height: 8),
          _buildPaymentRow(
            label: 'Platform Fee (5%)',
            value: '₹${_platformFee.toStringAsFixed(2)}',
            highlighted: false,
          ),
          const SizedBox(height: 8),
          _buildPaymentRow(
            label: 'GST (18%)',
            value: '₹${_gst.toStringAsFixed(2)}',
            highlighted: false,
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          _buildPaymentRow(
            label: 'Total Amount',
            value: '₹${_totalAmount.toStringAsFixed(2)}',
            highlighted: true,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00C853)),
            ),
            child: Row(
              children: [
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
                      Text(
                        'Razorpay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Secure payment gateway',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.black, size: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
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
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14)),
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
    required bool highlighted,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: highlighted ? Colors.white : Colors.white70,
            fontSize: highlighted ? 16 : 14,
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlighted ? const Color(0xFF00C853) : Colors.white,
            fontSize: highlighted ? 16 : 14,
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _friendlyErrorMessage(String? code) {
    switch (code) {
      case 'BAD_REQUEST_ERROR':
        return 'Invalid request. Please try again.';
      case 'NETWORK_ERROR':
        return 'Network error. Please check your connection.';
      case 'INTERNAL_SERVER_ERROR':
        return 'Server error. Please try again in a few minutes.';
      case 'PAYMENT_CANCELLED':
        return 'Payment was cancelled. Please try again.';
      case 'PAYMENT_FAILED':
        return 'Payment failed. Please try a different payment method.';
      default:
        return 'Payment failed. Please try again.';
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF00C853)),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
}
