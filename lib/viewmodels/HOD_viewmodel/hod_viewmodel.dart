import 'package:flutter/material.dart';

class Dept {
  final String name;
  final int percent;

  Dept(this.name, this.percent);
}

class HodViewModel extends ChangeNotifier {
  List<Dept> departments = [
    Dept("CSE", 78),
    Dept("IT", 72),
    Dept("ECE", 61),
    Dept("EEE", 54),
    Dept("Mech", 42),
    Dept("Civil", 38),
  ];
}
