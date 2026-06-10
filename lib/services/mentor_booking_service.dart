import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../config/payment_config.dart';
import '../repositories/mentor_payment_repository.dart';
import '../models/payment/item_type.dart';
import '../models/payment/order_result.dart';
import '../network/api_manager.dart';

class MentorBookingService {
  late Razorpay _razorpay;
  bool _isInitialized = false;
  final MentorPaymentRepository _mentorPaymentRepository = MentorPaymentRepository();

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

  DateTime _combineDateAndTime(DateTime date, String timeStr) {
    try {
      final cleaned = timeStr.trim().toUpperCase();
      final isAmPm = cleaned.contains('AM') || cleaned.contains('PM');
      
      int hour = 0;
      int minute = 0;
      
      if (isAmPm) {
        final parts = cleaned.split(' ');
        final timeParts = parts[0].split(':');
        hour = int.parse(timeParts[0]);
        minute = int.parse(timeParts[1]);
        final amPm = parts[1];
        if (amPm == 'PM' && hour < 12) hour += 12;
        if (amPm == 'AM' && hour == 12) hour = 0;
      } else {
        final timeParts = cleaned.split(':');
        hour = int.parse(timeParts[0]);
        minute = int.parse(timeParts[1]);
      }
      
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      return date;
    }
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
    required String topic,
    required String description,
    required double totalAmount,
    required String keyId,
    Map<String, dynamic>? bookingDetails,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'MentorBookingService not initialized. Call init() first.',
      );
    }

    // Show loading indicator dialog while we call the backend API
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
        ),
      ),
    );

    try {
      final combinedDate = _combineDateAndTime(selectedDate, selectedTime);
      final durationMinutes = int.tryParse(selectedDuration.replaceAll(RegExp(r'\D'), '')) ?? 60;

      // 1. Create Booking Session
      final bookingUrl = '/api/v1/mentor/$mentorId/book';
      final bookingPayload = {
        'topic': topic,
        'description': description,
        'date': combinedDate.toUtc().toIso8601String(),
        'duration': durationMinutes,
      };

      print("🚀 START MENTOR BOOKING");
      print("  Mentor ID: $mentorId");
      print("  Mentor Name: $mentorName");
      print("  Endpoint URL: $bookingUrl");
      print("  Payload: $bookingPayload");

      final bookingResponse = await _mentorPaymentRepository.createBooking(
        mentorId: mentorId,
        topic: topic,
        description: description,
        date: combinedDate,
        duration: durationMinutes,
      );

      print("  Response: $bookingResponse");

      final bookingSuccess = bookingResponse['success'] as bool? ?? false;
      if (!bookingSuccess || bookingResponse['data'] == null) {
        throw Exception('Failed to create booking: ${bookingResponse['message']}');
      }

      final bookingData = bookingResponse['data'] as Map<String, dynamic>;
      final sessionId = (bookingData['_id'] ?? '') as String;
      if (sessionId.isEmpty) {
        throw Exception('Failed to create booking: No session ID returned');
      }

      // 2. Create Payment Order using session ID
      final orderUrl = '/api/v1/payments/create-order';
      final orderPayload = {
        'itemId': sessionId,
        'itemType': 'Session',
      };

      print("🚀 CREATE PAYMENT ORDER");
      print("  Endpoint URL: $orderUrl");
      print("  Payload: $orderPayload");

      final orderResponse = await _mentorPaymentRepository.createMentorBookingOrder(
        sessionId: sessionId,
      );

      print("  Response: $orderResponse");

      // Close the loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      final orderSuccess = orderResponse['success'] as bool? ?? false;
      if (!orderSuccess || orderResponse['data'] == null) {
        throw Exception('Failed to create order on server: ${orderResponse['message']}');
      }

      final data = orderResponse['data'] as Map<String, dynamic>;
      final orderId = (data['razorpayOrderId'] ?? data['orderId'] ?? '') as String;
      final amount = data['amountInPaise'] ?? ((data['amount'] ?? totalAmount) * 100).toInt();
      final responseKeyId = (data['keyId'] ?? '') as String;
      final finalKeyId = responseKeyId.isNotEmpty ? responseKeyId : keyId;

      print("🧾 REAL MENTOR BOOKING ORDER: orderId=$orderId, amount=$amount, keyId=$finalKeyId");

      // Validation
      if (finalKeyId.isEmpty) {
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

      if (amount <= 0) {
        final errorMsg = 'Payment amount must be greater than 0 (got: $amount).';
        print('❌ ERROR: $errorMsg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.redAccent,
          ),
        );
        throw ArgumentError(errorMsg);
      }

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

      print("🔑 Razorpay Key: $finalKeyId");
      print("💳 OPENING Razorpay for mentor booking: $orderId");

      // Open Razorpay checkout for mentor session
      final options = {
        'key': finalKeyId,
        'amount': amount,
        'order_id': orderId,
        'currency': data['currency'] ?? 'INR',
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

      print('RAZORPAY OPTIONS');
      print(jsonEncode(options));

      print("🏁 Attempting to open Razorpay Checkout sheet...");
      _razorpay.open(options);
      print("✅ Razorpay Checkout open() call finished successfully.");
    } catch (e, st) {
      // Close the loading dialog if it is still open
      if (context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }

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
    required String razorpaySignature,
  }) async {
    try {
      print("🔍 VERIFYING MENTOR BOOKING PAYMENT: $razorpayPaymentId");

      final verification = await _mentorPaymentRepository.verifyMentorBookingPayment(
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
      );

      print("✅ MENTOR BOOKING PAYMENT VERIFIED: ${verification['success']}");
      return verification;
    } catch (e) {
      print("❌ MENTOR BOOKING PAYMENT VERIFICATION FAILED: $e");
      throw Exception('Mentor booking payment verification failed: $e');
    }
  }

  /// Refresh user sessions
  Future<void> refreshSessions() async {
    try {
      print("🔄 Refreshing user sessions via GET /api/v1/session/my");
      final NetworkAPIManager api = NetworkAPIManager.instance;
      final response = await api.get<Map<String, dynamic>>(
        '/api/v1/session/my',
        fromJson: (json) => json as Map<String, dynamic>,
      );
      print("🔄 Sessions refreshed response: ${response.data}");
    } catch (e) {
      print("⚠️ Failed to refresh user sessions: $e");
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
