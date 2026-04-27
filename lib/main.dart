import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_router.dart';
import 'services/auth_service.dart';

import 'viewmodels/student_viewmodel/auth_viewmodel.dart';
import 'viewmodels/student_viewmodel/dashboard_viewmodel.dart';
import 'viewmodels/student_viewmodel/learning_viewmodel.dart';
import 'viewmodels/student_viewmodel/test_viewmodel.dart';
import 'viewmodels/student_viewmodel/job_viewmodel.dart';
import 'viewmodels/tpo_viewmodels/drives_viewmodel.dart'; // 🔥 ADD THIS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.loadToken();
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
        ChangeNotifierProvider(create: (_) => LearningViewModel()),
        ChangeNotifierProvider(create: (_) => TestViewModel()),
        ChangeNotifierProvider(create: (_) => JobViewModel()),
        ChangeNotifierProvider(create: (_) => DrivesViewModel()), // 🔥 ADD THIS
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
