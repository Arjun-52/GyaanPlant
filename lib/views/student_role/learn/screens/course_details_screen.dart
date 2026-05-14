import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../data/services/api_service.dart';
import '../../../../models/learning/learning_model.dart';
import '../../../../models/payment/item_type.dart';
import '../../../../services/payment_service.dart';
import '../../../../viewmodels/student_viewmodel/learning_viewmodel.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final _apiService = ApiService();
  late final PaymentService _paymentService;

  CourseModel? course;
  bool isLoading = true;
  String? error;
  bool isEnrolled = false;
  bool isPaymentProcessing = false;

  @override
  void initState() {
    super.initState();

    _paymentService = PaymentService();
    _paymentService.initialize(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );

    _fetchCourse();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  // ─── Data Fetching ────────────────────────────────────────────────────────

  Future<void> _fetchCourse() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      course = await _apiService.learning.getCourseById(widget.courseId);

      if (mounted) {
        final learningViewModel = context.read<LearningViewModel>();
        isEnrolled = learningViewModel.isCourseEnrolled(widget.courseId);
      }
    } catch (e) {
      error = e.toString();
      debugPrint('❌ Error fetching course: $error');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ─── Razorpay Callbacks ───────────────────────────────────────────────────

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('💳 Course payment SUCCESS: ${response.paymentId}');

    setState(() => isPaymentProcessing = false);

    try {
      await _paymentService.verifyPayment(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        itemId: widget.courseId,
        itemType: ItemType.course,
      );

      debugPrint('✅ Course payment verified');

      if (mounted) {
        await context.read<LearningViewModel>().fetchCourses();
        setState(() => isEnrolled = true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course enrolled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Course payment verification failed: $e');
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
    debugPrint('❌ Course payment ERROR: ${response.code} — ${response.message}');
    if (!mounted) return;
    setState(() => isPaymentProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('👛 External wallet selected: ${response.walletName}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet selected: ${response.walletName}'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  // ─── Payment Flow ─────────────────────────────────────────────────────────

  Future<void> _startPayment() async {
    if (course == null || isPaymentProcessing) return;

    setState(() => isPaymentProcessing = true);

    await _paymentService.createOrderAndOpenCheckout(
      context: context,
      itemId: widget.courseId,
      itemType: ItemType.course,
      itemDescription: 'Enroll in ${course!.title}',
    );

    // Reset state if the checkout failed to open (error dialog was shown)
    if (mounted && isPaymentProcessing) {
      setState(() => isPaymentProcessing = false);
    }
  }

  void _resumeCourse() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening course content...'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  // ─── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('All Courses', style: TextStyle(color: Colors.white)),
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
              ? _buildErrorState()
              : course == null
                  ? const Center(
                      child: Text(
                        'Course not found',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Error loading course',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error!,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchCourse,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            course!.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Info cards
          Row(
            children: [
              _infoCard('Modules', '${course!.totalModules}'),
              const SizedBox(width: 10),
              _infoCard('Duration', '${course!.durationMins}m'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _infoCard('Points', '50'),
              const SizedBox(width: 10),
              _infoCard('XP', '100'),
            ],
          ),

          const SizedBox(height: 20),

          // Curriculum
          _sectionCard(
            title: 'Curriculum Overview',
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock, color: Colors.white),
                  title: Text('Intro', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    '10 mins',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Requirements
          _sectionCard(
            title: 'Requirements',
            child: const Column(
              children: [
                _RowItem('Passing Score', '70%'),
                _RowItem('Target Audience', 'Student'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Students
          _sectionCard(
            title: 'Enrolled Students',
            child: const Text(
              '0 Learners',
              style: TextStyle(color: Colors.white),
            ),
          ),

          const SizedBox(height: 20),

          // Price + Enroll
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'PRICE',
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 8),
                Text(
                  course!.category ?? 'Free',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isPaymentProcessing
                        ? null
                        : isEnrolled
                            ? _resumeCourse
                            : _startPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPaymentProcessing
                          ? Colors.grey
                          : isEnrolled
                              ? Colors.orange
                              : const Color(0xFF00C853),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isPaymentProcessing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Processing...'),
                            ],
                          )
                        : Text(
                            isEnrolled ? 'RESUME COURSE' : 'ENROLL NOW',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String title;
  final String value;

  const _RowItem(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
