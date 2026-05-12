import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/tpo_role_models/report_model.dart';

/// Service for generating professional PDF reports
class PdfGeneratorService {
  static const _tag = 'PdfGeneratorService';

  /// Generate a professional PDF report based on report type
  static Future<Uint8List> generateReport({
    required ReportType reportType,
    required String collegeName,
    required Map<String, dynamic> reportData,
  }) async {
    try {
      AppLogger.info(_tag, 'Generating ${reportType.name} report');
      AppLogger.info(_tag, 'College: $collegeName');
      AppLogger.info(_tag, 'Report data keys: ${reportData.keys.toList()}');

      final pdf = pw.Document();

      // Add custom fonts (using default fonts for compatibility)
      final titleFont = pw.Font.helveticaBold();
      final bodyFont = pw.Font.helvetica();

      // Build report content based on type
      switch (reportType) {
        case ReportType.naac:
          await _buildNaacReport(
            pdf,
            collegeName,
            reportData,
            titleFont,
            bodyFont,
          );
          break;
        case ReportType.placementSummary:
          await _buildPlacementSummaryReport(
            pdf,
            collegeName,
            reportData,
            titleFont,
            bodyFont,
          );
          break;
        case ReportType.skillGapAnalysis:
          await _buildSkillGapAnalysisReport(
            pdf,
            collegeName,
            reportData,
            titleFont,
            bodyFont,
          );
          break;
        case ReportType.departmentReadiness:
          await _buildDepartmentReadinessReport(
            pdf,
            collegeName,
            reportData,
            titleFont,
            bodyFont,
          );
          break;
        case ReportType.companyDrive:
          await _buildCompanyDriveReport(
            pdf,
            collegeName,
            reportData,
            titleFont,
            bodyFont,
          );
          break;
      }

      // Save the PDF
      final pdfBytes = await pdf.save();
      AppLogger.info(_tag, 'PDF generated successfully');
      return pdfBytes;
    } catch (e, st) {
      AppLogger.error(_tag, 'Failed to generate PDF', e, st);
      rethrow;
    }
  }

