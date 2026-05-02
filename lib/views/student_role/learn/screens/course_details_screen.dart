import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../data/services/api_service.dart';
import '../../../../models/learning/learning_model.dart';
import '../../../../models/payment/item_type.dart';
import '../../../../viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'package:provider/provider.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
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
      course = await _learning.getCourseById(widget.courseId);
      print(" COURSE TITLE: ${course?.title}");

      // Check if user is already enrolled using ViewModel
      final learningViewModel = context.read<LearningViewModel>();
      isEnrolled = learningViewModel.isCourseEnrolled(widget.courseId);
      print(" COURSE ENROLLED STATUS: $isEnrolled");
    } catch (e) {
      error = e.toString();
      print(" ERROR FETCHING COURSE: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("💳 PAYMENT SUCCESS: ${response.paymentId}, ${response.orderId}");

    try {
      // Verify payment with backend
      final verification = await _apiService.payment.verifyPayment(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        itemId: currentItemId!,
        itemType: currentItemType!,
      );

      print("✅ PAYMENT VERIFIED: $verification");

      // NOW safe to refresh - AFTER payment completes
      if (mounted) {
        await context.read<LearningViewModel>().fetchCourses();

        // Update UI state
        setState(() {
          isPaymentProcessing = false;
          isEnrolled = true;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course enrolled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("❌ VERIFY FAILED: $e");
      setState(() => isPaymentProcessing = false);
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
    print("❌ PAYMENT FAILED: ${response.code} - ${response.message}");
    setState(() => isPaymentProcessing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("🏦 EXTERNAL WALLET: ${response.walletName}");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet selected: ${response.walletName}'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _startPayment() async {
    if (course == null) return;

    // Payment processing guard
    if (isPaymentProcessing) {
      print("⚠️ Payment already in progress");
      return;
    }

    print("🚀 START PAYMENT");

    // Store current payment state
    currentItemId = widget.courseId;
    currentItemType = ItemType.course;
    isPaymentProcessing = true;

    try {
      // Create order ONLY
      final order = await _apiService.payment.createOrder(
        itemId: currentItemId!,
        itemType: currentItemType!,
      );

      print("🧾 ORDER: $order");

      // Check if this is a free course
      if (order['isFree'] == true) {
        print("⚠️ FREE COURSE DETECTED → DIRECT ENROLL");
        await _enrollFreeItem();
        return;
      }

      // Get order details with flexible field mapping
      final orderId = order['orderId'] ?? order['razorpayOrderId'];
      final amount = order['amount'] ?? order['amountInPaise'];

      if (orderId == null || amount == null) {
        throw Exception('Invalid order response: missing orderId or amount');
      }

      print("💳 OPENING RAZORPAY");

      // Open Razorpay checkout ONLY - no other work
      _razorpay.open({
        'key': 'rzp_test_SgTgIrRTm5fJjb',
        'order_id': orderId,
        'amount': amount,
        'name': 'GyaanPlant',
        'description': 'Enroll in ${course!.title} course',
        'prefill': {'contact': '9999999999', 'email': 'test@example.com'},
        'theme': {'color': '#00C853'},
      });
    } catch (e) {
      print("❌ PAYMENT SETUP FAILED: $e");
      setState(() => isPaymentProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create payment order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _enrollFreeItem() async {
    try {
      // Call the direct enrollment API
      await _apiService.payment.enrollFreeItem(
        itemId: currentItemId!,
        itemType: currentItemType!,
      );

      print("🎉 ENROLLED WITHOUT PAYMENT");

      // Update UI state
      setState(() {
        isEnrolled = true;
        isPaymentProcessing = false;
      });

      // Refresh enrolled courses to update Learn screen
      if (mounted) {
        await context.read<LearningViewModel>().fetchCourses();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Free course enrolled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("❌ FREE ENROLLMENT FAILED: $e");
      setState(() => isPaymentProcessing = false);
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

  Future<void> _enrollPaidCourse() async {
    try {
      // Call the direct enrollment API for paid courses
      await _apiService.payment.enrollCourse(
        itemId: currentItemId!,
        itemType: currentItemType!,
      );

      print("🎉 PAID COURSE ENROLLED SUCCESSFULLY");

      // Update UI state
      setState(() {
        isEnrolled = true;
        isPaymentProcessing = false;
      });

      // Refresh enrolled courses to update Learn screen
      if (mounted) {
        await context.read<LearningViewModel>().fetchCourses();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course enrolled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("❌ PAID ENROLLMENT FAILED: $e");
      setState(() => isPaymentProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enroll in course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resumeCourse() {
    // TODO: Navigate to course content
    // For now, just show a message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening course content...'),
          backgroundColor: Colors.blue,
        ),
      );
    }
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading course",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
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
                    child: const Text(
                      "Retry",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
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
                      _infoCard("Modules", "${course!.totalModules}"),
                      const SizedBox(width: 10),
                      _infoCard("Duration", "${course!.durationMins}m"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _infoCard("Points", "50"),
                      const SizedBox(width: 10),
                      _infoCard("XP", "100"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Curriculum
                  _sectionCard(
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
                  _sectionCard(
                    title: "Requirements",
                    child: Column(
                      children: const [
                        _rowItem("Passing Score", "70%"),
                        _rowItem("Target Audience", "Student"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Students
                  _sectionCard(
                    title: "Enrolled Students",
                    child: const Text(
                      "0 Learners",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Price + enroll
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "PRICE",
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course!.category ?? "Free",
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.black,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Processing...'),
                                    ],
                                  )
                                : Text(
                                    isEnrolled ? "RESUME COURSE" : "ENROLL NOW",
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

class _rowItem extends StatelessWidget {
  final String title;
  final String value;

  const _rowItem(this.title, this.value);

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
