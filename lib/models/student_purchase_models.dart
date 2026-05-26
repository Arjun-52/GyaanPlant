// lib/models/student_purchase_models.dart

class StudentPurchaseStats {
  final int activeLearners;
  final double grossRevenue;
  final int courseAdoption;
  final int mentorship;

  StudentPurchaseStats({
    required this.activeLearners,
    required this.grossRevenue,
    required this.courseAdoption,
    required this.mentorship,
  });

  factory StudentPurchaseStats.fromJson(Map<String, dynamic> json) {
    final students = json['students'] ?? {};
    final orders = (json['orders'] as List?) ?? [];
    final totalAmount = orders.isNotEmpty ? (orders[0]['totalAmount'] ?? 0).toDouble() : 0.0;
    return StudentPurchaseStats(
      activeLearners: (students['totalStudentsWithPurchases'] ?? 0) as int,
      grossRevenue: totalAmount,
      courseAdoption: ((students['studentsWithCourse'] ?? 0) as int) + ((students['studentsWithPrepPack'] ?? 0) as int),
      mentorship: (students['studentsWithSession'] ?? 0) as int,
    );
  }
}

class PaymentTransaction {
  final String? studentName;
  final String? purchasedItem;
  final double? amount;
  final String? paymentMethod;
  final String? status;
  final String? paymentDate;

  PaymentTransaction({
    this.studentName,
    this.purchasedItem,
    this.amount,
    this.paymentMethod,
    this.status,
    this.paymentDate,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      studentName: json['studentName']?.toString(),
      purchasedItem: json['item']?.toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['method']?.toString(),
      status: json['status']?.toString(),
      paymentDate: json['date']?.toString(),
    );
  }
}
