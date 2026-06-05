import 'package:flutter/material.dart';

/// Price and Enrollment CTA block container widget.
class PriceEnrollCard extends StatelessWidget {
  final String priceText;
  final bool isEnrolled;
  final bool isPaymentProcessing;
  final VoidCallback onEnroll;
  final VoidCallback onResume;

  const PriceEnrollCard({
    super.key,
    required this.priceText,
    required this.isEnrolled,
    required this.isPaymentProcessing,
    required this.onEnroll,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            priceText,
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
                  ? onResume
                  : onEnroll,
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
    );
  }
}
