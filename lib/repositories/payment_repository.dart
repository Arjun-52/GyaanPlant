import 'package:gyaanplant/core/utils/app_logger.dart';
import '../models/payment/item_type.dart';
import '../models/payment/order_result.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class PaymentRepository {
  static const _tag = 'PaymentRepository';

  final NetworkAPIManager _api;

  PaymentRepository(this._api);

  Future<OrderResult> createOrder({
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
      return const FreeItemOrder();
    }

    final responseData = response.data!;

    if (responseData['success'] != true) {
      final message = responseData['message']?.toString().toLowerCase() ?? '';
      if (message.contains('free') || message.contains('enrol directly')) {
        return const FreeItemOrder();
      }
      throw Exception('Failed to create order: $responseData');
    }

    final data = responseData['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('No order data received from server');
    }

    final orderId = (data['orderId'] ?? data['razorpayOrderId']) as String?;
    final amount = (data['amount'] ?? data['amountInPaise']) as int?;
    if (orderId == null || amount == null) {
      throw Exception('Invalid order response: missing orderId or amount');
    }

    return PaidOrder(orderId: orderId, amount: amount);
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
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/learning/$itemId/enroll',
      data: {'itemType': itemType.value},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data?['success'] == true) {
      AppLogger.info(_tag, 'Course enrollment success: $itemId');
      return;
    }

    // Idempotent: already-enrolled is treated as success.
    // Prefer the structured error code; fall back to substring match so this
    // works whether or not the backend has shipped the ALREADY_ENROLLED code.
    final errCode = response.error?.code;
    final errMsg = response.error?.message.toLowerCase() ?? '';
    if (errCode == 'ALREADY_ENROLLED' || errMsg.contains('already enrolled')) {
      AppLogger.info(_tag, 'Course already enrolled (idempotent): $itemId');
      return;
    }

    throw Exception('Failed to enroll in course: ${response.error?.message}');
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
