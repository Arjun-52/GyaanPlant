/// UI-side defaults for the Razorpay checkout sheet.
///
/// The Razorpay public key is no longer kept here — the backend supplies it
/// per-order on `/api/v1/payments/create-order` (see `PaidOrder.keyId`), so
/// test/live mode and key rotation are controlled server-side.
class PaymentConfig {
  PaymentConfig._();

  static const Duration paymentTimeout = Duration(minutes: 2);
  static const String themeColor = '#00C853';
  static const String defaultDescription = 'Purchase on GyaanPlant';
}
