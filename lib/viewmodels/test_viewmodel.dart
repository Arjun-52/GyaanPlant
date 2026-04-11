import 'package:flutter/material.dart';

class TestViewModel extends ChangeNotifier {
  int selectedOption = -1;

  void selectOption(int index) {
    selectedOption = index;
    notifyListeners();
  }
}
