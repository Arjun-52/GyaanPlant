import '../models/payment/item_type.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class FreeCourseException implements Exception {
  final String message;

  const FreeCourseException(this.message);

  @override
  String toString() => message;
}

class PaymentRepository {
  final NetworkAPIManager _api;

  PaymentRepository(this._api);

  ///  Create payment order for any item type
  Future<Map<String, dynamic>> createOrder({
    required String itemId,
    required ItemType itemType,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.createOrder,
      data: {'itemId': itemId, 'itemType': itemType.value},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    print("🧾 ORDER RESPONSE: ${response.data}");

    // Handle case where response.data might be null for error responses
    if (response.data == null) {
      // For 400 responses, the data might be in the error response
      // We'll return a special flag for free items
      print("⚠️ FREE COURSE DETECTED → DIRECT ENROLL");
      return {"isFree": true};
    }

    final responseData = response.data!;

    // Check if this is a free course
    if (responseData['success'] != true) {
      final message = responseData['message']?.toString().toLowerCase() ?? '';
      if (message.contains('free') || message.contains('enrol directly')) {
        print("⚠️ FREE COURSE DETECTED → DIRECT ENROLL");
        return {"isFree": true};
      }
      throw Exception('Failed to create order: $responseData');
    }

    if (responseData['data'] == null) {
      throw Exception('No order data received from server');
    }

    return responseData['data'] as Map<String, dynamic>;
  }

  /// Enroll in free item directly without payment
  Future<void> enrollFreeItem({
    required String itemId,
    required ItemType itemType,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/v1/learning/enroll', // Direct enrollment endpoint
        data: {'itemId': itemId, 'itemType': itemType.value},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      print("🎉 ENROLLED WITHOUT PAYMENT: ${response.data}");

      if (response.data == null || response.data!['success'] != true) {
        throw Exception('Failed to enroll in free item');
      }
    } catch (e) {
      print("❌ FREE ENROLLMENT FAILED: $e");
      throw Exception('Failed to enroll in free item: $e');
    }
  }

  /// Enroll in a course directly
  Future<void> enrollCourse({
    required String itemId,
    required ItemType itemType,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/v1/learning/$itemId/enroll', // Direct enrollment endpoint
        data: {'itemType': itemType.value},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      print("🎉 ENROLLMENT RESPONSE: ${response.data}");

      if (response.data == null || response.data!['success'] != true) {
        throw Exception('Failed to enroll in course');
      }
    } catch (e) {
      print("❌ ENROLLMENT FAILED: $e");

      // Handle "Already enrolled" case as success
      if (e.toString().contains("Already enrolled")) {
        print("✅ ALREADY ENROLLED - TREATING AS SUCCESS");
        return;
      }

      throw Exception('Failed to enroll in course: $e');
    }
  }

  ///  Verify payment after successful Razorpay transaction
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String itemId,
    required ItemType itemType,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.verifyPayment,
      data: {
        'razorpayPaymentId': razorpayPaymentId,
        'razorpayOrderId': razorpayOrderId,
        'itemId': itemId,
        'itemType': itemType.value,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    print("💳 PAYMENT VERIFICATION: ${response.data}");

    if (response.data == null) {
      throw Exception('No response data received from server');
    }

    final responseData = response.data!;
    if (responseData['success'] != true) {
      throw Exception('Payment verification failed: $responseData');
    }

    if (responseData['data'] == null) {
      throw Exception('No verification data received from server');
    }

    return responseData['data'] as Map<String, dynamic>;
  }

  ///  Get payment history for user
  Future<ApiResponse<List<Map<String, dynamic>>>> getPaymentHistory({
    int page = 1,
    int limit = 20,
  }) {
    return _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.paymentHistory,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;

        return list.map((e) => e as Map<String, dynamic>).toList();
      },
    );
  }
}
