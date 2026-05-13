import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/HOD_models/naac_model.dart';

class NaacViewModel extends ChangeNotifier {
  static const _tag = 'NaacViewModel';

  NaacModel? naac;
  bool isLoading = false;
  bool isLoaded = false;
  String? errorMessage;
  bool _disposed = false;
  bool isGeneratingReport = false;
  String? generatedReport;

  Future<void> generateFullReport() async {
    if (naac == null) {
      errorMessage = 'No NAAC data available';
      notifyListeners();
      return;
    }

    isGeneratingReport = true;
    generatedReport = null;
    notifyListeners();

    try {
      // Simulate report generation
      await Future.delayed(const Duration(seconds: 2));

      // Generate comprehensive report
      final report = _generateReportContent();
      generatedReport = report;

      AppLogger.info(_tag, 'NAAC report generated successfully');
    } catch (e, st) {
      errorMessage = 'Failed to generate report: ${e.toString()}';
      AppLogger.error(_tag, 'Failed to generate NAAC report', e, st);
    } finally {
      isGeneratingReport = false;
      notifyListeners();
    }
  }

  String _generateReportContent() {
    if (naac == null) return '';

    final totalScore = naac!.criteria.fold<double>(
      0,
      (sum, criterion) => sum + criterion.score,
    );
    final averageScore = totalScore / naac!.criteria.length;

    final buffer = StringBuffer();
    buffer.writeln('🏆 NAAC ACCREDITATION REPORT');
    buffer.writeln('================================');
    buffer.writeln();
    buffer.writeln('📋 INSTITUTION: GRIET Hyderabad');
    buffer.writeln('📅 Generated: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('🎓 Current Grade: ${naac!.grade}');
    buffer.writeln('⏰ Valid Until: ${naac!.validTill}');
    buffer.writeln();
    buffer.writeln('📊 OVERALL PERFORMANCE');
    buffer.writeln('=====================');
    buffer.writeln(
      'Total Score: ${totalScore.toStringAsFixed(2)}/${naac!.criteria.length * 4}',
    );
    buffer.writeln('Average Score: ${averageScore.toStringAsFixed(2)}/4.0');
    buffer.writeln('Grade Achievement: ${naac!.grade}');
    buffer.writeln();
    buffer.writeln('📈 CRITERIA-WISE ANALYSIS');
    buffer.writeln('========================');

    for (int i = 0; i < naac!.criteria.length; i++) {
      final criterion = naac!.criteria[i];
      final percentage = (criterion.score / 4) * 100;
      buffer.writeln();
      buffer.writeln('Criterion ${i + 1}: ${criterion.title}');
      buffer.writeln(
        'Score: ${criterion.score.toStringAsFixed(2)}/4.0 (${percentage.toStringAsFixed(1)}%)',
      );

      // Add performance analysis
      if (criterion.score >= 3.5) {
        buffer.writeln('Status: ✅ Excellent Performance');
      } else if (criterion.score >= 3.0) {
        buffer.writeln('Status: 🟡 Good Performance');
      } else if (criterion.score >= 2.0) {
        buffer.writeln('Status: 🟠 Needs Improvement');
      } else {
        buffer.writeln('Status: 🔴 Critical Attention Required');
      }
    }

    buffer.writeln();
    buffer.writeln('🎯 KEY RECOMMENDATIONS');
    buffer.writeln('=====================');

    // Generate recommendations based on scores
    final lowScoringCriteria = naac!.criteria
        .where((c) => c.score < 3.0)
        .toList();
    if (lowScoringCriteria.isNotEmpty) {
      buffer.writeln('📌 Areas Needing Attention:');
      for (final criterion in lowScoringCriteria) {
        buffer.writeln(
          '  • ${criterion.title} (${criterion.score.toStringAsFixed(2)}/4.0)',
        );
      }
      buffer.writeln();
    }

    buffer.writeln('💡 Improvement Strategies:');
    buffer.writeln('  • Focus on criteria scoring below 3.0');
    buffer.writeln('  • Implement quality enhancement measures');
    buffer.writeln('  • Strengthen documentation and evidence');
    buffer.writeln('  • Enhance stakeholder feedback mechanisms');
    buffer.writeln();

    buffer.writeln('📅 NEXT STEPS');
    buffer.writeln('=============');
    buffer.writeln('  • Review and implement recommendations');
    buffer.writeln('  • Prepare for next accreditation cycle');
    buffer.writeln('  • Continuous quality improvement');
    buffer.writeln('  • Regular monitoring and evaluation');
    buffer.writeln();
    buffer.writeln('================================');
    buffer.writeln('End of Report');

    return buffer.toString();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> fetchNaac() async {
    if (isLoaded) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // TODO: replace with real API call
      await Future.delayed(const Duration(seconds: 1));

      naac = NaacModel(
        grade: 'A+',
        validTill: 2028,
        criteria: [
          NaacCriterion(title: 'Curricular Aspects', score: 3.4),
          NaacCriterion(title: 'Teaching & Learning', score: 3.6),
          NaacCriterion(title: 'Research & Innovation', score: 3.2),
          NaacCriterion(title: 'Infrastructure', score: 3.5),
          NaacCriterion(title: 'Student Support (Placement)', score: 3.8),
          NaacCriterion(title: 'Governance', score: 3.3),
        ],
      );
      isLoaded = true;
      AppLogger.info(_tag, 'NAAC data loaded');
    } catch (e, st) {
      errorMessage = e.toString();
      AppLogger.error(_tag, 'Failed to load NAAC data', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
