import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../data/services/api_service.dart';
import '../../../../models/learning/learning_model.dart';
import '../../../../models/payment/item_type.dart';
import '../../../../viewmodels/student_viewmodel/learning_viewmodel.dart';
import '../../../../config/payment_config.dart';
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
      final result = await _learning.getCourseById(widget.courseId);
      if (result.isSuccess && result.data != null) {
        course = result.data;
        if (mounted) {
          isEnrolled = context.read<LearningViewModel>().isCourseEnrolled(
            widget.courseId,
          );
        }
      } else {
        error = result.error?.message ?? 'Failed to load course';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("💰 [RAZORPAY DEBUG] PAYMENT SUCCESS CALLBACK TRIGGERED!");
    print("   - Payment ID: ${response.paymentId}");
    print("   - Order ID: ${response.orderId}");
    print("   - Signature: ${response.signature}");
    print("   - Current Item ID: $currentItemId");
    print("   - Current Item Type: $currentItemType");

    if (response.paymentId == null) {
      print("❌ [RAZORPAY DEBUG] ERROR: Payment ID is null");
      if (mounted) setState(() => isPaymentProcessing = false);
      return;
    }

    if (response.orderId == null) {
      print("❌ [RAZORPAY DEBUG] ERROR: Order ID is null");
      if (mounted) setState(() => isPaymentProcessing = false);
      return;
    }

    if (currentItemId == null || currentItemType == null) {
      print("❌ [RAZORPAY DEBUG] ERROR: Current item details are null");
      print("   - Item ID: $currentItemId");
      print("   - Item Type: $currentItemType");
      if (mounted) setState(() => isPaymentProcessing = false);
      return;
    }

    try {
      print("🔍 [RAZORPAY DEBUG] Starting payment verification...");

      await _apiService.payment.verifyPayment(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        itemId: currentItemId!,
        itemType: currentItemType!,
      );

      print("✅ [RAZORPAY DEBUG] Payment verification successful!");
      print("📚 [RAZORPAY DEBUG] Fetching updated courses...");

      if (mounted) {
        await context.read<LearningViewModel>().fetchCourses();
        if (!mounted) return;

        print("🎉 [RAZORPAY DEBUG] Updating UI state...");
        setState(() {
          isPaymentProcessing = false;
          isEnrolled = true;
        });

        print("✅ [RAZORPAY DEBUG] Showing success message...");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course enrolled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("❌ [RAZORPAY DEBUG] PAYMENT VERIFICATION ERROR:");
      print("   - Error: $e");
      print("   - Type: ${e.runtimeType}");

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
    print("💔 [RAZORPAY DEBUG] PAYMENT ERROR CALLBACK TRIGGERED!");
    print("   - Error Code: ${response.code}");
    print("   - Error Message: ${response.message}");
    print("   - Response Type: ${response.runtimeType}");

    // Analyze specific error codes
    String errorAnalysis = "";
    switch (response.code?.toString()) {
      case 'BAD_REQUEST_ERROR':
        errorAnalysis = "Invalid payment request parameters";
        break;
      case 'NETWORK_ERROR':
        errorAnalysis = "Network connectivity issue";
        break;
      case 'INTERNAL_SERVER_ERROR':
        errorAnalysis = "Razorpay server error";
        break;
      case 'INVALID_SIGNATURE':
        errorAnalysis = "Payment signature verification failed";
        break;
      case 'PAYMENT_CANCELLED':
        errorAnalysis = "User cancelled the payment";
        break;
      case 'PAYMENT_FAILED':
        errorAnalysis = "Payment processing failed";
        break;
      case 'INVALID_ORDER':
        errorAnalysis = "Invalid or expired order";
        break;
      default:
        errorAnalysis = "Unknown error occurred (Code: ${response.code})";
    }

    print("🔍 [RAZORPAY DEBUG] Error Analysis: $errorAnalysis");

    if (mounted) {
      print("🔄 [RAZORPAY DEBUG] Updating UI state...");
      setState(() => isPaymentProcessing = false);

      print("📱 [RAZORPAY DEBUG] Showing error message to user...");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message ?? errorAnalysis}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      print("⚠️ [RAZORPAY DEBUG] Widget not mounted, cannot show UI error");
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("👛 [RAZORPAY DEBUG] EXTERNAL WALLET CALLBACK TRIGGERED!");
    print("   - Wallet Name: ${response.walletName}");
    print("   - Response Type: ${response.runtimeType}");

    if (mounted) {
      print("📱 [RAZORPAY DEBUG] Showing wallet selection message...");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet selected: ${response.walletName}'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      print(
        "⚠️ [RAZORPAY DEBUG] Widget not mounted, cannot show wallet message",
      );
    }
  }

  Future<void> _startPayment() async {
    print("🚀 [RAZORPAY DEBUG] Starting payment process...");

    if (course == null) {
      print("❌ [RAZORPAY DEBUG] ERROR: Course is null");
      return;
    }

    if (isPaymentProcessing) {
      print("⚠️ [RAZORPAY DEBUG] WARNING: Payment already in progress");
      return;
    }

    currentItemId = widget.courseId;
    currentItemType = ItemType.course;
    setState(() => isPaymentProcessing = true);

    print("✅ [RAZORPAY DEBUG] Payment state initialized:");
    print("   - Course ID: ${widget.courseId}");
    print("   - Course Title: ${course!.title}");
    print("   - Item Type: ${currentItemType}");
    print("   - Item ID: $currentItemId");

    try {
      print("📡 [RAZORPAY DEBUG] Creating order via API...");

      final order = await _apiService.payment.createOrder(
        itemId: currentItemId!,
        itemType: currentItemType!,
      );

      print("📦 [RAZORPAY DEBUG] Order response received:");
      print("   - Full Response: $order");
      print("   - Response Type: ${order.runtimeType}");
      print("   - Keys: ${order.keys.toList()}");

      if (order['isFree'] == true) {
        print(
          "🆓 [RAZORPAY DEBUG] Course is FREE, proceeding with direct enrollment",
        );
        await _enrollFreeItem();
        return;
      }

      final orderId = order['orderId'] ?? order['razorpayOrderId'];
      final amount = order['amount'] ?? order['amountInPaise'];

      print("🔍 [RAZORPAY DEBUG] Extracting payment details:");
      print("   - Order ID: $orderId");
      print("   - Amount: $amount");
      print("   - Amount Type: ${amount.runtimeType}");

      if (orderId == null) {
        print("❌ [RAZORPAY DEBUG] ERROR: Order ID is null");
        print("   - Available keys: ${order.keys.toList()}");
        print("   - orderId value: ${order['orderId']}");
        print("   - razorpayOrderId value: ${order['razorpayOrderId']}");
        throw Exception('Invalid order response: missing orderId');
      }

      if (amount == null) {
        print("❌ [RAZORPAY DEBUG] ERROR: Amount is null");
        print("   - Available keys: ${order.keys.toList()}");
        print("   - amount value: ${order['amount']}");
        print("   - amountInPaise value: ${order['amountInPaise']}");
        throw Exception('Invalid order response: missing amount');
      }

      if (amount <= 0) {
        print(
          "❌ [RAZORPAY DEBUG] ERROR: Invalid amount: $amount (must be > 0)",
        );
        throw Exception('Invalid amount: $amount');
      }

      final options = {
        'key': PaymentConfig.razorpayKey,
        'order_id': orderId,
        'amount': amount,
        'name': 'GyaanPlant',
        'description': 'Enroll in ${course!.title} course',
        'prefill': {'contact': '9999999999', 'email': 'test@example.com'},
        'theme': {'color': '#00C853'},
      };

      print("💳 [RAZORPAY DEBUG] Opening Razorpay checkout with options:");
      print("   - Key: ${PaymentConfig.razorpayKey}");
      print("   - Order ID: $orderId");
      print("   - Amount: ₹${(amount / 100).toStringAsFixed(2)}");
      print("   - Description: ${options['description']}");
      print("   - Theme Color: ${options['theme']['color']}");
      print("   - Is Test Mode: ${PaymentConfig.isTestMode}");

      _razorpay.open(options);

      print("✅ [RAZORPAY DEBUG] Razorpay checkout opened successfully");
    } on SocketException catch (e) {
      print("🌐 [RAZORPAY DEBUG] NETWORK ERROR:");
      print("   - Error: $e");
      print("   - Type: ${e.runtimeType}");
      print("   - Message: ${e.message}");
      print("   - Address: ${e.address}");
      print("   - Port: ${e.port}");

      if (mounted) setState(() => isPaymentProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException catch (e) {
      print("⏰ [RAZORPAY DEBUG] TIMEOUT ERROR:");
      print("   - Error: $e");
      print("   - Type: ${e.runtimeType}");
      print("   - Message: ${e.message}");
      print("   - Duration: ${e.duration}");

      if (mounted) setState(() => isPaymentProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment timeout: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FormatException catch (e) {
      print("📝 [RAZORPAY DEBUG] FORMAT ERROR:");
      print("   - Error: $e");
      print("   - Type: ${e.runtimeType}");
      print("   - Message: ${e.message}");
      print("   - Source: ${e.source}");

      if (mounted) setState(() => isPaymentProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data format error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      print("💥 [RAZORPAY DEBUG] UNEXPECTED ERROR:");
      print("   - Error: $e");
      print("   - Type: ${e.runtimeType}");
      print("   - Stack Trace: $stackTrace");

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
    print("🆓 [RAZORPAY DEBUG] STARTING FREE ITEM ENROLLMENT...");
    print("   - Item ID: $currentItemId");
    print("   - Item Type: $currentItemType");

    if (currentItemId == null || currentItemType == null) {
      print(
        "❌ [RAZORPAY DEBUG] ERROR: Item details are null for free enrollment",
      );
      if (mounted) setState(() => isPaymentProcessing = false);
      return;
    }

    try {
      print("📡 [RAZORPAY DEBUG] Calling free enrollment API...");

      await _apiService.payment.enrollFreeItem(
        itemId: currentItemId!,
        itemType: currentItemType!,
      );

      print("✅ [RAZORPAY DEBUG] Free enrollment API call successful!");
      print("📚 [RAZORPAY DEBUG] Fetching updated courses...");

      if (mounted) {
        await context.read<LearningViewModel>().fetchCourses();
        if (!mounted) return;

        print("🎉 [RAZORPAY DEBUG] Updating UI state for free enrollment...");
        setState(() {
          isEnrolled = true;
          isPaymentProcessing = false;
        });

        print("✅ [RAZORPAY DEBUG] Showing free enrollment success message...");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Free course enrolled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("❌ [RAZORPAY DEBUG] FREE ENROLLMENT ERROR:");
      print("   - Error: $e");
      print("   - Type: ${e.runtimeType}");

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
