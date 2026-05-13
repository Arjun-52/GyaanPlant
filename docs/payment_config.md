# Payment Configuration

## Environment Setup

The Razorpay payment integration now supports environment-based configuration for easy switching between test and production modes.

### Test Mode (Default)
```bash
flutter run
```
- Uses test key: `rzp_test_SgTgIrRTm5fJjb`
- Safe for development and testing

### Production Mode
```bash
flutter run --dart-define=RAZORPAY_KEY=your_live_key_here
```
- Uses your live Razorpay key
- Required for production deployment

## Features

### ✅ Production Ready
- Environment-based configuration
- No hardcoded credentials
- Proper error handling
- Payment timeout (2 minutes)
- Memory leak prevention

### ✅ User Experience
- Real user data prefill (email, name)
- Comprehensive error messages
- Network error handling
- Timeout protection

### ✅ Security
- Backend order creation
- Payment verification
- No sensitive data in client code

## Usage

### In UI Components
```dart
PaymentButton(
  itemId: 'course-123',
  itemType: ItemType.course,
  itemName: 'Flutter Course',
  buttonText: 'Purchase Now',
  onPaymentSuccess: () => print('Payment successful!'),
)
```

### Direct Service Usage
```dart
final paymentService = PaymentService();
paymentService.init(
  onSuccess: (response) => handleSuccess(response),
  onError: (response) => handleError(response),
  onExternal: (response) => handleWallet(response),
);

paymentService.purchaseItem(
  context: context,
  itemId: 'course-123',
  itemType: ItemType.course,
  user: authViewModel.user, // Real user data
);
```

## Configuration Options

### PaymentConfig Properties
- `razorpayKey`: API key from environment
- `paymentTimeout`: 2 minutes timeout
- `themeColor`: Brand color (#00C853)
- `defaultDescription`: Default payment description

### Environment Detection
- `PaymentConfig.isProduction`: Check if using live key
- `PaymentConfig.isTestMode`: Check if using test key

## Error Handling

The service handles:
- Network errors (SocketException)
- Timeout errors (TimeoutException)
- Invalid order responses
- Payment failures
- Backend verification errors

## Cleanup

Always dispose the payment service:
```dart
@override
void dispose() {
  paymentService.dispose();
  super.dispose();
}
```

## Migration Notes

- Removed duplicate `razorpay_service.dart`
- Centralized configuration in `PaymentConfig`
- Replaced hardcoded user data with real user data
- Added comprehensive error handling
- Implemented payment timeout protection
