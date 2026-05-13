import 'dart:async';
import 'dart:io';

import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../config/payment_config.dart';
import '../data/services/api_service.dart';
import '../models/auth/auth_user_model.dart';
import '../models/payment/item_type.dart';
import '../models/payment/order_result.dart';
import '../models/payment/payment_result.dart';

/// Payment orchestration on top of Razorpay.
///
/// The service is UI-free — `purchaseItem` returns a `Future<PaymentResult>`
/// and the caller renders dialogs/snackbars based on the sealed variant.
///
/// Razorpay only allows one checkout sheet to be open at a time, so a single
/// in-flight `Completer` is sufficient.
class PaymentService {
  static const _tag = 'PaymentService';

  late Razorpay _razorpay;
  final ApiService _apiService = ApiService();
  Timer? _paymentTimer;
  bool _isInitialized = false;

  // Completes when the current Razorpay checkout produces a success/error/
  // external-wallet event. Null when no checkout is in flight.
  Completer<PaymentResult>? _pending;

  void init() {
    if (_isInitialized) return;

    // Fails loudly if RAZORPAY_KEY wasn't supplied at build time.
    PaymentConfig.ensureConfigured();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _isInitialized = true;
    AppLogger.info(
      _tag,
      'Razorpay initialized (${PaymentConfig.isProduction ? "live" : "test"} mode)',
    );
  }

  /// Create an order and (if paid) open Razorpay checkout.
  ///
  /// Returns when one of:
  ///   - Free item: backend enrollment finishes.
  ///   - Paid item: Razorpay reports success / error / external-wallet.
  ///   - Pre-checkout failure: returns a `PaymentFailed`.
  Future<PaymentResult> purchaseItem({
    required String itemId,
    required ItemType itemType,
    String? itemDescription,
    AuthUser? user,
  }) async {
    if (!_isInitialized) {
      throw StateError('PaymentService not initialized. Call init() first.');
    }
    if (_pending != null) {
      return const PaymentFailed(
        reason: PaymentFailureReason.unknown,
        message: 'A payment is already in progress.',
      );
    }

    AppLogger.info(_tag, 'Starting payment for ${itemType.value}: $itemId');
    _startPaymentTimeout();

    final OrderResult order;
    try {
      order = await _apiService.payment.createOrder(
        itemId: itemId,
        itemType: itemType,
      );
    } on SocketException catch (e) {
      _cancelPaymentTimeout();
      AppLogger.error(_tag, 'Network error during createOrder', e);
      return const PaymentFailed(
        reason: PaymentFailureReason.network,
        message: 'Network error. Please check your internet connection.',
      );
    } on TimeoutException catch (e) {
      _cancelPaymentTimeout();
      AppLogger.error(_tag, 'Timeout during createOrder', e);
      return const PaymentFailed(
        reason: PaymentFailureReason.timeout,
        message: 'Payment request timed out. Please try again.',
      );
    } on HandshakeException catch (e) {
      _cancelPaymentTimeout();
      AppLogger.error(_tag, 'SSL handshake during createOrder', e);
      return const PaymentFailed(
        reason: PaymentFailureReason.ssl,
        message: 'Secure connection failed. Check network settings.',
      );
    } catch (e, st) {
      _cancelPaymentTimeout();
      AppLogger.error(_tag, 'createOrder failed', e, st);
      return PaymentFailed(
        reason: PaymentFailureReason.invalidOrder,
        message: 'Failed to create payment order: $e',
      );
    }

    switch (order) {
      case FreeItemOrder():
        _cancelPaymentTimeout();
        try {
          await _apiService.payment.enrollFreeItem(
            itemId: itemId,
            itemType: itemType,
          );
          AppLogger.info(_tag, 'Free enrollment success: $itemId');
          return FreeEnrollmentSucceeded(itemId);
        } catch (e, st) {
          AppLogger.error(_tag, 'Free enrollment failed', e, st);
          return PaymentFailed(
            reason: PaymentFailureReason.unknown,
            message: 'Failed to enroll in free item: $e',
          );
        }

      case PaidOrder(orderId: final orderId, amount: final amount):
        AppLogger.info(_tag, 'Opening Razorpay for order $orderId');
        final completer = Completer<PaymentResult>();
        _pending = completer;

        final options = <String, dynamic>{
          'key': PaymentConfig.razorpayKey,
          'order_id': orderId,
          'amount': amount,
          'name': 'GyaanPlant',
          'description': itemDescription ?? PaymentConfig.defaultDescription,
          'theme': {'color': PaymentConfig.themeColor},
        };
        final prefill = <String, String>{};
        if (user?.email != null) prefill['email'] = user!.email;
        if (user?.name != null) prefill['name'] = user!.name;
        if (prefill.isNotEmpty) options['prefill'] = prefill;

        try {
          _razorpay.open(options);
        } catch (e, st) {
          _cancelPaymentTimeout();
          _pending = null;
          AppLogger.error(_tag, 'Razorpay.open failed', e, st);
          return PaymentFailed(
            reason: PaymentFailureReason.unknown,
            message: 'Failed to open payment sheet: $e',
          );
        }

        return completer.future;
    }
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String itemId,
    required ItemType itemType,
  }) {
    return _apiService.payment.verifyPayment(
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      itemId: itemId,
      itemType: itemType,
    );
  }

  void dispose() {
    _cancelPaymentTimeout();
    if (_isInitialized) {
      _razorpay.clear();
      _isInitialized = false;
      AppLogger.info(_tag, 'Razorpay disposed');
    }
    // Don't leave a pending future hanging if the widget tears down mid-flow.
    if (_pending?.isCompleted == false) {
      _pending!.complete(
        const PaymentFailed(
          reason: PaymentFailureReason.unknown,
          message: 'Payment cancelled (widget disposed).',
        ),
      );
    }
    _pending = null;
  }

  // ── Razorpay event handlers ────────────────────────────────────────────

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _cancelPaymentTimeout();
    AppLogger.info(_tag, 'Payment success: ${response.paymentId}');
    _completePending(
      PaymentSucceeded(
        razorpayPaymentId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? '',
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _cancelPaymentTimeout();
    final raw = response.message ?? '';
    final lower = raw.toLowerCase();
    AppLogger.error(_tag, 'Payment error: ${response.code} - $raw');

    final reason = lower.contains('certificate') ||
            lower.contains('ssl') ||
            lower.contains('handshake')
        ? PaymentFailureReason.ssl
        : PaymentFailureReason.paymentDeclined;

    _completePending(
      PaymentFailed(reason: reason, message: raw.isEmpty ? 'Payment failed' : raw),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _cancelPaymentTimeout();
    AppLogger.info(_tag, 'External wallet selected: ${response.walletName}');
    _completePending(ExternalWalletSelected(response.walletName));
  }

  void _completePending(PaymentResult result) {
    final c = _pending;
    _pending = null;
    if (c != null && !c.isCompleted) c.complete(result);
  }

  // ── Timeout helpers ────────────────────────────────────────────────────

  void _startPaymentTimeout() {
    _cancelPaymentTimeout();
    _paymentTimer = Timer(PaymentConfig.paymentTimeout, () {
      AppLogger.warning(_tag, 'Payment timeout reached');
      _completePending(
        const PaymentFailed(
          reason: PaymentFailureReason.timeout,
          message: 'Payment timed out.',
        ),
      );
    });
  }

  void _cancelPaymentTimeout() {
    _paymentTimer?.cancel();
    _paymentTimer = null;
  }
}
