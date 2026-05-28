import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
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

class _CourseDetailsScreenState extends State<CourseDetailsScreen> with SingleTickerProviderStateMixin {
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
    _initEntranceAnimation();
    _fetchCourse();
  }

  late AnimationController _entranceCtrl;
  late Animation<double> _aTitle, _aStats, _aCurriculum, _aInfo, _aCta;
  late Animation<Offset> _sTitle, _sStats, _sCurriculum, _sInfo, _sCta;

  void _initEntranceAnimation() {
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _aTitle = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.15, curve: Curves.easeOut)));
    _aStats = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.15, 0.35, curve: Curves.easeOut)));
    _aCurriculum = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.35, 0.6, curve: Curves.easeOut)));
    _aInfo = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.6, 0.8, curve: Curves.easeOut)));
    _aCta = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.8, 1.0, curve: Curves.easeOut)));

    _sTitle = Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.15, curve: Curves.easeOut)));
    _sStats = Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.15, 0.35, curve: Curves.easeOut)));
    _sCurriculum = Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.35, 0.6, curve: Curves.easeOut)));
    _sInfo = Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.6, 0.8, curve: Curves.easeOut)));
    _sCta = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.8, 1.0, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    _razorpay.clear();
    try {
      _entranceCtrl.dispose();
    } catch (_) {}
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
      // trigger entrance animation when content ready
      if (mounted) {
        try {
          _entranceCtrl.forward(from: 0.0);
        } catch (_) {}
      }
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
                  : _buildRedesignedBody(context),
    );
  }

  Widget _buildRedesignedBody(BuildContext context) {
    // Colors
    const baseGreen = Color(0xFF00E676);
    const deepGreen = Color(0xFF003226);

    return Stack(
      children: [
        // Background layered gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF02110F), Color(0xFF021815)],
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner + Title Row
              _HeroCourseBanner(course: course!),
              const SizedBox(height: 18),

              // Title, badges and meta
              SlideTransition(
                position: _sTitle,
                child: FadeTransition(
                  opacity: _aTitle,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course!.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _Chip(label: course!.category ?? 'General', color: Colors.teal),
                                _Chip(label: 'Difficulty: Easy', color: Colors.green),
                                _Chip(label: '⭐ New', color: Colors.amber),
                                if (isEnrolled) _Chip(label: 'Enrolled', color: baseGreen),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Small stats on right
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _GlowingStat(icon: Icons.menu_book, label: 'Modules', value: '${course!.totalModules}'),
                          const SizedBox(height: 8),
                          _GlowingStat(icon: Icons.schedule, label: 'Duration', value: course!.duration ?? '0h 0m'),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Stats row
              SlideTransition(
                position: _sStats,
                child: FadeTransition(
                  opacity: _aStats,
                  child: Row(
                    children: [
                      Expanded(child: _StatCard(icon: Icons.layers, title: 'Points', value: '${course!.pointsReward}')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(icon: Icons.bolt, title: 'XP', value: '${course!.xpReward}')),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Curriculum roadmap
              SlideTransition(
                position: _sCurriculum,
                child: FadeTransition(
                  opacity: _aCurriculum,
                  child: _CurriculumRoadmap(modules: course!.modules, isEnrolled: isEnrolled),
                ),
              ),

              const SizedBox(height: 16),

              // Requirements + Students row
              SlideTransition(
                position: _sInfo,
                child: FadeTransition(
                  opacity: _aInfo,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _InfoCardGroup(course: course!),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: _EnrolledCard(count: course!.enrolled),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CTA
              SlideTransition(
                position: _sCta,
                child: FadeTransition(
                  opacity: _aCta,
                  child: Align(
                    alignment: Alignment.center,
                    child: _PremiumCTA(
                      isEnrolled: isEnrolled,
                      priceText: isEnrolled ? 'Enrolled' : (course!.price == 0 ? 'Free' : '₹${course!.price}'),
                      onEnroll: _startPayment,
                      onResume: _resumeCourse,
                      isProcessing: isPaymentProcessing,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
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

// ------------------ Helper widgets for redesigned UI ------------------

class _HeroCourseBanner extends StatefulWidget {
  final DetailedCourseModel course;
  const _HeroCourseBanner({required this.course});

  @override
  State<_HeroCourseBanner> createState() => _HeroCourseBannerState();
}

class _HeroCourseBannerState extends State<_HeroCourseBanner> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumb = widget.course.thumbnail ?? '';
    return SizedBox(
      height: 220,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = (_ctrl.value * 2.0 * math.pi);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(math.sin(t) * 6, math.cos(t) * 4, 0)
              ..rotateZ(math.sin(t) * 0.01),
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF06281F), Color(0xFF0B2F25)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 8)),
              BoxShadow(color: const Color(0xFF00E676).withOpacity(0.06), blurRadius: 32, spreadRadius: 1),
            ],
            border: Border.all(color: const Color(0xFF00E676).withOpacity(0.06)),
          ),
          child: Stack(
            children: [
              // background overlay glow
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: RadialGradient(
                      colors: [const Color(0xFF00E676).withOpacity(0.06), Colors.transparent],
                      center: Alignment.topLeft,
                      radius: 1.2,
                    ),
                  ),
                ),
              ),
              // course image centered
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.white10,
                      padding: const EdgeInsets.all(12),
                      child: Image.network(
                        thumb.isNotEmpty ? thumb : 'https://img.icons8.com/fluency/240/education.png',
                        height: 140,
                        fit: BoxFit.contain,
                        loadingBuilder: (c, ch, p) => p == null
                            ? ch
                            : const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF00E676)))),
                      ),
                    ),
                  ),
                ),
              ),
              // subtle shine
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.06,
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(colors: [Colors.white24, Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }
}

class _GlowingStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _GlowingStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF00E676), size: 16),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _StatCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [Colors.white12, Colors.white10]),
        border: Border.all(color: Colors.white10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF002918),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00E676)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}

