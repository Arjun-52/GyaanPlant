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

    // Razorpay-side id (`order_...`) is what the SDK and the verify endpoint
    // expect. Fall back to `orderId` only for older response shapes.
    final orderId = (data['razorpayOrderId'] ?? data['orderId']) as String?;
    // SDK expects amount in paise. Prefer `amountInPaise`; fall back to
    // `amount × 100` if the backend only sent rupees.
    final paise = data['amountInPaise'] as int?;
    final rupees = data['amount'] as int?;
    final amount = paise ?? (rupees != null ? rupees * 100 : null);
    // Per-order Razorpay public key — backend controls test/live and can
    // rotate without an app release.
    final keyId = data['keyId'] as String?;

    if (orderId == null || amount == null || keyId == null) {
      throw Exception(
        'Invalid order response: missing one of razorpayOrderId / '
        'amountInPaise / keyId',
      );
    }

    return PaidOrder(orderId: orderId, amount: amount, keyId: keyId);
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
    } catch (e) {
      if (e.toString().contains('Already enrolled')) return;
      rethrow;
    }
  }

  /// Verify a Razorpay payment with the backend.
  ///
  /// Field names match the backend contract exactly (snake_case). The
  /// signature is mandatory — the backend HMAC-verifies the success callback
  /// using it, so a missing/wrong signature → 400.
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.verifyPayment,
      data: {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
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
