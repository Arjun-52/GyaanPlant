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

                // Debug info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "DEBUG INFO",
                        style: TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Loading: ${vm.isLoading}",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Jobs Count: ${vm.jobs.length}",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Error: ${vm.errorMessage ?? 'None'}",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Is Loaded: ${vm.isLoaded}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (vm.errorMessage != null)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.error_outline,
                          size: 50,
                          color: Colors.redAccent,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Failed to load jobs',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Please check your connection and try again',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                else if (vm.jobs.isEmpty)
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
                    children: vm.jobs.map((job) {
                      return JobCard(
                        title: job.role,
                        company: job.companyName,
                        location: 'Not specified',
                        salary: '',
                        match: '',
                        tags: const ['Job'],
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
    );
  }
}
