import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/services/student_services/local_storage_service.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/tpo_dashboard_viewmodel.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/student_viewmodel.dart';

import 'package:gyaanplant/views/auth/screens/sign_in_screen.dart';
import 'package:gyaanplant/views/auth/screens/sign_up_screen.dart';

import 'package:gyaanplant/views/student_role/Test_/screens/test_screen.dart';
import 'package:gyaanplant/views/student_role/jobs/screens/job_screen.dart';
import 'package:gyaanplant/views/student_role/profile/screens/profile_screen.dart';
import 'package:gyaanplant/views/student_role/role_/screens/role_screen.dart';
import 'package:gyaanplant/views/student_role/student/screens/student_dashboard.dart';
import 'package:gyaanplant/views/student_role/learn/screens/learn_screen.dart';
import 'package:gyaanplant/views/HOD_role/overview/screens/overview_screen.dart';
import 'package:gyaanplant/views/HOD_role/depts/screens/departments_screen.dart';
import 'package:gyaanplant/views/HOD_role/analytics/screens/analytics_screen.dart';
import 'package:gyaanplant/views/HOD_role/naac/screens/naac_screen.dart';
import 'package:gyaanplant/views/student_role/student/widgets/leaderboard_view.dart';
import 'package:gyaanplant/views/tpo_role/home/screens/tpo_home_screen.dart';
import 'package:gyaanplant/views/tpo_role/reports/screens/reports_screen.dart';
import 'package:gyaanplant/views/tpo_role/settings/screens/settings_screen.dart';
import 'package:gyaanplant/views/tpo_role/student/screens/student_screen.dart';
import 'package:gyaanplant/views/tpo_role/Drives/screens/drive_screen.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',

    redirect: (context, state) async {
      final token = await LocalStorageService.getToken();
      final isLoggedIn = token != null;

      final location = state.uri.toString();

      //  PUBLIC ROUTES (allowed without login)
      final isPublicRoute = location == '/' || location == '/signup';

      //  If NOT logged in → block private routes
      if (!isLoggedIn && !isPublicRoute) {
        return '/';
      }

      //  If logged in → prevent going back to login/signup
      if (isLoggedIn && (location == '/' || location == '/signup')) {
        return '/role';
      }

      return null;
    },

    routes: [
      //  AUTH ROUTES
      GoRoute(
        path: '/',
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
      ),

      GoRoute(
        path: '/students',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => StudentViewModel(),
          child: const StudentScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      //  ROLE SELECTION
      GoRoute(
        path: '/role',
        name: 'role',
        builder: (context, state) => const RoleScreen(),
      ),

      //  HOD OVERVIEW
      GoRoute(
        path: '/overview',
        name: 'overview',
        builder: (context, state) => FutureBuilder<String?>(
          future: LocalStorageService.getToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data != null) {
              return OverViewScreen(token: snapshot.data!);
            }
            return const Center(child: Text('Error: No token found'));
          },
        ),
      ),

      //  HOD DEPARTMENTS
      GoRoute(
        path: '/depts',
        name: 'depts',
        builder: (context, state) => FutureBuilder<String?>(
          future: LocalStorageService.getToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data != null) {
              return DepartmentsScreen(token: snapshot.data!);
            }
            return const Center(child: Text('Error: No token found'));
          },
        ),
      ),

      //  HOD ANALYTICS
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => AnalyticsScreen(),
      ),

      //  HOD NAAC
      GoRoute(
        path: '/naac',
        name: 'naac',
        builder: (context, state) => const NaacScreen(),
      ),

      //  DASHBOARD
      GoRoute(
        path: '/student-dashboard',
        builder: (context, state) => const StudentDashboard(),
      ),

      //  LEARN
      GoRoute(path: '/learn', builder: (context, state) => const LearnScreen()),

      //  LEADERBOARD
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardView(),
      ),

      //  JOBS
      GoRoute(path: '/jobs', builder: (context, state) => const JobScreen()),

      //  PROFILE
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      //  TPO DASHBOARD
      GoRoute(
        path: '/tpo-dashboard',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => TpoDashboardViewModel(),
          child: const TPODashboard(),
        ),
      ),

      //  DRIVES
      GoRoute(
        path: '/drives',
        builder: (context, state) => const DrivesScreen(),
      ),

      //  REPORTS
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),

      //  SETTINGS
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // TEST
      GoRoute(path: '/test', builder: (context, state) => const TestScreen()),
    ],
  );
}
