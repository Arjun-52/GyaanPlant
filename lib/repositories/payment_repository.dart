import 'package:gyaanplant/core/utils/app_logger.dart';
import '../models/payment/item_type.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class PaymentRepository {
  static const _tag = 'PaymentRepository';

  final NetworkAPIManager _api;

  PaymentRepository(this._api);

  Future<Map<String, dynamic>> createOrder({
    required String itemId,
    required ItemType itemType,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.createOrder,
      data: {'itemId': itemId, 'itemType': itemType.value},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.data == null) {
      AppLogger.warning(_tag, 'createOrder: null response — treating as free');
      return {'isFree': true};
    }

    final responseData = response.data!;

    if (responseData['success'] != true) {
      final message = responseData['message']?.toString().toLowerCase() ?? '';
      if (message.contains('free') || message.contains('enrol directly')) {
        return {'isFree': true};
      }
      throw Exception('Failed to create order: $responseData');
    }

    if (responseData['data'] == null) {
      throw Exception('No order data received from server');
    }

    return responseData['data'] as Map<String, dynamic>;
  }

  Future<void> enrollFreeItem({
    required String itemId,
    required ItemType itemType,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/learning/enroll',
      data: {'itemId': itemId, 'itemType': itemType.value},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.data == null || response.data!['success'] != true) {
      throw Exception('Failed to enroll in free item');
    }
    AppLogger.info(_tag, 'Free enrollment success: $itemId');
  }

  Future<void> enrollCourse({
    required String itemId,
    required ItemType itemType,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/v1/learning/$itemId/enroll',
        data: {'itemType': itemType.value},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.data == null || response.data!['success'] != true) {
        throw Exception('Failed to enroll in course');
      }
      AppLogger.info(_tag, 'Course enrollment success: $itemId');
    } catch (e) {
      if (e.toString().contains('Already enrolled')) return;
      rethrow;
    }
  }

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

    if (response.data == null) throw Exception('No response from server');

    final responseData = response.data!;
    if (responseData['success'] != true) {
      throw Exception('Payment verification failed: $responseData');
    }
    if (responseData['data'] == null) {
      throw Exception('No verification data received');
    }

    AppLogger.info(_tag, 'Payment verified: $razorpayPaymentId');
    return responseData['data'] as Map<String, dynamic>;
  }

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