class _CurriculumRoadmap extends StatelessWidget {
  final List modules;
  final bool isEnrolled;
  const _CurriculumRoadmap({required this.modules, required this.isEnrolled});

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return const SectionCard(title: 'Curriculum Overview', child: Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No modules available yet.', style: TextStyle(color: Colors.white54)))));
    }

    return SectionCard(
      title: 'Curriculum Overview',
      child: Column(
        children: modules.map<Widget>((module) {
          final lectures = (module as dynamic).lectures as List;
          return ExpansionTile(
            tilePadding: EdgeInsets.zero,
            collapsedIconColor: Colors.white54,
            iconColor: const Color(0xFF00E676),
            title: Text((module as dynamic).title, style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
            children: lectures.map((lecture) {
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEnrolled ? const Color(0xFF00E676) : Colors.white12,
                  ),
                ),
                title: Text(lecture.title, style: const TextStyle(color: Colors.white)),
                subtitle: Text('${lecture.durationMins} mins', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                trailing: isEnrolled ? const Icon(Icons.play_arrow_rounded, color: Color(0xFF00E676)) : const Icon(Icons.lock, color: Colors.white24),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoCardGroup extends StatelessWidget {
  final DetailedCourseModel course;
  const _InfoCardGroup({required this.course});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          title: 'Requirements',
          child: Column(
            children: [
              RowItem(title: 'Passing Score', value: '${course.passingScore}%'),
              RowItem(title: 'Target Audience', value: course.targetAudience.isNotEmpty ? course.targetAudience[0] : 'Student'),
            ],
          ),
        ),
      ],
    );
  }
}

class _EnrolledCard extends StatelessWidget {
  final int count;
  const _EnrolledCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white10,
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Positioned(left: 24, child: CircleAvatar(radius: 14, backgroundColor: Colors.white12, child: const Icon(Icons.person, color: Colors.white24, size: 16))),
                  Positioned(left: 12, child: CircleAvatar(radius: 14, backgroundColor: Colors.white12, child: const Icon(Icons.person, color: Colors.white24, size: 16))),
                  CircleAvatar(radius: 14, backgroundColor: const Color(0xFF00E676), child: const Icon(Icons.person, color: Colors.black, size: 16)),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Enrolled', style: const TextStyle(color: Colors.white70)), Text('$count Learners', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumCTA extends StatefulWidget {
  final bool isEnrolled;
  final String priceText;
  final VoidCallback onEnroll;
  final VoidCallback onResume;
  final bool isProcessing;
  const _PremiumCTA({required this.isEnrolled, required this.priceText, required this.onEnroll, required this.onResume, required this.isProcessing});

  @override
  State<_PremiumCTA> createState() => _PremiumCTAState();
}

class _PremiumCTAState extends State<_PremiumCTA> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = Color.lerp(const Color(0xFF00E676), const Color(0xFF00BCD4), _ctrl.value)!;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.isEnrolled ? widget.onResume : widget.onEnroll,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: [glow.withOpacity(0.92), const Color(0xFF00695C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: glow.withOpacity(0.45), blurRadius: 24, spreadRadius: 1)],
              border: Border.all(color: glow.withOpacity(0.2)),
            ),
            child: Center(
              child: widget.isProcessing
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF02110F)))
                  : Text(widget.isEnrolled ? 'Resume Course' : (widget.priceText == 'Free' ? 'Enroll Now' : 'Buy • ${widget.priceText}'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        );
      },
    );
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
        final v = _controller.value;
        final left = (v - 0.25).clamp(0.0, 1.0);
        final center = v.clamp(0.0, 1.0);
        final right = (v + 0.25).clamp(0.0, 1.0);

        BoxDecoration shimmerDecoration({double radius = 8}) => BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: const [Color(0xFF1E2A27), Color(0xFF2F3C39), Color(0xFF1E2A27)],
                stops: [left, center, right],
              ),
            );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title block
              Container(
                width: 250,
                height: 32,
                decoration: shimmerDecoration(radius: 8),
              ),
              const SizedBox(height: 16),
              // Course Image block
              Container(
                width: double.infinity,
                height: 180,
                decoration: shimmerDecoration(radius: 16),
              ),
              const SizedBox(height: 20),
              // Info card row 1
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: shimmerDecoration(radius: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: shimmerDecoration(radius: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Info card row 2
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: shimmerDecoration(radius: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: shimmerDecoration(radius: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Sectioncard placeholder
              Container(
                width: double.infinity,
                height: 120,
                decoration: shimmerDecoration(radius: 16),
              ),
              const SizedBox(height: 16),
              // Price block placeholder
              Container(
                width: double.infinity,
                height: 150,
                decoration: shimmerDecoration(radius: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}
