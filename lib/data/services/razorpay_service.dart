import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onExternal,
  }) {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternal);
  }

  void openCheckout({
    required String orderId,
    required int amount,
    required String name,
    required String description,
  }) {
    var options = {
      'key': 'rzp_test_SgTgIrRTm5fJjb',
      'amount': amount,
      'name': name,
      'description': description,
      'order_id': orderId,
      'prefill': {'contact': '9999999999', 'email': 'test@example.com'},
    };

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
