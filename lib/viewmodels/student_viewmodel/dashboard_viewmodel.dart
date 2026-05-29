import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import 'package:gyaanplant/models/student_role_models/dashboard_model.dart';
import '../../data/services/api_service.dart';

class DashboardViewModel extends ChangeNotifier {
  static const _tag = 'DashboardViewModel';

  final _student = ApiService().student;

  DashboardModel? dashboard;
  bool isLoading = false;
  bool isLoaded = false;
  String? errorMessage;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> fetchDashboard() async {
    if (isLoaded) {
      print("📊 [DashboardViewModel] Already loaded, skipping fetch.");
      return;
    }

    print("📊 [DashboardViewModel] ========== FETCH START ==========");
    print("📊 [DashboardViewModel] fetchDashboard() called. Setting isLoading = true");
    isLoading = true;
    isLoaded = false;
    errorMessage = null;
    dashboard = null;
    notifyListeners();

    try {
      print("📊 [DashboardViewModel] Calling _student.getDashboard()...");
      final result = await _student.getDashboard();

      print("📊 [DashboardViewModel] API call completed");
      print("📊 [DashboardViewModel] Result - success: ${result.success}, statusCode: ${result.statusCode}, hasData: ${result.data != null}, hasError: ${result.error != null}");
      
      if (result.isSuccess) {
        try {
          final data = result.data!;
          print("📊 [DashboardViewModel] ✅ Response is successful");
          print("📊 [DashboardViewModel] Raw data received - xp=${data.xp}, rank=${data.rank}, xpProgress=${data.xpProgress}");
          print("📊 [DashboardViewModel] Student: ${data.student != null ? data.student!.user?.name ?? 'no name' : 'null'}");

          // Build the DashboardModel safely with null checks
          try {
            final studentName = data.student?.user?.name;
            final studentEmail = data.student?.user?.email;
            
            print("📊 [DashboardViewModel] Building DashboardModel with studentName: $studentName, studentEmail: $studentEmail");
            
            final studentInfo = data.student != null ? {
              'name': studentName,
              'email': studentEmail,
              'id': data.student!.id,
              'profileStrength': data.student!.profileStrength,
              'testsCompleted': data.student!.testsCompleted,
              'totalPoints': data.student!.totalPoints,
              'streakDays': data.student!.streakDays,
            } : null;

            dashboard = DashboardModel(
              xp: data.xp,
              rank: data.rank,
              xpProgress: data.xpProgress,
              enrollments: const [],
              drives: data.drives,
              student: studentInfo,
            );

            print("📊 [DashboardViewModel] ✅ DashboardModel created successfully");
            print("📊 [DashboardViewModel] Dashboard: xp=${dashboard!.xp}, rank=${dashboard!.rank}, studentInfo=$studentInfo");
            
            isLoaded = true;
            print("📊 [DashboardViewModel] isLoaded set to true");
            AppLogger.info(_tag, 'Dashboard loaded successfully');
          } catch (e, st) {
            print("📊 [DashboardViewModel] ❌ Error creating DashboardModel: $e");
            print(st);
            errorMessage = 'Failed to process dashboard data: $e';
            AppLogger.error(_tag, errorMessage!, e, st);
          }
        } catch (e, st) {
          print("📊 [DashboardViewModel] ❌ Error accessing response data: $e");
          print(st);
          errorMessage = 'Error accessing dashboard data: $e';
          AppLogger.error(_tag, errorMessage!, e, st);
        }
      } else {
        errorMessage = result.error?.message ?? 'Failed to load dashboard (unknown error)';
        print("📊 [DashboardViewModel] ❌ API response indicates failure: $errorMessage");
        print("📊 [DashboardViewModel] Error details: ${result.error}");
        AppLogger.error(_tag, errorMessage!);
      }
    } catch (e, st) {
      errorMessage = 'Dashboard fetch exception: $e';
      print("💥 [DashboardViewModel] ❌ EXCEPTION in fetchDashboard: $e");
      print(st);
      AppLogger.error(_tag, 'Failed to load dashboard', e, st);
    } finally {
      print("📊 [DashboardViewModel] ========== FINALLY BLOCK ==========");
      print("📊 [DashboardViewModel] Setting isLoading = false");
      print("📊 [DashboardViewModel] Final state - isLoaded: $isLoaded, isLoading: true → false, errorMessage: $errorMessage, dashboardNull: ${dashboard == null}");
      
      isLoading = false;
      
      if (!_disposed) {
        print("📊 [DashboardViewModel] Widget not disposed, calling notifyListeners()");
        notifyListeners();
        print("📊 [DashboardViewModel] ✅ Listeners notified. UI should update now.");
      } else {
        print("📊 [DashboardViewModel] ⚠️  Widget is disposed, skipping notifyListeners()");
      }
      print("📊 [DashboardViewModel] ========== FETCH END ==========");
    }
  }
}
