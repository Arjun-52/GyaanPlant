import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/payment/item_type.dart';
import '../services/payment_service.dart';
import '../viewmodels/student_viewmodel/learning_viewmodel.dart';

/// A reusable payment button that initiates the Razorpay checkout flow.
///
/// Uses [PaymentService] to create an order via the backend and open checkout.
/// Calls [onPaymentSuccess] after successful payment + backend verification.
class PaymentButton extends StatefulWidget {
  final String itemId;
  final ItemType itemType;
  final String? itemDescription;
  final String buttonText;
  final VoidCallback? onPaymentSuccess;
  final bool isEnabled;

  const PaymentButton({
    super.key,
    required this.itemId,
    required this.itemType,
    this.itemDescription,
    this.buttonText = 'Purchase',
    this.onPaymentSuccess,
    this.isEnabled = true,
  });

  @override
  State<PaymentButton> createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<PaymentButton> {
  late final PaymentService _paymentService;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    _paymentService.initialize(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  // ─── Razorpay Callbacks ───────────────────────────────────────────────────

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('💳 PaymentButton: Payment SUCCESS — ${response.paymentId}');

    try {
      await _paymentService.verifyPayment(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        itemId: widget.itemId,
        itemType: widget.itemType,
      );

      debugPrint('✅ PaymentButton: Payment verified');

      if (mounted) {
        setState(() => _isProcessing = false);

        // Refresh courses if applicable
        if (widget.itemType == ItemType.course) {
          await context.read<LearningViewModel>().fetchCourses();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment successful! Your ${widget.itemType.value} has been activated.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        widget.onPaymentSuccess?.call();
      }
    } catch (e) {
      debugPrint('❌ PaymentButton: Verification failed — $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verification failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint(
      '❌ PaymentButton: Payment ERROR — ${response.code}: ${response.message}',
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('👛 PaymentButton: External wallet — ${response.walletName}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet selected: ${response.walletName}'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  // ─── Payment Trigger ─────────────────────────────────────────────────────

  Future<void> _startPayment() async {
    if (_isProcessing || !widget.isEnabled) return;

    setState(() => _isProcessing = true);

    await _paymentService.createOrderAndOpenCheckout(
      context: context,
      itemId: widget.itemId,
      itemType: widget.itemType,
      itemDescription:
          widget.itemDescription ?? 'Purchase ${widget.itemType.value}',
    );

    // Reset if checkout failed to open
    if (mounted && _isProcessing) {
      setState(() => _isProcessing = false);
    }
  }

  // ─── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool disabled = _isProcessing || !widget.isEnabled;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: disabled ? null : _startPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? Colors.grey : const Color(0xFF00C853),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.black),
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
}
