/// Payment configuration for Razorpay integration
/// Supports environment-based configuration for production deployment
class PaymentConfig {
  // Private constructor to prevent instantiation
  PaymentConfig._();

  /// Razorpay API key from environment or test key as fallback
  /// Usage: flutter run --dart-define=RAZORPAY_KEY=your_live_key
  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: 'rzp_test_SgTgIrRTm5fJjb',
  );

  /// Payment timeout duration (2 minutes)
  static const Duration paymentTimeout = Duration(minutes: 2);

  /// Default payment theme color
  static const String themeColor = '#00C853';

  /// Default payment description
  static const String defaultDescription = 'Purchase on GyaanPlant';

  /// Check if running in production mode
  static bool get isProduction => razorpayKey.contains('rzp_live_');

  /// Check if running in test mode
  static bool get isTestMode => razorpayKey.contains('rzp_test_');
}
