// Add this method to your StudentViewModel to test token storage
// You can call this from a button or in initState for debugging

import 'package:gyaanplant/data/services/local_storage_service.dart';

Future<void> debugTokenStorage() async {
  print("=== TOKEN STORAGE DEBUG ===");

  try {
    // Test LocalStorageService methods
    final token = await LocalStorageService.getToken();
    print("LocalStorageService.getToken() result: $token");
    print("Token type: ${token.runtimeType}");

    // Test if we can save and retrieve
    const testToken = "test_token_12345";
    await LocalStorageService.saveToken(testToken);
    final retrievedToken = await LocalStorageService.getToken();
    print("Test token retrieval: $retrievedToken");

    // Restore original token if it existed
    if (token != null) {
      await LocalStorageService.saveToken(token);
    } else {
      await LocalStorageService.clearToken();
    }

    print("Token storage working: ${retrievedToken == testToken}");
    print("========================");
  } catch (e) {
    print("Error in token storage test: $e");
    print("========================");
  }
}

// Add this to your StudentScreen for a quick test:
// ElevatedButton(
//   onPressed: () => viewModel.debugTokenStorage(),
//   child: Text("Test Token Storage"),
// ),
