import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../config/payment_config.dart';
import '../data/services/api_service.dart';
import '../models/payment/item_type.dart';
import '../models/auth/auth_user_model.dart';

class PaymentService {
  static const _tag = 'PaymentService';

  late Razorpay _razorpay;
  final ApiService _apiService = ApiService();
  Timer? _paymentTimer;
  bool _isInitialized = false;

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onExternal,
  }) {
    if (_isInitialized) return;

    // Fails loudly if RAZORPAY_KEY wasn't supplied at build time.
    PaymentConfig.ensureConfigured();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternal);

    _isInitialized = true;
    AppLogger.info(
      _tag,
      'Razorpay initialized (${PaymentConfig.isProduction ? "live" : "test"} mode)',
    );
  }

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
      AppLogger.info(_tag, 'Starting payment for $itemType: $itemId');

      // Start payment timeout timer
      _startPaymentTimeout();

      // Create order ONLY
      final order = await _apiService.payment.createOrder(
        itemId: itemId,
        itemType: itemType,
      );

      if (order['isFree'] == true) {
        AppLogger.info(_tag, 'Free item — enrolling directly');
        if (!context.mounted) return;
        await _enrollFreeItem(context, itemId, itemType);
        return;
      }

      final orderId = order['orderId'] ?? order['razorpayOrderId'];
      final amount = order['amount'] ?? order['amountInPaise'];

      if (orderId == null || amount == null) {
        _cancelPaymentTimeout();
        throw Exception('Invalid order response: missing orderId or amount');
      }

      AppLogger.info(_tag, 'Opening Razorpay for order $orderId');

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
      AppLogger.error(_tag, '❌ NETWORK ERROR: $e');
      _showErrorDialog(
        context,
        'Network error. Please check your internet connection.',
        errorType: 'network',
      );
    } on TimeoutException catch (e) {
      _cancelPaymentTimeout();
      AppLogger.error(_tag, '❌ TIMEOUT ERROR: $e');
      _showErrorDialog(
        context,
        'Payment request timed out. Please try again.',
        errorType: 'timeout',
      );
    } on HandshakeException catch (e) {
      _cancelPaymentTimeout();
      AppLogger.error(_tag, '🔒 SSL HANDSHAKE ERROR: $e');
      _showErrorDialog(
        context,
        'Secure connection failed. Please check your network settings and try again.',
        errorType: 'ssl',
        showRetry: true,
      );
    } catch (e) {
      _cancelPaymentTimeout();
      AppLogger.error(_tag, '❌ PURCHASE ERROR: $e');
      _showErrorDialog(
        context,
        'Failed to create payment order: $e',
        errorType: 'general',
        showRetry: true,
      );
    }
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String itemId,
    required ItemType itemType,
  }) {
    return _apiService.payment.verifyPayment(
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      itemId: itemId,
      itemType: itemType,
    );
  }

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
      AppLogger.info(_tag, 'Free enrollment success: $itemId');
      if (context.mounted) {
        _showSuccessDialog(context, 'Free item enrolled successfully!');
      }
    } catch (e) {
      AppLogger.error(_tag, 'Free enrollment failed: $e');
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to enroll in free item: $e');
      }
    }
  }

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

  void _showErrorDialog(
    BuildContext context,
    String message, {
    String errorType = 'general',
    bool showRetry = false,
  }) {
    AppLogger.error(_tag, 'Showing error dialog: $message (type: $errorType)');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getErrorIcon(errorType),
              color: _getErrorColor(errorType),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Payment Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 8),
            if (errorType == 'ssl') ...[
              const Text(
                'This appears to be an SSL certificate issue. '
                'The app has been configured to handle this, '
                'but you may need to restart the app.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          if (showRetry)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Retry logic can be added here
              },
              child: const Text('Retry'),
            ),
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
      AppLogger.info(_tag, '🧹 Razorpay disposed');
    }
  }

  /// Start payment timeout timer
  void _startPaymentTimeout() {
    _cancelPaymentTimeout(); // Cancel any existing timer

    _paymentTimer = Timer(PaymentConfig.paymentTimeout, () {
      AppLogger.warning(_tag, 'Payment timeout reached');
      _cancelPaymentTimeout();
      // Note: UI should handle timeout state through callbacks
    });

    AppLogger.info(
      _tag,
      "⏱️ Payment timeout started: ${PaymentConfig.paymentTimeout.inMinutes} minutes",
    );
  }

  /// Cancel payment timeout timer
  void _cancelPaymentTimeout() {
    if (_paymentTimer != null && _paymentTimer!.isActive) {
      _paymentTimer!.cancel();
      _paymentTimer = null;
      AppLogger.info(_tag, '⏹️ Payment timeout cancelled');
    }
  }

  /// Handle payment success with enhanced logging
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _cancelPaymentTimeout();
    AppLogger.info(_tag, '💳 PAYMENT SUCCESS: ${response.paymentId}');
    AppLogger.info(_tag, '📋 Order ID: ${response.orderId}');

    // Call original success handler if set
    // Note: You'll need to pass the success callback in init method
  }

  /// Handle payment error with enhanced logging and SSL detection
  void _handlePaymentError(PaymentFailureResponse response) {
    _cancelPaymentTimeout();
    AppLogger.error(
      _tag,
      '❌ PAYMENT ERROR: ${response.code} - ${response.message}',
    );

    // Detect SSL-related errors
    if (response.message?.toLowerCase().contains('certificate') == true ||
        response.message?.toLowerCase().contains('ssl') == true ||
        response.message?.toLowerCase().contains('handshake') == true) {
      AppLogger.error(_tag, '🔒 SSL/Certificate error detected in Razorpay');
    }

    // Call original error handler if set
    // Note: You'll need to pass the error callback in init method
  }

  /// Get error icon based on error type
  IconData _getErrorIcon(String errorType) {
    switch (errorType) {
      case 'ssl':
        return Icons.security;
      case 'network':
        return Icons.wifi_off;
      case 'timeout':
        return Icons.access_time;
      default:
        return Icons.error;
    }
  }

  /// Get error color based on error type
  Color _getErrorColor(String errorType) {
    switch (errorType) {
      case 'ssl':
        return Colors.orange;
      case 'network':
        return Colors.red;
      case 'timeout':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
