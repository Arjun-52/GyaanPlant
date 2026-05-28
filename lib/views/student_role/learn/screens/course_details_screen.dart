import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../data/services/api_service.dart';
import 'package:gyaanplant/models/learning/detailed_course_model.dart';
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

  DetailedCourseModel? course;
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
      course = await _learning.getCourseById(widget.courseId);
      if (mounted) {
        setState(() {
          isEnrolled = (course!.enrollment != null || course!.hasAccess == true);
        });
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
          ? const _DetailShimmer()
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

                  /// Course Image Banner
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      color: (course!.thumbnail != null && course!.thumbnail!.isNotEmpty)
                          ? const Color(0xFFD9D9D9)
                          : const Color(0xFF09241E),
                      padding: const EdgeInsets.all(16),
                      child: Image.network(
                        (course!.thumbnail != null && course!.thumbnail!.isNotEmpty)
                            ? course!.thumbnail!
                            : _getCourseImageUrl(course!.title),
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(Color(0xFF00C853)),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          final hasThumbnail = course!.thumbnail != null && course!.thumbnail!.isNotEmpty;
                          if (hasThumbnail) {
                            return Image.network(
                              _getCourseImageUrl(course!.title),
                              fit: BoxFit.contain,
                              errorBuilder: (context, e, st) {
                                return const Icon(
                                  Icons.menu_book,
                                  color: Colors.white38,
                                  size: 48,
                                );
                              },
                            );
                          }
                          return const Icon(
                            Icons.menu_book,
                            color: Colors.white38,
                            size: 48,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Info cards
                  Row(
                    children: [
                      InfoCard(title: "Modules", value: "${course!.totalModules}"),
                      const SizedBox(width: 10),
                      InfoCard(title: "Duration", value: course!.duration ?? "0h 0m"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      InfoCard(title: "Points", value: "${course!.pointsReward}"),
                      const SizedBox(width: 10),
                      InfoCard(title: "XP", value: "${course!.xpReward}"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Curriculum
                  SectionCard(
                    title: "Curriculum Overview",
                    child: course!.modules.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                "No modules available yet.",
                                style: TextStyle(color: Colors.white54, fontSize: 14),
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: course!.modules.map((module) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                                    child: Text(
                                      module.title,
                                      style: const TextStyle(
                                        color: Color(0xFF00C853),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Divider(color: Colors.white10),
                                  ...module.lectures.map((lecture) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(
                                        isEnrolled ? Icons.play_arrow_rounded : Icons.lock,
                                        color: isEnrolled ? const Color(0xFF00C853) : Colors.white54,
                                      ),
                                      title: Text(
                                        lecture.title,
                                        style: const TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                      subtitle: Text(
                                        "${lecture.durationMins} mins",
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 12),
                                ],
                              );
                            }).toList(),
                          ),
                  ),

                  const SizedBox(height: 16),

                  /// Requirements
                  SectionCard(
                    title: "Requirements",
                    child: Column(
                      children: [
                        RowItem(title: "Passing Score", value: "${course!.passingScore}%"),
                        RowItem(
                          title: "Target Audience",
                          value: course!.targetAudience.isNotEmpty
                              ? course!.targetAudience[0]
                              : "Student",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Students
                  SectionCard(
                    title: "Enrolled Students",
                    child: Text(
                      "${course!.enrolled} Learners",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Price + enroll
                  PriceEnrollCard(
                    priceText: isEnrolled
                        ? "Enrolled"
                        : (course!.price == 0 ? "Free" : "₹${course!.price}"),
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

  String _getCourseImageUrl(String title) {
    final t = title.toLowerCase();
    if (t.contains('rust')) {
      return 'https://img.icons8.com/color/144/rust.png';
    }
    if (t.contains('javascript') || t.contains('js')) {
      return 'https://img.icons8.com/color/144/javascript--v1.png';
    }
    if (t.contains('flutter') || t.contains('dart')) {
      return 'https://img.icons8.com/color/144/flutter.png';
    }
    if (t.contains('python')) {
      return 'https://img.icons8.com/color/144/python--v1.png';
    }
    if (t.contains('sql') || t.contains('database') || t.contains('db')) {
      return 'https://img.icons8.com/fluency/144/database.png';
    }
    if (t.contains('azure') || t.contains('cloud') || t.contains('aws')) {
      return 'https://img.icons8.com/color/144/azure-1.png';
    }
    if (t.contains('dsa') || t.contains('data structure') || t.contains('algorithm') || t.contains('coding')) {
      return 'https://img.icons8.com/fluency/144/code.png';
    }
    if (t.contains('aptitude') || t.contains('math') || t.contains('quant')) {
      return 'https://img.icons8.com/fluency/144/math.png';
    }
    if (t.contains('verbal') || t.contains('english') || t.contains('communication')) {
      return 'https://img.icons8.com/fluency/144/speech-bubble.png';
    }
    if (t.contains('hr') || t.contains('interview') || t.contains('career')) {
      return 'https://img.icons8.com/color/144/briefcase.png';
    }
    return 'https://img.icons8.com/fluency/144/education.png';
  }
}

class _DetailShimmer extends StatefulWidget {
  const _DetailShimmer();

  @override
  State<_DetailShimmer> createState() => _DetailShimmerState();
}

class _DetailShimmerState extends State<_DetailShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.3 + (_controller.value * 0.35);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title block
              Opacity(
                opacity: opacity,
                child: Container(
                  width: 250,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Course Image block
              Opacity(
                opacity: opacity,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Info card row 1
              Opacity(
                opacity: opacity,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Info card row 2
              Opacity(
                opacity: opacity,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Sectioncard placeholder
              Opacity(
                opacity: opacity,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Price block placeholder
              Opacity(
                opacity: opacity,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
