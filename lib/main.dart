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
import 'viewmodels/tpo_viewmodels/tpo_notification_viewmodel.dart';
import 'viewmodels/student_viewmodel/notification_viewmodel.dart';
import 'viewmodels/HOD_viewmodel/hod_dashboard_viewmodel.dart';
import 'viewmodels/student_viewmodel/organization_viewmodel.dart';
import 'viewmodels/mentor_viewmodel/mentor_earnings_controller.dart';
import 'core/utils/app_logger.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // 2. Initialize NetworkAPIManager
    NetworkAPIManager.initialize();
    debugPrint("Network initialized");

    // 3. Load token from LocalStorageService and populate AuthCache
    final token = await LocalStorageService.getToken();
    AuthCache.token = token;
    AuthCache.role = await LocalStorageService.getRole();
    AppLogger.info('main', '🔑 TOKEN LOADED ON STARTUP: $token');
    AppLogger.info('main', '🔑 ROLE LOADED ON STARTUP: ${AuthCache.role}');

    AuthInterceptor.onUnauthorized = () async {
      await LocalStorageService.clearToken();
      AuthCache.token = null;
      AuthCache.role = null;
      AppRouter.router.go('/signin');
    };

    // 4. Initialize notification service (FCM setup)
    await NotificationService.initialize();
    debugPrint("FCM initialized");

  } catch (e) {
    debugPrint("❌ Error during startup initialization: $e");
  }

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
        ChangeNotifierProvider(create: (_) => MentorEarningsController()),
        ChangeNotifierProvider(create: (_) => TpoNotificationViewModel()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: ThemeData(
          fontFamily: 'Gilroy-Semibold',
        ),
      ),
    );
  }
}
