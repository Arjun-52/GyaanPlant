import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'network/api_manager.dart';
import 'network/interceptors/auth_interceptor.dart';
import 'network/auth_cache.dart';
import 'routes/app_router.dart';
import 'data/services/local_storage_service.dart';
import 'viewmodels/student_viewmodel/auth_viewmodel.dart';
import 'viewmodels/student_viewmodel/student_tab_controller.dart';
import 'viewmodels/student_viewmodel/dashboard_viewmodel.dart';
import 'viewmodels/student_viewmodel/job_viewmodel.dart';
import 'viewmodels/student_viewmodel/leaderboard_viewmodel.dart';
import 'viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'viewmodels/student_viewmodel/mentor_viewmodel.dart';
import 'viewmodels/student_viewmodel/test_viewmodel.dart';
import 'viewmodels/tpo_viewmodels/drives_viewmodel.dart';
import 'viewmodels/HOD_viewmodel/hod_dashboard_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NetworkAPIManager.initialize();

  // Populate in-memory cache from secure storage so the router and interceptor
  // have the token synchronously on the first frame.
  final token = await LocalStorageService.getToken();
  AuthCache.token = token;

  AuthInterceptor.onUnauthorized = () {
    AppRouter.router.go('/');
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => JobViewModel()),
        ChangeNotifierProvider(create: (_) => MentorViewModel()),
        ChangeNotifierProvider(create: (_) => TestViewModel()),
        ChangeNotifierProvider(create: (_) => LearningViewModel()),
        ChangeNotifierProvider(create: (_) => LeaderboardViewModel()),
        ChangeNotifierProvider(create: (_) => StudentTabController()),
        ChangeNotifierProvider(create: (_) => DrivesViewModel()),
        // TpoDashboardViewModel is scoped to the TPO route in app_router.dart.
        ChangeNotifierProvider(
          create: (_) => HodDashboardViewModel()..loadDashboard(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
