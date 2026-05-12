import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../config/payment_config.dart';
import '../data/services/api_service.dart';
import '../models/payment/item_type.dart';
import '../models/auth/auth_user_model.dart';

class PaymentService {
  late Razorpay _razorpay;
  final ApiService _apiService = ApiService();
  Timer? _paymentTimer;
  bool _isInitialized = false;

  /// Initialize Razorpay with callbacks
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
    print("🔧 Razorpay initialized with key: ${PaymentConfig.razorpayKey}");
  }

  /// Create order and open Razorpay checkout
  Future<void> purchaseItem({
    required BuildContext context,
    required String itemId,
    required ItemType itemType,
    String? itemName,
    String? itemDescription,
    AuthUser? user,
  }) async {
    if (!_isInitialized) {
      throw Exception('PaymentService not initialized. Call init() first.');
    }

    try {
      print("🚀 START PAYMENT for $itemType: $itemId");

      // Start payment timeout timer
      _startPaymentTimeout();

      // Create order ONLY
      final order = await _apiService.payment.createOrder(
        itemId: itemId,
        itemType: itemType,
      );

      print("🧾 ORDER: $order");

      // Check if this is a free course
      if (order['isFree'] == true) {
        print("⚠️ FREE COURSE DETECTED → DIRECT ENROLL");
        _cancelPaymentTimeout();
        await _enrollFreeItem(context, itemId, itemType);
        return;
      }

      // Get order details with flexible field mapping
      final orderId = order['orderId'] ?? order['razorpayOrderId'];
      final amount = order['amount'] ?? order['amountInPaise'];

      if (orderId == null || amount == null) {
        _cancelPaymentTimeout();
        throw Exception('Invalid order response: missing orderId or amount');
      }

      print("💳 OPENING RAZORPAY with order: $orderId");

      // Get user data for prefill
      final userEmail = user?.email;
      final userName = user?.name;

      // Open Razorpay checkout with improved configuration
      final options = {
        'key': PaymentConfig.razorpayKey,
        'order_id': orderId,
        'amount': amount,
        'name': 'GyaanPlant',
        'description': itemDescription ?? PaymentConfig.defaultDescription,
        'theme': {'color': PaymentConfig.themeColor},
      };

      // Add user data if available
      if (userEmail != null || userName != null) {
        final prefill = <String, String>{};
        if (userEmail != null) prefill['email'] = userEmail;
        if (userName != null) prefill['name'] = userName;
        options['prefill'] = prefill;
      }

      _razorpay.open(options);
    } on SocketException catch (e) {
      _cancelPaymentTimeout();
      print("❌ NETWORK ERROR: $e");
      _showErrorDialog(
        context,
        'Network error. Please check your internet connection.',
      );
    } on TimeoutException catch (e) {
      _cancelPaymentTimeout();
      print("❌ TIMEOUT ERROR: $e");
      _showErrorDialog(context, 'Payment request timed out. Please try again.');
    } catch (e) {
      _cancelPaymentTimeout();
      print("❌ PAYMENT SETUP FAILED: $e");
      _showErrorDialog(context, 'Failed to create payment order: $e');
    }
  }

  /// Verify payment after successful Razorpay transaction
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String itemId,
    required ItemType itemType,
  }) async {
    try {
      final verification = await _apiService.payment.verifyPayment(
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        itemId: itemId,
        itemType: itemType,
      );

      return verification;
    } catch (e) {
      throw Exception('Payment verification failed: $e');
    }
  }

  /// Enroll in free item directly
  Future<void> _enrollFreeItem(
    BuildContext context,
    String itemId,
    ItemType itemType,
  ) async {
    try {
      await _apiService.payment.enrollFreeItem(
        itemId: itemId,
        itemType: itemType,
      );

      print("🎉 ENROLLED WITHOUT PAYMENT");

      if (context.mounted) {
        _showSuccessDialog(context, 'Free item enrolled successfully!');
      }
    } catch (e) {
      print("❌ FREE ENROLLMENT FAILED: $e");
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to enroll in free item: $e');
      }
    }
  }

  /// Show success dialog
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Dispose Razorpay instance and cleanup
  void dispose() {
    _cancelPaymentTimeout();
    if (_isInitialized) {
      _razorpay.clear();
      _isInitialized = false;
      print("🧹 Razorpay disposed");
    }
  }

  /// Start payment timeout timer
  void _startPaymentTimeout() {
    _cancelPaymentTimeout(); // Cancel any existing timer

    _paymentTimer = Timer(PaymentConfig.paymentTimeout, () {
      print("⏰ PAYMENT TIMEOUT REACHED");
      _cancelPaymentTimeout();
      // Note: UI should handle timeout state through callbacks
    });

    print(
      "⏱️ Payment timeout started: ${PaymentConfig.paymentTimeout.inMinutes} minutes",
    );
  }

  /// Cancel payment timeout timer
  void _cancelPaymentTimeout() {
    if (_paymentTimer != null && _paymentTimer!.isActive) {
      _paymentTimer!.cancel();
      _paymentTimer = null;
      print("⏹️ Payment timeout cancelled");
    }
  }
}
