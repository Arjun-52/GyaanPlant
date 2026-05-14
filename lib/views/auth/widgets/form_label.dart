import 'package:flutter/material.dart';

class FormLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const FormLabel({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
    );
  }
}
