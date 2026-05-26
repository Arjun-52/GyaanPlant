// lib/viewmodels/HOD_viewmodel/student_purchase_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:gyaanplant/models/student_purchase_models.dart';
import 'package:gyaanplant/repositories/student_purchase_repository.dart';

class StudentPurchaseViewModel extends ChangeNotifier {
  final StudentPurchaseRepository _repo = StudentPurchaseRepository();

  bool isLoading = false;
  String? error;

  StudentPurchaseStats? stats;
  List<PaymentTransaction> transactions = [];
  int totalEntries = 0;

  // Search query for UI filtering
  String _searchQuery = '';
  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  List<PaymentTransaction> get filteredTransactions {
    if (_searchQuery.isEmpty) return transactions;
    return transactions.where((t) => (t.studentName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) || (t.purchasedItem?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList();
  }

  Future<void> fetchAll() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final statsFuture = _repo.fetchStats();
      final paymentsFuture = _repo.fetchPayments();
      final results = await Future.wait([statsFuture, paymentsFuture]);
      stats = results[0] as StudentPurchaseStats;
      final paymentMap = results[1] as Map<String, dynamic>;
      final items = (paymentMap['items'] as List?) ?? [];
      transactions = items.map((e) => PaymentTransaction.fromJson(e as Map<String, dynamic>)).toList();
      totalEntries = (paymentMap['pagination']?['total'] ?? 0) as int;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async => fetchAll();
}
