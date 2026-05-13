/// Payment configuration for Razorpay integration.
///
/// The Razorpay key MUST be supplied at build time via:
///   flutter run --dart-define=RAZORPAY_KEY=rzp_test_xxx
///   flutter build apk --dart-define=RAZORPAY_KEY=rzp_live_xxx
///
/// No default is provided so that a missing build flag cannot silently leak
/// a test key into a release build.
class PaymentConfig {
  PaymentConfig._();

  static const String razorpayKey = String.fromEnvironment('RAZORPAY_KEY');

  static const Duration paymentTimeout = Duration(minutes: 2);
  static const String themeColor = '#00C853';
  static const String defaultDescription = 'Purchase on GyaanPlant';

  static bool get isProduction => razorpayKey.startsWith('rzp_live_');
  static bool get isTestMode => razorpayKey.startsWith('rzp_test_');

  /// Throws a [StateError] when the key is missing or malformed.
  /// Call this once during PaymentService.init() to fail loudly.
  static void ensureConfigured() {
    if (razorpayKey.isEmpty) {
      throw StateError(
        'RAZORPAY_KEY is not set. Pass it at build time: '
        '--dart-define=RAZORPAY_KEY=rzp_<test|live>_xxx',
      );
    }
    if (!isProduction && !isTestMode) {
      throw StateError(
        'RAZORPAY_KEY must start with "rzp_test_" or "rzp_live_". '
        'Got: "$razorpayKey"',
      );
    }
  }
}
