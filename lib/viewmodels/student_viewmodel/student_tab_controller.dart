import 'package:flutter/material.dart';

class StudentTabController extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void switchTab(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }

  void reset() {
    _currentIndex = 0;
  }
}