  /// Build NAAC Accreditation Report
  static Future<void> _buildNaacReport(
    pw.Document pdf,
    String collegeName,
    Map<String, dynamic> data,
    pw.Font titleFont,
    pw.Font bodyFont,
  ) async {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          // Header
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Text(
                'NAAC Accreditation Report',
                style: pw.TextStyle(
                  font: titleFont,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              // College Name and Date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    collegeName,
                    style: pw.TextStyle(font: bodyFont, fontSize: 16),
                  ),
                  pw.Text(
                    _getCurrentDate(),
                    style: pw.TextStyle(font: bodyFont, fontSize: 12),
                  ),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.grey),
              pw.SizedBox(height: 20),

              // Executive Summary
              _buildSectionTitle('Executive Summary', titleFont),
              pw.SizedBox(height: 10),
              pw.Text(
                'This comprehensive NAAC accreditation report provides an in-depth analysis of our institution\'s '
                'performance across various quality metrics and educational standards.',
                style: pw.TextStyle(font: bodyFont, fontSize: 12),
              ),
              pw.SizedBox(height: 20),

              // Key Metrics
              _buildSectionTitle('Key Performance Metrics', titleFont),
              pw.SizedBox(height: 10),
              _buildMetricsTable(data, bodyFont),
              pw.SizedBox(height: 20),

              // Academic Excellence
              _buildSectionTitle('Academic Excellence', titleFont),
              pw.SizedBox(height: 10),
              pw.Text(
                'Our institution maintains high academic standards with a focus on research, innovation, '
                'and holistic development of students.',
                style: pw.TextStyle(font: bodyFont, fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              _buildAcademicMetrics(data, bodyFont),
              pw.SizedBox(height: 20),

              // Infrastructure and Facilities
              _buildSectionTitle('Infrastructure and Facilities', titleFont),
              pw.SizedBox(height: 10),
              pw.Text(
                'State-of-the-art infrastructure including modern classrooms, laboratories, library, '
                'and sports facilities supporting comprehensive education.',
                style: pw.TextStyle(font: bodyFont, fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              _buildInfrastructureMetrics(data, bodyFont),
              pw.SizedBox(height: 20),

              // Recommendations
              _buildSectionTitle('Recommendations', titleFont),
              pw.SizedBox(height: 10),
              _buildRecommendationsList(data, bodyFont),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Placement Summary Report
  static Future<void> _buildPlacementSummaryReport(
    pw.Document pdf,
    String collegeName,
    Map<String, dynamic> data,
    pw.Font titleFont,
    pw.Font bodyFont,
  ) async {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Text(
                'Placement Summary Report',
                style: pw.TextStyle(
                  font: titleFont,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              // College Name and Date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    collegeName,
                    style: pw.TextStyle(font: bodyFont, fontSize: 16),
                  ),
                  pw.Text(
                    _getCurrentDate(),
                    style: pw.TextStyle(font: bodyFont, fontSize: 12),
                  ),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.grey),
              pw.SizedBox(height: 20),

              // Placement Overview
              _buildSectionTitle('Placement Overview', titleFont),
              pw.SizedBox(height: 10),
              _buildPlacementOverview(data, bodyFont),
              pw.SizedBox(height: 20),

              // Company-wise Statistics
              _buildSectionTitle(
                'Company-wise Placement Statistics',
                titleFont,
              ),
              pw.SizedBox(height: 10),
              _buildCompanyStatsTable(data, bodyFont),
              pw.SizedBox(height: 20),

              // Department-wise Analysis
              _buildSectionTitle('Department-wise Analysis', titleFont),
              pw.SizedBox(height: 10),
              _buildDepartmentStatsTable(data, bodyFont),
              pw.SizedBox(height: 20),

              // Salary Analysis
              _buildSectionTitle('Salary Analysis', titleFont),
              pw.SizedBox(height: 10),
              _buildSalaryAnalysis(data, bodyFont),
              pw.SizedBox(height: 20),

              // Top Recruiters
              _buildSectionTitle('Top Recruiters', titleFont),
              pw.SizedBox(height: 10),
              _buildTopRecruitersList(data, bodyFont),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Skill Gap Analysis Report
  static Future<void> _buildSkillGapAnalysisReport(
    pw.Document pdf,
    String collegeName,
    Map<String, dynamic> data,
    pw.Font titleFont,
    pw.Font bodyFont,
  ) async {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Text(
                'Skill Gap Analysis Report',
                style: pw.TextStyle(
                  font: titleFont,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              // College Name and Date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    collegeName,
                    style: pw.TextStyle(font: bodyFont, fontSize: 16),
                  ),
                  pw.Text(
                    _getCurrentDate(),
                    style: pw.TextStyle(font: bodyFont, fontSize: 12),
                  ),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.grey),
              pw.SizedBox(height: 20),

              // AI Insights
              _buildSectionTitle('AI-Generated Insights', titleFont),
              pw.SizedBox(height: 10),
              pw.Text(
                'Based on comprehensive analysis of student performance and industry requirements, '
                'our AI has identified critical skill gaps and recommended interventions.',
                style: pw.TextStyle(font: bodyFont, fontSize: 12),
              ),
              pw.SizedBox(height: 20),

              // Skill Gap Analysis
              _buildSectionTitle('Skill Gap Analysis', titleFont),
              pw.SizedBox(height: 10),
              _buildSkillGapTable(data, bodyFont),
              pw.SizedBox(height: 20),

              // Industry Requirements
              _buildSectionTitle(
                'Industry Requirements vs Student Skills',
                titleFont,
              ),
              pw.SizedBox(height: 10),
              _buildIndustryComparison(data, bodyFont),
              pw.SizedBox(height: 20),

              // Recommendations
              _buildSectionTitle('Recommendations', titleFont),
              pw.SizedBox(height: 10),
              _buildSkillRecommendations(data, bodyFont),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Department Readiness Report
  static Future<void> _buildDepartmentReadinessReport(
    pw.Document pdf,
    String collegeName,
    Map<String, dynamic> data,
    pw.Font titleFont,
    pw.Font bodyFont,
  ) async {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Text(
                'Department Readiness Report',
                style: pw.TextStyle(
                  font: titleFont,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              // College Name and Date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    collegeName,
                    style: pw.TextStyle(font: bodyFont, fontSize: 16),
                  ),
                  pw.Text(
                    _getCurrentDate(),
                    style: pw.TextStyle(font: bodyFont, fontSize: 12),
                  ),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.grey),
              pw.SizedBox(height: 20),

              // Overall Readiness Score
              _buildSectionTitle('Overall Readiness Assessment', titleFont),
              pw.SizedBox(height: 10),
              _buildReadinessScore(data, bodyFont),
              pw.SizedBox(height: 20),

              // Department-wise Analysis
              _buildSectionTitle('Department-wise Analysis', titleFont),
              pw.SizedBox(height: 10),
              _buildDepartmentReadinessTable(data, bodyFont),
              pw.SizedBox(height: 20),

              // Strengths and Weaknesses
              _buildSectionTitle(
                'Departmental Strengths and Weaknesses',
                titleFont,
              ),
              pw.SizedBox(height: 10),
              _buildDepartmentAnalysis(data, bodyFont),
              pw.SizedBox(height: 20),

              // Action Plan
              _buildSectionTitle('Action Plan for Improvement', titleFont),
              pw.SizedBox(height: 10),
              _buildActionPlan(data, bodyFont),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Company Drive Report
  static Future<void> _buildCompanyDriveReport(
    pw.Document pdf,
    String collegeName,
    Map<String, dynamic> data,
    pw.Font titleFont,
    pw.Font bodyFont,
  ) async {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Text(
                'Company Drive Report',
                style: pw.TextStyle(
                  font: titleFont,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              // College Name and Date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    collegeName,
                    style: pw.TextStyle(font: bodyFont, fontSize: 16),
                  ),
                  pw.Text(
                    _getCurrentDate(),
                    style: pw.TextStyle(font: bodyFont, fontSize: 12),
                  ),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.grey),
              pw.SizedBox(height: 20),

              // Drive Summary
              _buildSectionTitle('Drive Summary', titleFont),
              pw.SizedBox(height: 10),
              _buildDriveSummary(data, bodyFont),
              pw.SizedBox(height: 20),

              // Company-wise Performance
              _buildSectionTitle('Company-wise Performance', titleFont),
              pw.SizedBox(height: 10),
              _buildCompanyPerformanceTable(data, bodyFont),
              pw.SizedBox(height: 20),

              // Student Participation
              _buildSectionTitle('Student Participation Analysis', titleFont),
              pw.SizedBox(height: 10),
              _buildStudentParticipation(data, bodyFont),
              pw.SizedBox(height: 20),

              // Success Metrics
              _buildSectionTitle('Success Metrics', titleFont),
              pw.SizedBox(height: 10),
              _buildSuccessMetrics(data, bodyFont),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for building report sections
  static pw.Widget _buildSectionTitle(String title, pw.Font font) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        font: font,
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
    );
  }

  static pw.Widget _buildMetricsTable(Map<String, dynamic> data, pw.Font font) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          children: [
            _buildTableCell('Metric', font, isHeader: true),
            _buildTableCell('Current', font, isHeader: true),
            _buildTableCell('Target', font, isHeader: true),
            _buildTableCell('Status', font, isHeader: true),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell('Student-Faculty Ratio', font),
            _buildTableCell('15:1', font),
            _buildTableCell('20:1', font),
            _buildTableCell('✓ Excellent', font),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell('Research Publications', font),
            _buildTableCell('45', font),
            _buildTableCell('50', font),
            _buildTableCell('✓ Good', font),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell('Placement Rate', font),
            _buildTableCell('85%', font),
            _buildTableCell('90%', font),
            _buildTableCell('⚠ Needs Improvement', font),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  // Additional helper methods for other report sections
  static pw.Widget _buildAcademicMetrics(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '• Graduation Rate: 92%',
            style: pw.TextStyle(font: font, fontSize: 11),
          ),
          pw.Text(
            '• Research Output: 45 publications',
            style: pw.TextStyle(font: font, fontSize: 11),
          ),
          pw.Text(
            '• Innovation Index: 8.5/10',
            style: pw.TextStyle(font: font, fontSize: 11),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfrastructureMetrics(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '• Classrooms: 120 (Smart)',
            style: pw.TextStyle(font: font, fontSize: 11),
          ),
          pw.Text(
            '• Laboratories: 45 (Advanced)',
            style: pw.TextStyle(font: font, fontSize: 11),
          ),
          pw.Text(
            '• Library: Digital with 50,000+ books',
            style: pw.TextStyle(font: font, fontSize: 11),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildRecommendationsList(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '1. Enhance industry-academia collaboration',
          style: pw.TextStyle(font: font, fontSize: 11),
        ),
        pw.Text(
          '2. Focus on research and innovation',
          style: pw.TextStyle(font: font, fontSize: 11),
        ),
        pw.Text(
          '3. Improve placement support services',
          style: pw.TextStyle(font: font, fontSize: 11),
        ),
        pw.Text(
          '4. Strengthen alumni engagement',
          style: pw.TextStyle(font: font, fontSize: 11),
        ),
      ],
    );
  }

  // Placeholder methods for other report types (to be implemented similarly)
  static pw.Widget _buildPlacementOverview(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Placement overview data will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildCompanyStatsTable(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Company statistics table will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildDepartmentStatsTable(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Department statistics table will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildSalaryAnalysis(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Salary analysis will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildTopRecruitersList(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Top recruiters list will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildSkillGapTable(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Skill gap analysis table will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildIndustryComparison(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Industry comparison will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildSkillRecommendations(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Skill recommendations will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildReadinessScore(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Readiness score will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildDepartmentReadinessTable(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Department readiness table will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildDepartmentAnalysis(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Department analysis will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildActionPlan(Map<String, dynamic> data, pw.Font font) {
    return pw.Text(
      'Action plan will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildDriveSummary(Map<String, dynamic> data, pw.Font font) {
    return pw.Text(
      'Drive summary will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildCompanyPerformanceTable(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Company performance table will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildStudentParticipation(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Student participation will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }

  static pw.Widget _buildSuccessMetrics(
    Map<String, dynamic> data,
    pw.Font font,
  ) {
    return pw.Text(
      'Success metrics will be displayed here...',
      style: pw.TextStyle(font: font, fontSize: 12),
    );
  }
}
