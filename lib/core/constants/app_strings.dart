/// AppStrings contains all the string constants used throughout the application.
/// This centralizes string management and makes it easy to maintain text content
/// and supports future internationalization.
class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // App general
  static const String appName = 'GyaanPlant';
  static const String welcome = 'Welcome to GyaanPlant';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String ok = 'OK';

  // Navigation
  static const String home = 'Home';
  static const String secondScreen = 'Second Screen';
  static const String goToSecondScreen = 'Go to Second Screen';
  static const String backToHome = 'Back to Home';

  // Home screen
  static const String homeTitle = 'Home Screen';
  static const String homeSubtitle = 'Welcome to the MVVM Architecture Demo';
  static const String navigateButton = 'Navigate to Second Screen';

  // Second screen
  static const String secondScreenTitle = 'Second Screen';
  static const String secondScreenSubtitle = 'This is the second screen of the app';
  static const String backButton = 'Go Back';
}
