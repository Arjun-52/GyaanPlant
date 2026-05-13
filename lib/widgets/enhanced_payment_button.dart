import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';

import '../models/auth/auth_user_model.dart';
import '../models/payment/item_type.dart';
import '../models/payment/payment_result.dart';
import '../services/payment_service.dart';

class EnhancedPaymentButton extends StatefulWidget {
  final String itemId;
  final ItemType itemType;
  final String? itemName;
  final String? itemDescription;
  final AuthUser? user;
  final VoidCallback? onPaymentComplete;
  final bool isLoading;

  const EnhancedPaymentButton({
    super.key,
    required this.itemId,
    required this.itemType,
    this.itemName,
    this.itemDescription,
    this.user,
    this.onPaymentComplete,
    this.isLoading = false,
  });

  @override
  State<EnhancedPaymentButton> createState() => _EnhancedPaymentButtonState();
}

class _EnhancedPaymentButtonState extends State<EnhancedPaymentButton> {
  static const _tag = 'EnhancedPaymentButton';
  static const int _maxRetries = 3;

  late final PaymentService _paymentService;
  bool _isProcessing = false;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService()..init();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (_isProcessing || widget.isLoading) return;

    setState(() {
      _isProcessing = true;
      _retryCount = 0;
    });

    await _runPayment();
  }

  Future<void> _runPayment() async {
    final result = await _paymentService.purchaseItem(
      itemId: widget.itemId,
      itemType: widget.itemType,
      itemDescription: widget.itemDescription,
      user: widget.user,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result) {
      case FreeEnrollmentSucceeded():
        _showSuccessSnackBar('Free item enrolled successfully!');
        widget.onPaymentComplete?.call();
      case PaymentSucceeded():
        _showSuccessSnackBar('Payment successful!');
        widget.onPaymentComplete?.call();
      case ExternalWalletSelected(walletName: final wallet):
        _showInfoSnackBar('External wallet selected: ${wallet ?? "unknown"}');
      case PaymentFailed(reason: final reason, message: final msg):
        AppLogger.warning(_tag, 'Payment failed ($reason): $msg');
        if (reason == PaymentFailureReason.ssl && _retryCount < _maxRetries) {
          _showRetryDialog('SSL Certificate Error: $msg');
        } else {
          _showErrorDialog(msg);
        }
    }
  }

  Future<void> _retryPayment() async {
    setState(() {
      _retryCount++;
      _isProcessing = true;
    });
    // Small delay before retry — SSL flakes can resolve on a fresh handshake.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await _runPayment();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showRetryDialog(String errorMessage) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.orange),
            SizedBox(width: 8),
            Text('Payment Retry'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage),
            const SizedBox(height: 16),
            Text(
              'Attempt ${_retryCount + 1} of $_maxRetries',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'SSL certificate issues can sometimes be resolved by retrying.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _retryPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry Payment'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Payment Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              'If this problem persists, please contact support.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final disabled = _isProcessing || widget.isLoading;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: disabled ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? Colors.grey : Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: disabled
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...'),
                ],
              )
            : const Text(
                'Proceed to Payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
