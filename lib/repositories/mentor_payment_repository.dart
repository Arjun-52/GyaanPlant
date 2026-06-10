import '../models/payment/item_type.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class MentorPaymentRepository {
  final NetworkAPIManager _api = NetworkAPIManager.instance;

  /// Create a mentor booking session on the backend
  Future<Map<String, dynamic>> createBooking({
    required String mentorId,
    required String topic,
    required String description,
    required DateTime date,
    required int duration,
  }) async {
    try {
      final endpoint = '/api/v1/mentor/$mentorId/book';
      final payload = {
        'topic': topic,
        'description': description,
        'date': date.toUtc().toIso8601String(),
        'duration': duration,
      };

      print("🧾 POSTing to booking endpoint $endpoint with payload: $payload");

      final response = await _api.post<Map<String, dynamic>>(
        endpoint,
        data: payload,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      print("🧾 BOOKING CREATION RESPONSE: ${response.data}");

      if (response.data == null) {
        throw Exception('Failed to create mentor booking: No response data');
      }

      return response.data!;
    } catch (e) {
      print("❌ BOOKING CREATION FAILED: $e");
      throw Exception('Failed to create mentor booking: $e');
    }
  }

  /// Create mentor booking order
  Future<Map<String, dynamic>> createMentorBookingOrder({
    required String sessionId,
  }) async {
    try {
      final endpoint = '/api/v1/payments/create-order';
      final payload = {
        'itemId': sessionId,
        'itemType': ItemType.session.value,
      };

      print("🧾 POSTing to $endpoint with payload: $payload");

      final response = await _api.post<Map<String, dynamic>>(
        endpoint,
        data: payload,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      print("🧾 MENTOR BOOKING ORDER CREATION RESPONSE: ${response.data}");

      if (response.data == null) {
        throw Exception(
          'Failed to create mentor booking order: No response data',
        );
      }

      return response.data!;
    } catch (e) {
      print("❌ MENTOR BOOKING ORDER CREATION FAILED: $e");
      throw Exception('Failed to create mentor booking order: $e');
    }
  }

  /// Verify mentor booking payment
  Future<Map<String, dynamic>> verifyMentorBookingPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    try {
      final endpoint = '/api/v1/payments/verify';
      final payload = {
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_signature': razorpaySignature,
      };

      print("🔍 POSTing verification to $endpoint with payload: $payload");

      final response = await _api.post<Map<String, dynamic>>(
        endpoint,
        data: payload,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      print("🔍 MENTOR BOOKING PAYMENT VERIFIED: ${response.data}");

      if (response.data == null || response.data!['success'] != true) {
        throw Exception('Mentor booking payment verification failed');
      }

      return response.data!;
    } catch (e) {
      print("❌ MENTOR BOOKING PAYMENT VERIFICATION FAILED: $e");
      throw Exception('Mentor booking payment verification failed: $e');
    }
  }

  /// Get mentor booking details
  Future<Map<String, dynamic>> getMentorBookingDetails({
    required String bookingId,
  }) async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        '/api/v1/mentor/booking/$bookingId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      print("📋 MENTOR BOOKING DETAILS: ${response.data}");

      if (response.data == null) {
        throw Exception('Failed to get mentor booking details');
      }

      return response.data!;
    } catch (e) {
      print("❌ FAILED TO GET MENTOR BOOKING DETAILS: $e");
      throw Exception('Failed to get mentor booking details: $e');
    }
  }

  /// Cancel mentor booking
  Future<Map<String, dynamic>> cancelMentorBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/v1/mentor/booking/$bookingId/cancel',
        data: {'reason': reason},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      print("❌ MENTOR BOOKING CANCELLED: ${response.data}");

      if (response.data == null || response.data!['success'] != true) {
        throw Exception('Failed to cancel mentor booking');
      }

      return response.data!;
    } catch (e) {
      print("❌ FAILED TO CANCEL MENTOR BOOKING: $e");
      throw Exception('Failed to cancel mentor booking: $e');
    }
  }
}
