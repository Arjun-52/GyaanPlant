import 'package:flutter/material.dart';
import '../../models/assessment/mock_test_models.dart';
import '../../models/auth/auth_user_model.dart';
import '../../models/payment/item_type.dart';
import '../../models/payment/payment_result.dart';
import '../../services/payment_service.dart';
import '../../data/services/api_service.dart';
import '../../core/unlocked_packs_cache.dart';
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

          // Payment verified — try re-fetching details with retries
          // Backend may have a sync delay before the pack details endpoint
          // reflects the new access record written by verifyPayment.
          PrepPackDetailsModel? unlockedPack;
          for (int attempt = 0; attempt < 3; attempt++) {
            if (attempt > 0) {
              // Wait 1.5s before each retry to allow backend sync
              await Future.delayed(const Duration(milliseconds: 1500));
            }
            final response = await _apiService.assessment.getPrepPackDetails(packId);
            if (response.isSuccess && response.data != null && response.statusCode == 200) {
              unlockedPack = response.data!;
              break;
            }
          }

          if (unlockedPack != null) {
            // Backend confirmed unlock
            _state = PreparationUnlocked(unlockedPack);
            notifyListeners();
            // Mark unlocked in local cache so other screens update immediately
            UnlockedPacksCache.add(packId);
            showSuccess("Pack unlocked successfully! 🎉");
          } else {
            // Backend still returning 402 after retries — backend sync lag.
            // Trust the verified payment and force unlock locally using preview data.
            // The sections will be empty until backend syncs, but the user
            // can use the refresh button (↻) in the app bar to re-fetch.
            final forcedUnlock = _copyWithAccess(previewPack);
            _state = PreparationUnlocked(forcedUnlock);
            notifyListeners();
            // Backend sync lag: force local unlock so UI updates immediately
            UnlockedPacksCache.add(packId);
            showSuccess(
              "Pack unlocked! ✓ Tap ↻ to refresh if content isn't visible yet.",
            );
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

  /// Creates a copy of [pack] with [hasAccess] forced to true.
  /// Used as a frontend workaround when the backend pack-details endpoint
  /// returns 402 immediately after payment verification (sync lag).
  PrepPackDetailsModel _copyWithAccess(PrepPackDetailsModel pack) {
    return PrepPackDetailsModel(
      id: pack.id,
      title: pack.title,
      description: pack.description,
      price: pack.price,
      discountedPrice: pack.discountedPrice,
      discountPercentage: pack.discountPercentage,
      difficulty: pack.difficulty,
      targetType: pack.targetType,
      isPremium: pack.isPremium,
      hasAccess: true, // Force unlocked
      totalQuestions: pack.totalQuestions,
      totalDurationMins: pack.totalDurationMins,
      attempts: pack.attempts,
      completions: pack.completions,
      avgScore: pack.avgScore,
      passingScore: pack.passingScore,
      targetCompanies: pack.targetCompanies,
      targetRoles: pack.targetRoles,
      industries: pack.industries,
      markingScheme: pack.markingScheme,
      sections: pack.sections, // May be empty — user should refresh
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
}
