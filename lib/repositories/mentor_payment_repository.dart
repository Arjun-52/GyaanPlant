import '../models/payment/item_type.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class MentorPaymentRepository {
  final NetworkAPIManager _api = NetworkAPIManager.instance;

  /// Create mentor booking order
  Future<Map<String, dynamic>> createMentorBookingOrder({
    required String mentorId,
    required DateTime selectedDate,
    required String selectedTime,
    required String selectedDuration,
    required double totalAmount,
    required Map<String, dynamic> bookingDetails,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/v1/mentor/booking/create-order',
        data: {
          'mentorId': mentorId,
          'selectedDate': selectedDate.toIso8601String(),
          'selectedTime': selectedTime,
          'selectedDuration': selectedDuration,
          'totalAmount': totalAmount,
          'bookingDetails': bookingDetails,
          'itemType': ItemType.session.value,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      print("🧾 MENTOR BOOKING ORDER CREATED: ${response.data}");

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
    required String mentorId,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/v1/mentor/booking/verify-payment',
        data: {
          'razorpayPaymentId': razorpayPaymentId,
          'razorpayOrderId': razorpayOrderId,
          'mentorId': mentorId,
        },
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

  /// Confirm mentor session booking
  Future<Map<String, dynamic>> confirmMentorBooking({
    required String mentorId,
    required DateTime selectedDate,
    required String selectedTime,
    required String selectedDuration,
    required String razorpayPaymentId,
    required String razorpayOrderId,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/v1/mentor/booking/confirm',
        data: {
          'mentorId': mentorId,
          'selectedDate': selectedDate.toIso8601String(),
          'selectedTime': selectedTime,
          'selectedDuration': selectedDuration,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpayOrderId': razorpayOrderId,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      print("✅ MENTOR BOOKING CONFIRMED: ${response.data}");

      if (response.data == null || response.data!['success'] != true) {
        throw Exception('Failed to confirm mentor booking');
      }

      return response.data!;
    } catch (e) {
      print("❌ MENTOR BOOKING CONFIRMATION FAILED: $e");
      throw Exception('Failed to confirm mentor booking: $e');
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
