import 'package:flutter/material.dart';
import '../../models/assessment/mock_test_models.dart';
import '../../models/auth/auth_user_model.dart';
import '../../models/payment/item_type.dart';
import '../../models/payment/payment_result.dart';
import '../../services/payment_service.dart';
import '../../data/services/api_service.dart';
import 'prep_pack_state.dart';

class PrepPackDetailsViewModel extends ChangeNotifier {
  final String packId;
  final PaymentService _paymentService = PaymentService()..init();
  final ApiService _apiService = ApiService();

  PrepPackState _state = const PreparationLoading();
  PrepPackState get state => _state;

  PrepPackDetailsViewModel({required this.packId});

  Future<void> loadDetails() async {
    _state = const PreparationLoading();
    notifyListeners();

    try {
      final response = await _apiService.assessment.getPrepPackDetails(packId);
      if (response.isSuccess && response.data != null) {
        if (response.statusCode == 200) {
          _state = PreparationUnlocked(response.data!);
        } else if (response.statusCode == 402) {
          _state = PreparationLocked(response.data!);
        } else {
          _state = PreparationError(response.error?.message ?? "Failed to load prep pack details");
        }
      } else {
        _state = PreparationError(response.error?.message ?? "Failed to load prep pack details");
      }
    } catch (e) {
      _state = PreparationError("An unexpected error occurred: $e");
    }
    notifyListeners();
  }

  Future<void> unlockPack({
    required AuthUser? user,
    required void Function(String message) showSuccess,
    required void Function(String message) showError,
  }) async {
    final currentState = _state;
    if (currentState is! PreparationLocked) return;

    final previewPack = currentState.previewPack;
    _state = PreparationPurchaseLoading(previewPack);
    notifyListeners();

    try {
      final result = await _paymentService.purchaseItem(
        itemId: previewPack.id,
        itemType: ItemType.preparationPack,
        itemDescription: previewPack.title,
        user: user,
      );

      if (result is PaymentFailed) {
        _state = PreparationLocked(previewPack);
        notifyListeners();
        showError(result.message);
        return;
      }

      if (result is PaymentSucceeded) {
        _state = const PreparationLoading();
        notifyListeners();

        try {
          await _paymentService.verifyPayment(
            razorpayPaymentId: result.razorpayPaymentId,
            razorpayOrderId: result.razorpayOrderId,
            razorpaySignature: result.razorpaySignature,
          );

          // Re-fetch details to confirm unlock status
          final response = await _apiService.assessment.getPrepPackDetails(packId);
          if (response.isSuccess && response.data != null && response.statusCode == 200) {
            _state = PreparationUnlocked(response.data!);
            notifyListeners();
            showSuccess("Pack unlocked successfully");
          } else {
            _state = PreparationLocked(previewPack);
            notifyListeners();
            showError("Payment completed. Access sync pending. Pull to refresh.");
          }
        } catch (e) {
          _state = PreparationLocked(previewPack);
          notifyListeners();
          showError("Payment completed. Access sync pending. Pull to refresh.");
        }
        return;
      }

      _state = PreparationLocked(previewPack);
      notifyListeners();
      showError("Payment cancelled");

    } catch (e) {
      _state = PreparationLocked(previewPack);
      notifyListeners();
      showError("An error occurred during purchase: $e");
    }
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
}
