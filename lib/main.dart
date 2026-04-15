import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_router.dart';
import 'viewmodels/student_viewmodel/auth_viewmodel.dart';
import 'viewmodels/student_viewmodel/dashboard_viewmodel.dart';
import 'viewmodels/student_viewmodel/test_viewmodel.dart';
import 'viewmodels/student_viewmodel/job_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        ChangeNotifierProvider(create: (_) => TestViewModel()),
        ChangeNotifierProvider(create: (_) => JobViewModel()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
