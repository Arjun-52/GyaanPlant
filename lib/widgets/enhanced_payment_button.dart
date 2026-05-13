import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/payment_service.dart';
import '../models/payment/item_type.dart';
import '../models/auth/auth_user_model.dart';

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
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _initializePaymentService();
  }

  void _initializePaymentService() {
    _paymentService.init(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternal: _handleExternalWallet,
    );
  }

  Future<void> _handlePayment() async {
    if (_isProcessing || widget.isLoading) return;

    setState(() {
      _isProcessing = true;
      _retryCount = 0;
    });

    try {
      await _paymentService.purchaseItem(
        context: context,
        itemId: widget.itemId,
        itemType: widget.itemType,
        itemName: widget.itemName,
        itemDescription: widget.itemDescription,
        user: widget.user,
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      _showRetryDialog(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      _isProcessing = false;
      _retryCount = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Payment successful!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    widget.onPaymentComplete?.call();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isProcessing = false;
    });

    // Check if this is an SSL-related error
    final isSSLError =
        response.message?.toLowerCase().contains('certificate') == true ||
        response.message?.toLowerCase().contains('ssl') == true ||
        response.message?.toLowerCase().contains('handshake') == true;

    if (isSSLError && _retryCount < _maxRetries) {
      _showRetryDialog('SSL Certificate Error: ${response.message}');
    } else {
      _showErrorDialog(response.message ?? 'Payment failed');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showRetryDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
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

  void _retryPayment() async {
    setState(() {
      _retryCount++;
    });

    // Add a small delay before retry
    await Future.delayed(const Duration(seconds: 2));

    try {
      await _paymentService.purchaseItem(
        context: context,
        itemId: widget.itemId,
        itemType: widget.itemType,
        itemName: widget.itemName,
        itemDescription: widget.itemDescription,
        user: widget.user,
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (_retryCount >= _maxRetries) {
        _showErrorDialog(
          'Maximum retry attempts reached. Please try again later.',
        );
      } else {
        _showRetryDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing || widget.isLoading ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isProcessing || widget.isLoading
              ? Colors.grey
              : Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing || widget.isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Processing...'),
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
