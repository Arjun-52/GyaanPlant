class AppConfig {
  AppConfig._();

  /// Override at build time: flutter run --dart-define=BASE_URL=https://api.example.com
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  static const Duration httpTimeout = Duration(seconds: 15);
}
