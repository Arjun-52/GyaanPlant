import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../data/services/api_service.dart';
import '../models/payment/item_type.dart';

class PaymentService {
  late Razorpay _razorpay;
  final ApiService _apiService = ApiService();

  /// Initialize Razorpay with callbacks
  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onExternal,
  }) {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternal);
  }

  /// Create order and open Razorpay checkout
  Future<void> purchaseItem({
    required BuildContext context,
    required String itemId,
    required ItemType itemType,
    String? itemName,
    String? itemDescription,
  }) async {
    try {
      print("🚀 START PAYMENT");

      // Create order ONLY
      final order = await _apiService.payment.createOrder(
        itemId: itemId,
        itemType: itemType,
      );

      print("🧾 ORDER: $order");

      // Check if this is a free course
      if (order['isFree'] == true) {
        print("⚠️ FREE COURSE DETECTED → DIRECT ENROLL");
        await _enrollFreeItem(context, itemId, itemType);
        return;
      }

      // Get order details with flexible field mapping
      final orderId = order['orderId'] ?? order['razorpayOrderId'];
      final amount = order['amount'] ?? order['amountInPaise'];

      if (orderId == null || amount == null) {
        throw Exception('Invalid order response: missing orderId or amount');
      }

      print("💳 OPENING RAZORPAY");

      // Open Razorpay checkout ONLY - no other work
      _razorpay.open({
        'key': 'rzp_test_SgTgIrRTm5fJjb',
        'order_id': orderId,
        'amount': amount,
        'name': 'GyaanPlant',
        'description': itemDescription ?? 'Purchase ${itemType.value}',
        'prefill':
            order['prefill'] ??
            {'contact': '9999999999', 'email': 'test@example.com'},
        'theme': {'color': '#00C853'},
      });
    } catch (e) {
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

  /// Dispose Razorpay instance
  void dispose() {
    _razorpay.clear();
  }
}
