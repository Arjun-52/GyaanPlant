import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../config/payment_config.dart';

class MentorBookingService {
  late Razorpay _razorpay;
  bool _isInitialized = false;

  /// Initialize Razorpay with mentor-specific callbacks
  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onExternal,
  }) {
    if (_isInitialized) return;

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternal);

    _isInitialized = true;
    print("🔧 MentorBookingService initialized");
  }

  /// Purchase mentor session booking.
  ///
  /// `keyId` is the Razorpay public key the backend returned on the
  /// create-order response. The frontend no longer holds a build-time key —
  /// the caller is responsible for fetching `keyId` from the backend.
  Future<void> purchaseMentorSession({
    required BuildContext context,
    required String mentorId,
    required String mentorName,
    required DateTime selectedDate,
    required String selectedTime,
    required String selectedDuration,
    required double totalAmount,
    required String keyId,
    Map<String, dynamic>? bookingDetails,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'MentorBookingService not initialized. Call init() first.',
      );
    }

    // Validation
    if (keyId.isEmpty) {
      const errorMsg = 'Razorpay Key ID is empty. Please check your configuration.';
      print('❌ ERROR: $errorMsg');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.redAccent,
        ),
      );
      throw ArgumentError(errorMsg);
    }

    if (totalAmount <= 0) {
      final errorMsg = 'Payment amount must be greater than 0 (got: $totalAmount).';
      print('❌ ERROR: $errorMsg');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.redAccent,
        ),
      );
      throw ArgumentError(errorMsg);
    }

    final orderId = 'mentor_${DateTime.now().millisecondsSinceEpoch}';
    final amount = (totalAmount * 100).toInt(); // Convert to paise

    if (orderId.isEmpty) {
      const errorMsg = 'Razorpay order ID could not be generated.';
      print('❌ ERROR: $errorMsg');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.redAccent,
        ),
      );
      throw ArgumentError(errorMsg);
    }

    try {
      print("🚀 START MENTOR BOOKING for mentor: $mentorId");
      print("🧾 MOCK MENTOR BOOKING ORDER: orderId=$orderId, amount=$amount");
      print("🔑 Razorpay Key: $keyId");
      print("💳 OPENING RAZORPAY for mentor booking: $orderId");

      // Open Razorpay checkout for mentor session
      final options = {
        'key': keyId,
        'amount': amount,
        'order_id': orderId,
        'name': 'Mentor Session with $mentorName',
        'description':
            '$selectedDuration session on ${_formatDate(selectedDate)} at $selectedTime',
        'prefill': {
          'contact': '', // Will be filled from user profile
          'email': '', // Will be filled from user profile
        },
        'theme': {'color': '#00C853'},
        'modal': {
          'backdropclose': false,
          'escape': false,
          'handleback': false,
          'confirm_close': true,
          'animation': 'fade-in',
        },
        'retry': {'enabled': true, 'max_count': 3},
        'timeout': PaymentConfig.paymentTimeout.inSeconds,
      };

      // Debug logging to verify all values are JSON-serializable
      print("🔍 RAZORPAY OPTIONS DEBUG:");
      options.forEach((key, value) {
        print("  $key: $value (${value.runtimeType})");
      });

      print("🏁 Attempting to open Razorpay Checkout sheet...");
      _razorpay.open(options);
      print("✅ Razorpay Checkout open() call finished successfully.");
    } catch (e, st) {
      print("❌ MENTOR BOOKING PAYMENT EXCEPTION: $e");
      print("Stack trace:\n$st");
      
      // Show snackbar with exact exception reason
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open Razorpay checkout: $e'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
        ),
      );
      
      throw Exception('Failed to initiate mentor booking payment: $e');
    }
  }

  /// Verify mentor booking payment
  Future<Map<String, dynamic>> verifyMentorBookingPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String mentorId,
  }) async {
    try {
      print("🔍 VERIFYING MENTOR BOOKING PAYMENT: $razorpayPaymentId");

      // TEMPORARY: Mock verification to bypass backend
      final verification = {
        'success': true,
        'paymentId': razorpayPaymentId,
        'orderId': razorpayOrderId,
        'mentorId': mentorId,
        'message': 'Mentor booking payment verified successfully',
      };

      print(
        "✅ MOCK MENTOR BOOKING PAYMENT VERIFIED: ${verification['success']}",
      );
      return verification;
    } catch (e) {
      print("❌ MENTOR BOOKING PAYMENT VERIFICATION FAILED: $e");
      throw Exception('Mentor booking payment verification failed: $e');
    }
  }

  /// Dispose Razorpay instance and cleanup
  void dispose() {
    if (_isInitialized) {
      _razorpay.clear();
      _isInitialized = false;
      print("🧹 MentorBookingService disposed");
    }
  }

  /// Format date for display
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

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}
