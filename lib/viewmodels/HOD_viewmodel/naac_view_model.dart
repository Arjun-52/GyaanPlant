import 'package:flutter/material.dart';
import 'package:gyaanplant/models/HOD_models/naac_model.dart';

class NaacViewModel extends ChangeNotifier {
  NaacModel? naac;
  bool isLoading = false;

  Future<void> fetchNaac() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Mock data (replace with API)
    naac = NaacModel(
      grade: "A+",
      validTill: 2028,
      criteria: [
        NaacCriterion(title: "Curricular Aspects", score: 3.4),
        NaacCriterion(title: "Teaching & Learning", score: 3.6),
        NaacCriterion(title: "Research & Innovation", score: 3.2),
        NaacCriterion(title: "Infrastructure", score: 3.5),
        NaacCriterion(title: "Student Support (Placement)", score: 3.8),
        NaacCriterion(title: "Governance", score: 3.3),
      ],
    );

    isLoading = false;
    notifyListeners();
  }
}
