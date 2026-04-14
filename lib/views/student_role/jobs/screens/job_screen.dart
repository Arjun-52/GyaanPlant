import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/common_bottom_nav.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/job_viewmodel.dart';
import 'package:gyaanplant/views/student_role/jobs/widgets/job_card.dart';
import 'package:gyaanplant/views/student_role/jobs/widgets/job_filter_row.dart';
import 'package:gyaanplant/views/student_role/jobs/widgets/job_header.dart';
import 'package:gyaanplant/views/student_role/jobs/widgets/search_bar.dart';
import 'package:provider/provider.dart';

class JobScreen extends StatelessWidget {
  const JobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobViewModel()..fetchJobs(),

      child: Scaffold(
        backgroundColor: const Color(0xFF020B08),
        bottomNavigationBar: const CommonBottomNav(currentIndex: 3),

        body: Consumer<JobViewModel>(
          builder: (context, vm, child) {
            /// 🔄 LOADING
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16),

              child: ListView(
                children: [
                  const SizedBox(height: 20),

                  const JobHeader(),
                  const SizedBox(height: 16),

                  const JobSearchBar(),
                  const SizedBox(height: 16),

                  const JobFilterRow(),
                  const SizedBox(height: 20),

                  /// ❌ EMPTY STATE
                  if (vm.jobs.isEmpty)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.work, size: 50, color: Colors.white38),
                          SizedBox(height: 12),

                          Text(
                            "No jobs available",
                            style: TextStyle(color: Colors.white),
                          ),

                          SizedBox(height: 6),

                          Text(
                            "Check back later for opportunities",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    )
                  /// ✅ JOB LIST
                  else
                    Column(
                      children: vm.jobs.map((job) {
                        return JobCard(
                          title: job.role,
                          company: job.companyName,

                          // 🔥 fallback values (backend may not provide)
                          location: "Not specified",
                          salary: "—",
                          match: "—",
                          tags: const ["Job"],

                          showBadge: false,
                          logoColor: Colors.green,
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
