import 'package:flutter/material.dart';

class JobViewModel extends ChangeNotifier {
  int selectedFilter = 0;

  void selectFilter(int index) {
    selectedFilter = index;
    notifyListeners();
  }
}
