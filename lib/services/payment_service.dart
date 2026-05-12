import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../data/services/api_service.dart';
import '../models/payment/item_type.dart';

class PaymentService {
  static const _tag = 'PaymentService';

  late Razorpay _razorpay;
  final ApiService _apiService = ApiService();

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

  Future<void> purchaseItem({
    required BuildContext context,
    required String itemId,
    required ItemType itemType,
    String? itemName,
    String? itemDescription,
  }) async {
    try {
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
        throw Exception('Invalid order response: missing orderId or amount');
      }

      AppLogger.info(_tag, 'Opening Razorpay for order $orderId');

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
      AppLogger.error(_tag, 'purchaseItem failed: $e');
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to create payment order: $e');
      }
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

  void dispose() {
    _razorpay.clear();
  }
}
