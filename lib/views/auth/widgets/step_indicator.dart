import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({super.key, required this.currentStep});

  Widget _buildStep(int step) {
    bool isActive = step == currentStep;
    bool isCompleted = step < currentStep;

    return CircleAvatar(
      radius: 14,
      backgroundColor: isActive || isCompleted
          ? Colors.black
          : Colors.grey.shade300,
      child: Text(
        "$step",
        style: TextStyle(
          color: isActive || isCompleted ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _line() {
    return Expanded(child: Container(height: 1, color: Colors.grey.shade300));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [_buildStep(1), _line(), _buildStep(2), _line(), _buildStep(3)],
    );
  }
}
