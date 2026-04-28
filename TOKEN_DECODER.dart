import 'dart:convert';

void decodeJWTToken(String token) {
  print("=== JWT TOKEN DECODER ===");
  
  try {
    // Remove "Bearer " prefix if present
    String cleanToken = token.startsWith('Bearer ') ? token.substring(7) : token;
    
    // Split token into parts
    final parts = cleanToken.split('.');
    if (parts.length != 3) {
      print("ERROR: Invalid JWT format - should have 3 parts, got ${parts.length}");
      return;
    }
    
    // Decode payload (middle part)
    String payload = parts[1];
    
    // Add padding if needed
    while (payload.length % 4 != 0) {
      payload += '=';
    }
    
    // Decode base64
    final decodedBytes = base64.decode(base64.normalize(payload));
    final decodedPayload = utf8.decode(decodedBytes);
    
    print("Token payload:");
    print(decodedPayload);
    
    // Parse JSON
    final payloadJson = json.decode(decodedPayload);
    
    print("\nParsed payload:");
    print("ID: ${payloadJson['id']}");
    print("Role: ${payloadJson['role']}");
    print("Token Version: ${payloadJson['tokenVersion']}");
    print("Issued At (iat): ${payloadJson['iat']}");
    print("Expires At (exp): ${payloadJson['exp']}");
    print("Issuer (iss): ${payloadJson['iss']}");
    
    // Check expiration
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = payloadJson['exp'] as int?;
    if (exp != null) {
      final isExpired = now > exp;
      print("Current time: $now");
      print("Expires at: $exp");
      print("Is expired: $isExpired");
      
      if (isExpired) {
        final expiredTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        print("Token expired on: $expiredTime");
      }
    }
    
    print("========================");
    
  } catch (e) {
    print("Error decoding token: $e");
    print("========================");
  }
}

// Your token from logs:
const testToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5ZDQ5NGU5NjAzODliMmE2ZDY3NzBkYyIsInJvbGUiOiJ0cG8iLCJ0b2tlblZlcnNpb24iOjAsImlhdCI6MTc3Njg1MTc1MiwiZXhwIjoxNzc3NDU2NTUyLCJpc3MiOiJneWFhbnBsYW50In0.CQhIuoI5HEqeakMH92gUtAdtiIzDuS-OVb-Ce1t1bOk";

void main() {
  decodeJWTToken(testToken);
}
