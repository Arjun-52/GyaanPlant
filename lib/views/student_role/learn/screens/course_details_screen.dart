import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../data/services/api_service.dart';
import '../../../../models/learning/learning_model.dart';
import '../../../../models/payment/item_type.dart';
import '../../../../models/payment/order_result.dart';
import '../../../../viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/course-details/info_card.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/course-details/section_card.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/course-details/row_item.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/course-details/error_retry_widget.dart';
import 'package:gyaanplant/views/student_role/learn/widgets/course-details/price_enroll_card.dart';
import 'package:gyaanplant/views/student_role/learn/screens/course_learning_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  static const _tag = 'CourseDetailsScreen';

  final _learning = ApiService().learning;
  final _apiService = ApiService();
  late Razorpay _razorpay;

  CourseModel? course;
  bool isLoading = true;
  String? error;
  bool isEnrolled = false;

  // Payment state
  String? currentItemId;
  ItemType? currentItemType;
  bool isPaymentProcessing = false;

  @override
  void initState() {
    super.initState();
    _initRazorpay();
    _fetchCourse();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _fetchCourse() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // `getCourseById` now returns `CourseModel` directly and throws on
      // failure — no `ApiResponse` wrapper.
      course = await _learning.getCourseById(widget.courseId);
      if (mounted) {
        isEnrolled = context.read<LearningViewModel>().isCourseEnrolled(
          widget.courseId,
        );
      }
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    AppLogger.info(
      _tag,
      'Payment success: paymentId=${response.paymentId} orderId=${response.orderId} itemId=$currentItemId itemType=$currentItemType',
    );

    if (response.paymentId == null ||
        response.orderId == null ||
        response.signature == null) {
      AppLogger.error(
        _tag,
        'Razorpay success callback missing field(s): '
        'paymentId=${response.paymentId} orderId=${response.orderId} '
        'signature=${response.signature}',
      );
      if (mounted) setState(() => isPaymentProcessing = false);
      return;
    }

    try {
      AppLogger.info(_tag, 'Verifying payment...');

      await _apiService.payment.verifyPayment(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        razorpaySignature: response.signature!,
      );

      AppLogger.info(_tag, 'Payment verified; refreshing course list');

      if (mounted) {
        await context.read<LearningViewModel>().fetchCourses();
        if (!mounted) return;

        setState(() {
          isPaymentProcessing = false;
          isEnrolled = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course enrolled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Payment verification failed', e, st);

      if (mounted) setState(() => isPaymentProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verification failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final analysis = switch (response.code?.toString()) {
      'BAD_REQUEST_ERROR' => 'Invalid payment request parameters',
      'NETWORK_ERROR' => 'Network connectivity issue',
      'INTERNAL_SERVER_ERROR' => 'Razorpay server error',
      'INVALID_SIGNATURE' => 'Payment signature verification failed',
      'PAYMENT_CANCELLED' => 'User cancelled the payment',
      'PAYMENT_FAILED' => 'Payment processing failed',
      'INVALID_ORDER' => 'Invalid or expired order',
      _ => 'Unknown error (code: ${response.code})',
    };

    AppLogger.error(
      _tag,
      'Payment error: code=${response.code} message=${response.message} ($analysis)',
    );

    if (mounted) {
      setState(() => isPaymentProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message ?? analysis}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      AppLogger.warning(_tag, 'Widget not mounted; suppressed error snackbar');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    AppLogger.info(_tag, 'External wallet selected: ${response.walletName}');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet selected: ${response.walletName}'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      AppLogger.warning(_tag, 'Widget not mounted; suppressed wallet snackbar');
    }
  }

  Future<void> _startPayment() async {
    AppLogger.info(_tag, 'Starting payment process');

    if (course == null) {
      AppLogger.error(_tag, 'Course is null');
      return;
    }

    if (isPaymentProcessing) {
      AppLogger.warning(_tag, 'Payment already in progress');
      return;
    }

    currentItemId = widget.courseId;
    currentItemType = ItemType.course;
    setState(() => isPaymentProcessing = true);

    AppLogger.info(
      _tag,
      'Payment state: course=${course!.title} itemType=$currentItemType itemId=$currentItemId',
    );

    try {
      AppLogger.info(_tag, 'Creating order via API...');

      final order = await _apiService.payment.createOrder(
        itemId: currentItemId!,
        itemType: currentItemType!,
      );

      AppLogger.info(_tag, 'Order response: ${order.runtimeType}');

      final int amount;
      final String orderId;
      final String keyId;
      switch (order) {
        case FreeItemOrder():
          AppLogger.info(_tag, 'Course is FREE — direct enrollment');
          await _enrollFreeItem();
          return;
        case PaidOrder(
            orderId: final id,
            amount: final amt,
            keyId: final key,
          ):
          orderId = id;
          amount = amt;
          keyId = key;
      }

      if (amount <= 0) {
        AppLogger.error(_tag, 'Invalid amount: $amount (must be > 0)');
        throw Exception('Invalid amount: $amount');
      }

      final options = {
        'key': keyId,
        'order_id': orderId,
        'amount': amount,
        'name': 'GyaanPlant',
        'description': 'Enroll in ${course!.title} course',
        'prefill': {'contact': '9999999999', 'email': 'test@example.com'},
        'theme': {'color': '#00C853'},
      };

      AppLogger.info(
        _tag,
        'Opening Razorpay: orderId=$orderId amount=₹${(amount / 100).toStringAsFixed(2)} testMode=${keyId.startsWith('rzp_test_')}',
      );

      _razorpay.open(options);

      AppLogger.info(_tag, 'Razorpay checkout opened');
    } on SocketException catch (e, st) {
      AppLogger.error(_tag, 'Network error: ${e.message}', e, st);

      if (mounted) setState(() => isPaymentProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException catch (e, st) {
      AppLogger.error(_tag, 'Timeout: ${e.message}', e, st);

      if (mounted) setState(() => isPaymentProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment timeout: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FormatException catch (e, st) {
      AppLogger.error(_tag, 'Format error: ${e.message}', e, st);

      if (mounted) setState(() => isPaymentProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data format error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Unexpected payment error', e, st);

      if (mounted) setState(() => isPaymentProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _enrollFreeItem() async {
    AppLogger.info(
      _tag,
      'Free enrollment: itemId=$currentItemId itemType=$currentItemType',
    );

    if (currentItemId == null || currentItemType == null) {
      AppLogger.error(_tag, 'Item details null for free enrollment');
      if (mounted) setState(() => isPaymentProcessing = false);
      return;
    }

    try {
      await _apiService.payment.enrollFreeItem(
        itemId: currentItemId!,
        itemType: currentItemType!,
      );

      AppLogger.info(_tag, 'Free enrollment success; refreshing course list');

      if (mounted) {
        await context.read<LearningViewModel>().fetchCourses();
        if (!mounted) return;

        setState(() {
          isEnrolled = true;
          isPaymentProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Free course enrolled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, st) {
      AppLogger.error(_tag, 'Free enrollment failed', e, st);

      if (mounted) setState(() => isPaymentProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enroll in free course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resumeCourse() {
    if (course == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseLearningScreen(
          courseId: widget.courseId,
          courseTitle: course!.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("All Courses", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C853)),
            )
          : error != null
          ? ErrorRetryWidget(
              errorMessage: error!,
              onRetry: _fetchCourse,
            )
          : course == null
          ? const Center(
              child: Text(
                "Course not found",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    course!.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Info cards
                  Row(
                    children: [
                      InfoCard(title: "Modules", value: "${course!.totalModules}"),
                      const SizedBox(width: 10),
                      InfoCard(title: "Duration", value: "${course!.durationMins}m"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      InfoCard(title: "Points", value: "50"),
                      const SizedBox(width: 10),
                      InfoCard(title: "XP", value: "100"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Curriculum
                  SectionCard(
                    title: "Curriculum Overview",
                    child: Column(
                      children: const [
                        ListTile(
                          leading: Icon(Icons.lock, color: Colors.white),
                          title: Text(
                            "Intro",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "10 mins",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Requirements
                  SectionCard(
                    title: "Requirements",
                    child: Column(
                      children: const [
                        RowItem(title: "Passing Score", value: "70%"),
                        RowItem(title: "Target Audience", value: "Student"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Students
                  SectionCard(
                    title: "Enrolled Students",
                    child: const Text(
                      "0 Learners",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Price + enroll
                  PriceEnrollCard(
                    priceText: course!.category ?? "Free",
                    isEnrolled: isEnrolled,
                    isPaymentProcessing: isPaymentProcessing,
                    onEnroll: _startPayment,
                    onResume: _resumeCourse,
                  ),
                ],
              ),
            ),
    );
  }
}
