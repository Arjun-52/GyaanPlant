import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'network/api_manager.dart';
import 'network/interceptors/auth_interceptor.dart';
import 'routes/app_router.dart';
import 'viewmodels/student_viewmodel/auth_viewmodel.dart';
import 'viewmodels/student_viewmodel/student_tab_controller.dart';
import 'viewmodels/student_viewmodel/dashboard_viewmodel.dart';
import 'viewmodels/student_viewmodel/job_viewmodel.dart';
import 'viewmodels/student_viewmodel/leaderboard_viewmodel.dart';
import 'viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'viewmodels/student_viewmodel/test_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NetworkAPIManager.initialize();

  // On 401, clear token and redirect to sign-in
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
        ChangeNotifierProvider(create: (_) => TestViewModel()),
        ChangeNotifierProvider(create: (_) => LearningViewModel()),
        ChangeNotifierProvider(create: (_) => LeaderboardViewModel()),
        ChangeNotifierProvider(create: (_) => StudentTabController()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
