import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'network/api_manager.dart';
import 'network/interceptors/auth_interceptor.dart';
import 'network/auth_cache.dart';
import 'routes/app_router.dart';
import 'data/services/local_storage_service.dart';
import 'services/notification_service.dart';
import 'viewmodels/student_viewmodel/auth_viewmodel.dart';
import 'viewmodels/student_viewmodel/student_tab_controller.dart';
import 'viewmodels/student_viewmodel/dashboard_viewmodel.dart';
import 'viewmodels/student_viewmodel/job_viewmodel.dart';
import 'viewmodels/student_viewmodel/leaderboard_viewmodel.dart';
import 'viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'viewmodels/student_viewmodel/mentor_viewmodel.dart';
import 'viewmodels/student_viewmodel/test_viewmodel.dart';
import 'viewmodels/tpo_viewmodels/drives_viewmodel.dart';
import 'viewmodels/tpo_viewmodels/tpo_dashboard_viewmodel.dart';
import 'viewmodels/student_viewmodel/notification_viewmodel.dart';
import 'viewmodels/HOD_viewmodel/hod_dashboard_viewmodel.dart';
import 'viewmodels/student_viewmodel/organization_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notification service and request permissions
  await NotificationService.initialize();

  NetworkAPIManager.initialize();

  // Load token from LocalStorageService and populate AuthCache
  final token = await LocalStorageService.getToken();
  AuthCache.token = token;
  print("🔑 TOKEN LOADED ON STARTUP: $token");
  print("🔑 TOKEN IS NULL: ${token == null}");

  AuthInterceptor.onUnauthorized = () async {
    await LocalStorageService.clearToken();
    AuthCache.token = null;
    AppRouter.router.go('/signin');
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
        ChangeNotifierProvider(create: (_) => TpoDashboardViewModel()),
        ChangeNotifierProvider(
          create: (_) => HodDashboardViewModel()..loadDashboard(),
        ),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => OrganizationViewModel()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
