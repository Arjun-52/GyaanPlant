import 'package:flutter/material.dart';
import 'package:gyaanplant/core/common_widgets/common_bottom_nav.dart';
import 'package:gyaanplant/viewmodels/job_viewmodel.dart';
import 'package:gyaanplant/views/jobs/widgets/job_card.dart';
import 'package:gyaanplant/views/jobs/widgets/job_filter_row.dart';
import 'package:gyaanplant/views/jobs/widgets/job_header.dart';
import 'package:gyaanplant/views/jobs/widgets/search_bar.dart';
import 'package:provider/provider.dart';

class JobScreen extends StatelessWidget {
  const JobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFF020B08),
        bottomNavigationBar: const CommonBottomNav(currentIndex: 3),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: const [
              SizedBox(height: 20),

              JobHeader(),
              SizedBox(height: 16),

              JobSearchBar(),
              SizedBox(height: 16),

              JobFilterRow(),
              SizedBox(height: 20),

              Column(
                children: [
                  JobCard(
                    title: "Software Engineer",
                    company: "TCS",
                    location: "Hyderabad",
                    salary: "₹3.5–7",
                    match: "87%",
                    tags: ["Java", "SQL", "B.E/B.Tech", "2025 Batch"],

                    showBadge: true,
                    badgeText: "NEW",
                    badgeColor: Color(0xFF00C853),

                    logoColor: Colors.blue,
                  ),
                  JobCard(
                    title: "Data Analyst Intern",
                    company: "Swiggy",
                    location: "Remote",
                    salary: "₹20K",
                    match: "91%",
                    tags: ["SQL", "Excel", "Python"],

                    showBadge: true,
                    badgeText: "HOT 🔥",
                    badgeColor: Colors.orange,

                    logoColor: Colors.purple,
                  ),
                  JobCard(
                    title: "Systems Engineer",
                    company: "Infosys",
                    location: "Bengaluru",
                    salary: "₹3.6–6.5",
                    match: "74%",
                    tags: ["Python", "DBMS", "Any Branch"],
                    logoColor: Colors.orange,
                  ),

                  JobCard(
                    title: "Project Engineer",
                    company: "Wipro",
                    location: "Hyderabad",
                    salary: "₹3.5–5",
                    match: "79%",
                    tags: ["C++", "Java", "2025 Batch"],
                    showBadge: true,
                    badgeText: "NEW",
                    badgeColor: Colors.green,
                    logoColor: Colors.red,
                  ),

                  JobCard(
                    title: "Associate Software Eng",
                    company: "Accenture",
                    location: "Multiple",
                    salary: "₹4.5–8",
                    match: "82%",
                    tags: ["Coding", "Aptitude", "Any Branch"],
                    logoColor: Colors.deepPurple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
