import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/payment/item_type.dart';
import '../services/payment_service.dart';

class PaymentButton extends StatefulWidget {
  final String itemId;
  final ItemType itemType;
  final String? itemName;
  final String? itemDescription;
  final String buttonText;
  final VoidCallback? onPaymentSuccess;
  final bool isEnabled;

  const PaymentButton({
    super.key,
    required this.itemId,
    required this.itemType,
    this.itemName,
    this.itemDescription,
    this.buttonText = 'Purchase',
    this.onPaymentSuccess,
    this.isEnabled = true,
  });

  @override
  State<PaymentButton> createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<PaymentButton> {
  late PaymentService _paymentService;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    _paymentService.init(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternal: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("💳 PAYMENT SUCCESS: ${response.paymentId}, ${response.orderId}");

    try {
      // Verify payment with backend - NO setState during verification
      final verification = await _paymentService.verifyPayment(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        itemId: widget.itemId,
        itemType: widget.itemType,
      );

      print("✅ PAYMENT VERIFIED: $verification");

      // NOW safe to update UI - AFTER payment completes
      if (mounted) {
        setState(() => _isProcessing = false);

        _showSuccessDialog(
          'Payment successful! Your ${widget.itemType.value} has been activated.',
        );

        // Call success callback
        widget.onPaymentSuccess?.call();
      }
    } catch (e) {
      print("❌ PAYMENT VERIFICATION FAILED: $e");
      setState(() => _isProcessing = false);
      if (mounted) {
        _showErrorDialog('Payment verification failed: $e');
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("❌ PAYMENT ERROR: ${response.code} - ${response.message}");
    setState(() => _isProcessing = false);
    _showErrorDialog('Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showInfoDialog('External wallet selected: ${response.walletName}');
  }

  void _showSuccessDialog(String message) {
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

  void _showErrorDialog(String message) {
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

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Info'),
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isProcessing || !widget.isEnabled) ? null : _startPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isEnabled
              ? const Color(0xFF00C853)
              : Colors.grey,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Processing...'),
                ],
              )
            : Text(
                widget.buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  void _startPayment() {
    if (_isProcessing) {
      print("⚠️ Payment already in progress");
      return;
    }

    print("🚀 START PAYMENT");
    setState(() => _isProcessing = true);

    _paymentService.purchaseItem(
      context: context,
      itemId: widget.itemId,
      itemType: widget.itemType,
      itemName: widget.itemName,
      itemDescription: widget.itemDescription,
    );
  }
}
