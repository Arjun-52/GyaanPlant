/// Outcome of a `PaymentService.purchaseItem` call.
///
/// Sealed so callers must switch exhaustively — no boolean flags or magic
/// strings to interpret. Keeps `PaymentService` free of `BuildContext` and
/// any UI concerns.
sealed class PaymentResult {
  const PaymentResult();
}

/// Item was free — backend enrolled the user directly, no Razorpay flow.
class FreeEnrollmentSucceeded extends PaymentResult {
  final String itemId;
  const FreeEnrollmentSucceeded(this.itemId);
}

/// Razorpay checkout completed successfully. The caller must still verify
/// the payment with the backend (call `PaymentService.verifyPayment`).
class PaymentSucceeded extends PaymentResult {
  final String razorpayPaymentId;
  final String razorpayOrderId;
  const PaymentSucceeded({
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
  });
}

/// Payment failed before or during checkout. `reason` distinguishes between
/// pre-checkout failures (network/timeout/ssl/invalidOrder) and user-facing
/// payment failures from Razorpay (paymentDeclined/unknown).
class PaymentFailed extends PaymentResult {
  final PaymentFailureReason reason;
  final String message;
  const PaymentFailed({required this.reason, required this.message});
}

/// User selected an external wallet from the Razorpay sheet. Razorpay hands
/// off — there is no success/failure callback after this.
class ExternalWalletSelected extends PaymentResult {
  final String? walletName;
  const ExternalWalletSelected(this.walletName);
}

enum PaymentFailureReason {
  network,
  timeout,
  ssl,
  invalidOrder,
  paymentDeclined,
  unknown,
}
