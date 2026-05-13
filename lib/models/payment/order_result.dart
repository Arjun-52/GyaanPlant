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
class PaidOrder extends OrderResult {
  final String orderId;
  final int amount;

  const PaidOrder({required this.orderId, required this.amount});
}
