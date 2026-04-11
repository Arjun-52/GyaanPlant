import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/viewmodels/test_viewmodel.dart';
import 'package:gyaanplant/views/Test-/screens/test_screen.dart';
import 'package:gyaanplant/views/auth/screens/sign_in_screen.dart';
import 'package:gyaanplant/views/auth/screens/sign_up_screen.dart';
import 'package:gyaanplant/views/role_/screens/role_screen.dart';
import 'package:gyaanplant/views/student/screens/student_dashboard.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      //  Sign In Screen
      GoRoute(
        path: '/',
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
      ),

      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text("Home Screen"))),
      ),
      GoRoute(
        path: '/test',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => TestViewModel(),
          child: const TestScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/role',
        name: 'role',
        builder: (context, state) => const RoleScreen(),
      ),
      GoRoute(
        path: '/student-dashboard',
        name: 'studentDashboard',
        builder: (context, state) => const StudentDashboard(),
      ),
    ],
  );
}
