import 'dart:convert';
import 'package:http/http.dart' as http;

/// Test API endpoints and credentials
/// Run this to debug login issues

class LoginTestHelper {
  static const String baseUrl = 'https://backend.gyaanplant.com';
  
  /// Test registration with new TPO user
  static Future<void> testRegistration() async {
    print("=== TESTING REGISTRATION ===");
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': 'Test TPO User',
          'email': 'testtpo@gyaanplant.com',
          'password': 'tpo123456',
          'role': 'tpo',
        }),
      ).timeout(Duration(seconds: 10));

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Registration successful!');
      } else {
        print('❌ Registration failed');
      }
    } catch (e) {
      print('❌ Registration error: $e');
    }
    print('========================');
  }
  
  /// Test login with various credentials
  static Future<void> testLoginCredentials() async {
    print("=== TESTING LOGIN CREDENTIALS ===");
    
    // Test credentials to try
    final testCredentials = [
      {
        'email': 'testtpo@gyaanplant.com',
        'password': 'tpo123456',
        'desc': 'New test TPO user'
      },
      {
        'email': 'surya@mailinator.com',
        'password': 'password123',
        'desc': 'Existing TPO from seed'
      },
      {
        'email': 'surya@mailinator.com',
        'password': 'surya123',
        'desc': 'TPO with common password'
      },
      {
        'email': 'tpo@gyaanplant.com',
        'password': 'tpo123',
        'desc': 'Generic TPO account'
      },
    ];
    
    for (final creds in testCredentials) {
      print("\n--- Testing: ${creds['desc']} ---");
      print("Email: ${creds['email']}");
      print("Password: ${creds['password']}");
      
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/v1/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': creds['email'],
            'password': creds['password'],
          }),
        ).timeout(Duration(seconds: 10));

        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');
        
        if (response.statusCode == 200) {
          print('✅ LOGIN SUCCESSFUL!');
          final data = jsonDecode(response.body);
          print('Token: ${data['accessToken']?.substring(0, 50)}...');
          print('User role: ${data['user']?['role']}');
        } else {
          print('❌ Login failed');
        }
      } catch (e) {
        print('❌ Login error: $e');
      }
    }
    print('==============================');
  }
  
  /// Test protected API endpoints
  static Future<void> testProtectedEndpoints(String token) async {
    print("=== TESTING PROTECTED ENDPOINTS ===");
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    
    // Test student endpoint
    try {
      print("\n--- Testing /api/v1/student ---");
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/student'),
        headers: headers,
      ).timeout(Duration(seconds: 10));
      
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
    } catch (e) {
      print('❌ Student endpoint error: $e');
    }
    
    // Test drive endpoint
    try {
      print("\n--- Testing /api/v1/drive ---");
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/drive'),
        headers: headers,
      ).timeout(Duration(seconds: 10));
      
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
    } catch (e) {
      print('❌ Drive endpoint error: $e');
    }
    
    print('==============================');
  }
  
  /// Run all tests
  static Future<void> runAllTests() async {
    await testRegistration();
    await testLoginCredentials();
    
    // If you get a successful login, copy the token and test endpoints
    print('\n🔑 If you get a successful login above, copy the token and run:');
    print('LoginTestHelper.testProtectedEndpoints("YOUR_TOKEN_HERE");');
  }
}

void main() {
  LoginTestHelper.runAllTests();
}
