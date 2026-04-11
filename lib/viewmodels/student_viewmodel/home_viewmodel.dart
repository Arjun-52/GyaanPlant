import 'package:flutter/foundation.dart';
import '../../core/constants/app_strings.dart';

/// HomeViewModel manages the state and business logic for the HomeScreen.
/// This follows the MVVM pattern where the ViewModel handles all logic
/// and the UI (View) only displays the data and forwards user interactions.
class HomeViewModel extends ChangeNotifier {
  // Private state variables
  String _title = AppStrings.homeTitle;
  String _subtitle = AppStrings.homeSubtitle;
  bool _isLoading = false;
  String _errorMessage = '';
  int _counter = 0;

  // Public getters for the UI to access the state
  String get title => _title;
  String get subtitle => _subtitle;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get counter => _counter;

  /// Initializes the ViewModel
  /// This method can be called when the screen is first created
  void initialize() {
    if (kDebugMode) {
      print('HomeViewModel initialized');
    }
    // You can load initial data here
    loadData();
  }

  /// Loads data for the home screen
  /// This is an example of an async operation that the ViewModel would handle
  Future<void> loadData() async {
    setLoading(true);
    clearError();

    try {
      // Simulate a network call or data fetching
      await Future.delayed(const Duration(seconds: 1));

      // Update state with loaded data
      _title = AppStrings.homeTitle;
      _subtitle = '${AppStrings.homeSubtitle} - Data loaded successfully!';

      notifyListeners();
    } catch (e) {
      setError('Failed to load data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Increments the counter
  /// This is an example of a simple state mutation
  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  /// Decrements the counter
  void decrementCounter() {
    if (_counter > 0) {
      _counter--;
      notifyListeners();
    }
  }

  /// Resets the counter to zero
  void resetCounter() {
    _counter = 0;
    notifyListeners();
  }

  /// Refreshes the data
  Future<void> refresh() async {
    await loadData();
  }

  /// Sets the loading state
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Sets an error message
  void setError(String error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  /// Clears any existing error message
  void clearError() {
    if (_errorMessage.isNotEmpty) {
      _errorMessage = '';
      notifyListeners();
    }
  }

  /// Updates the title
  void updateTitle(String newTitle) {
    if (_title != newTitle) {
      _title = newTitle;
      notifyListeners();
    }
  }

  /// Updates the subtitle
  void updateSubtitle(String newSubtitle) {
    if (_subtitle != newSubtitle) {
      _subtitle = newSubtitle;
      notifyListeners();
    }
  }

  /// Performs a sample async operation
  Future<void> performAsyncOperation() async {
    setLoading(true);
    clearError();

    try {
      // Simulate an async operation (e.g., API call)
      await Future.delayed(const Duration(seconds: 2));

      // Update some state based on the operation result
      updateSubtitle('Async operation completed at ${DateTime.now()}');
    } catch (e) {
      setError('Async operation failed: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Cleanup method to dispose resources
  @override
  void dispose() {
    if (kDebugMode) {
      print('HomeViewModel disposed');
    }
    super.dispose();
  }
}
