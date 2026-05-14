import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../models/payment/item_type.dart';
import '../models/payment/payment_result.dart';
import '../services/payment_service.dart';
import '../viewmodels/student_viewmodel/auth_viewmodel.dart';

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
  static const _tag = 'PaymentButton';

  late final PaymentService _paymentService;
  bool _isProcessing = false;

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

  Future<void> _startPayment() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final result = await _paymentService.purchaseItem(
      itemId: widget.itemId,
      itemType: widget.itemType,
      itemDescription: widget.itemDescription,
      user: context.read<AuthViewModel>().user,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result) {
      case FreeEnrollmentSucceeded():
        _showDialog(
          'Success',
          'Free ${widget.itemType.value} enrolled successfully!',
        );
        widget.onPaymentSuccess?.call();
      case PaymentSucceeded(
          razorpayPaymentId: final pid,
          razorpayOrderId: final oid,
          razorpaySignature: final sig,
        ):
        await _verifyAndAnnounce(pid, oid, sig);
      case PaymentFailed(message: final msg):
        _showDialog('Payment Error', msg);
      case ExternalWalletSelected(walletName: final wallet):
        _showDialog('Info', 'External wallet selected: ${wallet ?? "unknown"}');
    }
  }

  Future<void> _verifyAndAnnounce(
    String paymentId,
    String orderId,
    String signature,
  ) async {
    try {
      final verification = await _paymentService.verifyPayment(
        razorpayPaymentId: paymentId,
        razorpayOrderId: orderId,
        razorpaySignature: signature,
      );
      AppLogger.info(_tag, 'Payment verified: ${verification.keys}');
      if (!mounted) return;
      _showDialog(
        'Success',
        'Payment successful! Your ${widget.itemType.value} has been activated.',
      );
      widget.onPaymentSuccess?.call();
    } catch (e, st) {
      AppLogger.error(_tag, 'Verification failed', e, st);
      if (!mounted) return;
      _showDialog('Payment Error', 'Payment verification failed: $e');
    }
  }

  void _showDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isProcessing || !widget.isEnabled) ? null : _startPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              widget.isEnabled ? const Color(0xFF00C853) : Colors.grey,
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }
}
