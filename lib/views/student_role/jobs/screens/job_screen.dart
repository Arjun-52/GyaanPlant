import 'package:flutter/material.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/job_viewmodel.dart';
import 'package:gyaanplant/views/student_role/jobs/widgets/job_card.dart';
import 'package:gyaanplant/views/student_role/jobs/widgets/job_filter_row.dart';
import 'package:gyaanplant/views/student_role/jobs/widgets/job_header.dart';
import 'package:gyaanplant/views/student_role/jobs/widgets/search_bar.dart';
import 'package:provider/provider.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  @override
  void initState() {
    super.initState();
    print("🖥️ JobScreen initState() called");
    Future.microtask(() {
      if (mounted) {
        print("🖥️ Calling fetchJobs() from JobScreen initState");
        context.read<JobViewModel>().fetchJobs();
      } else {
        print("❌ Widget not mounted, skipping fetchJobs()");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B08),
      body: Consumer<JobViewModel>(
        builder: (context, vm, child) {
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

                if (vm.filteredJobs.isEmpty)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.work, size: 50, color: Colors.white38),
                        SizedBox(height: 12),
                        Text(
                          'No jobs available',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Check back later for opportunities',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: vm.filteredJobs.map((job) {
                      return JobCard(
                        title: job.role ?? 'No Role',
                        company: job.companyName ?? 'Unknown Company',
                        location: job.location ?? 'Not specified',
                        salary: job.salary ?? 'Not specified',
                        match: job.match,
                        tags: job.skills ?? ['Job'],
                        showBadge: job.isNew ?? false,
                        badgeText: 'New',
                        badgeColor: Colors.orange,
                        logoColor: Colors.green,
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
