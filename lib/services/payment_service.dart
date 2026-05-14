import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../data/services/api_service.dart';
import '../models/payment/item_type.dart';

/// Callback types for Razorpay events
typedef PaymentSuccessCallback = Future<void> Function(
  PaymentSuccessResponse response,
);
typedef PaymentErrorCallback = void Function(PaymentFailureResponse response);
typedef ExternalWalletCallback = void Function(ExternalWalletResponse response);

/// Clean, production-ready PaymentService.
/// Initializes Razorpay, creates orders via backend, and opens checkout
/// using values returned by the API (including keyId).
class PaymentService {
  Razorpay? _razorpay;
  final ApiService _apiService = ApiService();

  bool _isInitialized = false;

  PaymentSuccessCallback? _onSuccess;
  PaymentErrorCallback? _onError;
  ExternalWalletCallback? _onExternalWallet;

  // ─── Initialization ───────────────────────────────────────────────────────

  /// Initialize Razorpay with the three required event callbacks.
  /// Must be called before [openCheckout].
  void initialize({
    required PaymentSuccessCallback onSuccess,
    required PaymentErrorCallback onError,
    required ExternalWalletCallback onExternalWallet,
  }) {
    if (_isInitialized) {
      dispose(); // dispose any previous instance cleanly before re-init
    }

    _onSuccess = onSuccess;
    _onError = onError;
    _onExternalWallet = onExternalWallet;

    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _isInitialized = true;
    debugPrint('✅ PaymentService: Razorpay initialized');
  }

  // ─── Internal Razorpay Listeners ─────────────────────────────────────────

  void _handleSuccess(PaymentSuccessResponse response) {
    debugPrint('💳 PaymentService: Payment SUCCESS — ${response.paymentId}');
    _onSuccess?.call(response);
  }

  void _handleError(PaymentFailureResponse response) {
    debugPrint(
      '❌ PaymentService: Payment ERROR — ${response.code}: ${response.message}',
    );
    _onError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint(
      '👛 PaymentService: External Wallet — ${response.walletName}',
    );
    _onExternalWallet?.call(response);
  }

  // ─── Order Creation & Checkout ────────────────────────────────────────────

  /// Creates a payment order via the backend and opens Razorpay checkout.
  ///
  /// Backend endpoint: POST /api/v1/payments/create-order
  /// The [keyId], [razorpayOrderId], [amountInPaise], and [prefill] are all
  /// sourced exclusively from the backend response — no hardcoded keys.
  ///
  /// [itemId]          - The ID of the item to purchase (course, session, etc.)
  /// [itemType]        - The type of item ([ItemType])
  /// [itemDescription] - Optional human-readable description shown in checkout
  Future<void> createOrderAndOpenCheckout({
    required BuildContext context,
    required String itemId,
    required ItemType itemType,
    String itemDescription = 'Purchase on GyaanPlant',
  }) async {
    if (!_isInitialized || _razorpay == null) {
      debugPrint('❌ PaymentService not initialized. Call initialize() first.');
      _showError(context, 'Payment service not ready. Please try again.');
      return;
    }

    try {
      debugPrint(
        '🚀 PaymentService: Creating order — itemId=$itemId, type=${itemType.value}',
      );

      // ── Step 1: Create order via backend ──────────────────────────────
      final orderData = await _apiService.payment.createOrder(
        itemId: itemId,
        itemType: itemType,
      );

      debugPrint('🧾 PaymentService: Order data received — $orderData');

      // ── Step 2: Handle free items ─────────────────────────────────────
      if (orderData['isFree'] == true) {
        debugPrint('🎁 PaymentService: Free item — enrolling directly');
        await _apiService.payment.enrollFreeItem(
          itemId: itemId,
          itemType: itemType,
        );
        if (context.mounted) {
          _showSuccess(context, 'Enrolled successfully (free item)!');
        }
        return;
      }

      // ── Step 3: Extract required fields from backend response ─────────
      final String? keyId = orderData['keyId']?.toString();
      final String? razorpayOrderId = orderData['razorpayOrderId']?.toString();
      final int? amountInPaise = orderData['amountInPaise'] as int?;

      if (keyId == null || razorpayOrderId == null || amountInPaise == null) {
        throw Exception(
          'Invalid order response: missing keyId, razorpayOrderId, or amountInPaise.\n'
          'Received: $orderData',
        );
      }

      // ── Step 4: Build prefill from backend ────────────────────────────
      final prefillData = orderData['prefill'] as Map<String, dynamic>?;

      final Map<String, dynamic> options = {
        'key': keyId,
        'order_id': razorpayOrderId,
        'amount': amountInPaise,
        'name': 'GyaanPlant',
        'description': itemDescription,
        'theme': {'color': '#00C853'},
      };

      if (prefillData != null) {
        final prefill = <String, String>{};
        if (prefillData['name'] != null) {
          prefill['name'] = prefillData['name'].toString();
        }
        if (prefillData['email'] != null) {
          prefill['email'] = prefillData['email'].toString();
        }
        if (prefill.isNotEmpty) {
          options['prefill'] = prefill;
        }
      }

      // ── Step 5: Open Razorpay checkout ────────────────────────────────
      debugPrint(
        '💳 PaymentService: Opening Razorpay checkout — order=$razorpayOrderId',
      );
      _razorpay!.open(options);
    } catch (e) {
      debugPrint('❌ PaymentService: Failed to create order — $e');
      if (context.mounted) {
        _showError(context, 'Failed to initiate payment: $e');
      }
    }
  }

  // ─── Payment Verification ─────────────────────────────────────────────────

  /// Verifies a successful payment with the backend.
  /// Should be called inside [PaymentSuccessCallback].
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String itemId,
    required ItemType itemType,
  }) async {
    debugPrint(
      '🔍 PaymentService: Verifying payment — $razorpayPaymentId',
    );
    return await _apiService.payment.verifyPayment(
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      itemId: itemId,
      itemType: itemType,
    );
  }

  // ─── Cleanup ──────────────────────────────────────────────────────────────

  /// Disposes the Razorpay instance and clears all event listeners.
  /// Must be called in the widget's [dispose] method.
  void dispose() {
    if (_isInitialized && _razorpay != null) {
      _razorpay!.clear();
      _razorpay = null;
      _isInitialized = false;
      _onSuccess = null;
      _onError = null;
      _onExternalWallet = null;
      debugPrint('🧹 PaymentService: Razorpay disposed');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF020B08),
        title: const Text(
          'Payment Error',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF00C853)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF020B08),
        title: const Text(
          'Success',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF00C853)),
            ),
          ),
        ],
      ),
    );
  }
}
