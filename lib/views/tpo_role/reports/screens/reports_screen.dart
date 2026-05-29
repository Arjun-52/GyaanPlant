import 'package:flutter/material.dart';
import 'package:gyaanplant/models/tpo_role_models/report_model.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/reports_viewmodel.dart';
import 'package:gyaanplant/views/tpo_role/reports/widgets/report_card.dart';
import 'package:provider/provider.dart';
import 'package:gyaanplant/views/tpo_role/reports/services/report_type.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final ReportsViewModel _vm;
  String _searchQuery = "";
  String _selectedFilter = "All";

  final List<String> _filterChips = [
    "All",
    "PDF",
    "Excel",
    "NAAC",
    "Placement",
    "Analytics"
  ];

  @override
  void initState() {
    super.initState();
    _vm = ReportsViewModel()..initialize();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  List<Report> _getFilteredReports(List<Report> reports) {
    return reports.where((report) {
      // 1. Search Query Filter
      final title = report.title.toLowerCase();
      final subtitle = report.subtitle.toLowerCase();
      final query = _searchQuery.toLowerCase();
      if (!title.contains(query) && !subtitle.contains(query)) {
        return false;
      }

      // 2. Category Chip Filter
      if (_selectedFilter == "All") return true;
      if (_selectedFilter == "PDF") {
        return subtitle.contains("pdf") ||
            report.type == ReportType.naac ||
            report.type == ReportType.companyDrive ||
            report.type == ReportType.placementSummary ||
            report.type == ReportType.departmentReadiness;
      }
      if (_selectedFilter == "Excel") {
        return subtitle.contains("excel") ||
            report.type == ReportType.skillGapAnalysis;
      }
      if (_selectedFilter == "NAAC") {
        return report.type == ReportType.naac || title.contains("naac");
      }
      if (_selectedFilter == "Placement") {
        return report.type == ReportType.placementSummary ||
            report.type == ReportType.companyDrive ||
            title.contains("placement") ||
            title.contains("drive");
      }
      if (_selectedFilter == "Analytics") {
        return report.type == ReportType.skillGapAnalysis ||
            report.type == ReportType.departmentReadiness ||
            title.contains("readiness") ||
            title.contains("gap");
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Scaffold(
        backgroundColor: const Color(0xFF020B08),
        body: Consumer<ReportsViewModel>(
          builder: (context, vm, _) {
            final filtered = _getFilteredReports(vm.reports);

            // Grouping reports
            final naacReports = filtered
                .where((r) => r.type == ReportType.naac || r.title.toLowerCase().contains("naac"))
                .toList();
            final placementReports = filtered
                .where((r) =>
                    (r.type == ReportType.placementSummary ||
                        r.type == ReportType.companyDrive) &&
                    !r.title.toLowerCase().contains("naac"))
                .toList();
            final analyticsReports = filtered
                .where((r) =>
                    r.type == ReportType.skillGapAnalysis ||
                    r.type == ReportType.departmentReadiness)
                .toList();

            return SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  /// 🟢 HERO HEADER
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: _buildHeroCard(vm.reports.length),
                    ),
                  ),

                  /// 🟢 QUICK STATS
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _buildQuickStats(vm.reports.length),
                    ),
                  ),

                  /// 🟢 GENERATE NAAC REPORT BANNER
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                      child: _buildFeaturedNaacBanner(vm),
                    ),
                  ),

                  /// 🟢 SEARCH & FILTER CHIPS
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          _buildSearchBar(),
                          const SizedBox(height: 12),
                          _buildFilterChips(),
                        ],
                      ),
                    ),
                  ),

                  /// 🟢 CATEGORIZED REPORTS LIST OR EMPTY STATE
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                        child: _buildEmptyState(),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildCategorySection("🏫 NAAC REPORTS", naacReports),
                          _buildCategorySection("📊 PLACEMENT REPORTS", placementReports),
                          _buildCategorySection("📈 ANALYTICS & READINESS REPORTS", analyticsReports),
                        ]),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🔷 HERO CARD WIDGET
  Widget _buildHeroCard(int totalCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3B2E), Color(0xFF031410)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C853).withOpacity(0.08),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF00E676),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Reports & Analytics",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Generate placement summaries, NAAC reports, and institutional student readiness insight archives directly to your local storage.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeroBadge("Total: $totalCount Reports"),
              const SizedBox(width: 10),
              _buildHeroBadge("Active: 3 Categories"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.15),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF00E676),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  /// 🔷 QUICK STATS GRID
  Widget _buildQuickStats(int totalCount) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard("📄 Total", "$totalCount Reports", "All Available"),
          const SizedBox(width: 12),
          _buildStatCard("📥 Downloads", "24 Hits", "This Month"),
          const SizedBox(width: 12),
          _buildStatCard("📊 Generated", "8 Done", "Active Cycle"),
          const SizedBox(width: 12),
          _buildStatCard("🏫 NAAC", "2 Items", "Criterion 5.2"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String sub) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF091F18), Color(0xFF04100C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔷 FEATURED NAAC BANNER
  Widget _buildFeaturedNaacBanner(ReportsViewModel vm) {
    final naacReport = vm.reports.firstWhere(
      (r) => r.type == ReportType.naac,
      orElse: () => vm.reports.first,
    );
    final isDownloading = vm.isDownloading(naacReport.type);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3B2E), Color(0xFF08211A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF00C853).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C853).withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "🏫",
                      style: TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        naacReport.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Criterion 5.2 — Institutional Placement & Higher Studies metrics compilation.",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isDownloading
                ? null
                : () => vm.downloadReport(naacReport, context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.black,
              shadowColor: const Color(0xFF00C853).withOpacity(0.4),
              elevation: 8,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "🚀 Generate",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// 🔷 SEARCH BAR
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.1),
        ),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Search premium reports...",
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00E676), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchQuery = "";
                    });
                  },
                  child: const Icon(Icons.close, color: Colors.white54, size: 16),
                )
              : null,
        ),
      ),
    );
  }

  /// 🔷 FILTER CHIPS
  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filterChips.length,
        itemBuilder: (context, index) {
          final chip = _filterChips[index];
          final isSelected = _selectedFilter == chip;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = chip;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00C853)
                      : const Color(0xFF081A15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00C853)
                        : Colors.greenAccent.withOpacity(0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    chip,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white60,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🔷 CATEGORY SECTION CONTAINER
  Widget _buildCategorySection(String title, List<Report> categoryReports) {
    if (categoryReports.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.greenAccent.withOpacity(0.2),
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: categoryReports.map((report) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ReportCard(report: report),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 🔷 EMPTY STATE
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF051410),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.08),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red.withOpacity(0.15),
              ),
            ),
            child: const Icon(
              Icons.find_in_page_outlined,
              color: Colors.redAccent,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "📄 No Reports Available",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "We couldn't find any reports matching your search or filters. Try adjusting your settings.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
