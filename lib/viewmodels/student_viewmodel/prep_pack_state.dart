import '../../models/assessment/mock_test_models.dart';

abstract class PrepPackState {
  const PrepPackState();
}

class PreparationLoading extends PrepPackState {
  const PreparationLoading();
}

class PreparationLocked extends PrepPackState {
  final PrepPackDetailsModel previewPack;
  const PreparationLocked(this.previewPack);
}

class PreparationUnlocked extends PrepPackState {
  final PrepPackDetailsModel fullPack;
  const PreparationUnlocked(this.fullPack);
}

class PreparationPurchaseLoading extends PrepPackState {
  final PrepPackDetailsModel previewPack;
  const PreparationPurchaseLoading(this.previewPack);
}

class PreparationError extends PrepPackState {
  final String message;
  const PreparationError(this.message);
}
