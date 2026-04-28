import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5ZTliMmU5YjcwODY2ZDFhMjIxY2E5ZSIsInJvbGUiOiJ0cG8iLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3NjkyMzM3MCwiZXhwIjoxNzc3NTI4MTcwLCJpc3MiOiJneWFhbnBsYW50In0.W2jw3XtksLM9dPVswsbNS2k_8JzZJXUKiAM-ARQYm8o";
  const String baseUrl = 'https://backend.gyaanplant.in';
  
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  
  print("=== TESTING PROTECTED ENDPOINTS ===");
  
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
  
  // Test TPO students endpoint
  try {
    print("\n--- Testing /api/v1/tpo/students ---");
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/tpo/students'),
      headers: headers,
    ).timeout(Duration(seconds: 10));
    
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('❌ TPO students endpoint error: $e');
  }
  
  print('==============================');
}
