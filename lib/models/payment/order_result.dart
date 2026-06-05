/// Outcome of `PaymentRepository.createOrder`.
///
/// A sealed union so callers must handle both cases via exhaustive `switch`
/// rather than poking at untyped map keys like `order['orderId']` vs
/// `order['isFree']`.
sealed class OrderResult {
  const OrderResult();
}

/// Backend reported the item is free — no payment required, enroll directly.
class FreeItemOrder extends OrderResult {
  const FreeItemOrder();
}

/// Backend created a paid Razorpay order ready to be opened in checkout.
///
/// `orderId` is the Razorpay-side order id (`order_...`), `amount` is in
/// paise (the smallest currency unit, what the Razorpay SDK expects), and
/// `keyId` is the Razorpay public key the backend wants the client to use
/// for this transaction. Shipping the key per-order means the backend
/// controls test/live mode and can rotate keys without an app release.
class PaidOrder extends OrderResult {
  final String orderId;
  final int amount;
  final String keyId;

  const PaidOrder({
    required this.orderId,
    required this.amount,
    required this.keyId,
  });
}
