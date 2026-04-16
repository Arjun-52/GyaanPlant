import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/reports_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/reports/widgets/report_card.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/core/common_widgets/tpo_bottom_nav.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFF061A14),

        body: Consumer<ReportsViewModel>(
          builder: (context, vm, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    const Text(
                      "Reports 📊",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// LIST
                    Expanded(
                      child: ListView.separated(
                        itemCount: vm.reports.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            ReportCard(report: vm.reports[i]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        bottomNavigationBar: const TpoBottomNav(currentIndex: 3),
      ),
    );
  }
}
