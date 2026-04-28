import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/services/student_services/local_storage_service.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/tpo_dashboard_viewmodel.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/student_viewmodel.dart';
import 'package:gyaanplant/viewmodels/mentor_viewmodel/mentor_dashboard_viewmodel.dart';

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
import 'package:gyaanplant/views/tpo_role/settings/screens/settings_screen.dart'
    as tpo_settings;
import 'package:gyaanplant/views/tpo_role/student/screens/student_screen.dart';
import 'package:gyaanplant/views/tpo_role/Drives/screens/drive_screen.dart';
import 'package:gyaanplant/views/HOD_role/settings/screens/settings_screen.dart'
    as hod_settings;
import 'package:gyaanplant/views/mentor/dashboard/screens/mentor_dashboard_screen.dart';
import 'package:gyaanplant/views/mentor/bookings/screens/booking_screen.dart';
import 'package:gyaanplant/views/mentor/sessions/screens/sessions_screen.dart';
import 'package:gyaanplant/views/mentor/earnings/screens/earnings_screen.dart';
import 'package:gyaanplant/views/mentor/profile/screens/mentor_profile_screen.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/role',
    debugLogDiagnostics: true,

    redirect: (context, state) async {
      final token = await LocalStorageService.getToken();
      final role = await LocalStorageService.getRole(); // if exists
      final isLoggedIn = token != null;

      final location = state.uri.toString();
      print("🔍 ROUTER REDIRECT CHECK: $location");
      print("🔍 IS LOGGED IN: $isLoggedIn");
      print("🔍 USER ROLE: $role");

      //  If logged in → go to role-based dashboard
      if (isLoggedIn) {
        if (location == '/' || location == '/signup' || location == '/role') {
          switch (role) {
            case 'student':
              print("🔄 STUDENT LOGGED IN - redirecting to /students");
              return '/students';
            case 'tpo':
              print("🔄 TPO LOGGED IN - redirecting to /tpo-dashboard");
              return '/tpo-dashboard';
            case 'hod':
              print("🔄 HOD LOGGED IN - redirecting to /overview");
              return '/overview';
            case 'mentor':
              print("🔄 MENTOR LOGGED IN - redirecting to /mentor-dashboard");
              return '/mentor-dashboard';
            default:
              print("🔄 UNKNOWN ROLE - redirecting to /role");
              return '/role'; // fallback safety
          }
        }
        return null;
      }

      //  If NOT logged in
      //  Step 1: No role selected → go to role screen
      if (role == null && location != '/role') {
        print("� NO ROLE SELECTED - redirecting to /role");
        return '/role';
      }

      //  Step 2: Role selected → allow login/signup
      if (role != null && location == '/role') {
        print("🔄 ROLE SELECTED - redirecting to /");
        return '/';
      }

      //  Allow public routes
      print("✅ ALLOWING NAVIGATION TO: $location");
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
        builder: (context, state) => const OverViewScreen(),
      ),

      //  HOD DEPARTMENTS
      GoRoute(
        path: '/depts',
        name: 'depts',
        builder: (context, state) => const DepartmentsScreen(),
      ),

      //  HOD ANALYTICS
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
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

      //  TPO SETTINGS
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const tpo_settings.SettingsScreen(),
      ),

      //  HOD SETTINGS
      GoRoute(
        path: '/hod-settings',
        name: 'hod-settings',
        builder: (context, state) => const hod_settings.SettingsScreen(),
      ),

      //  MENTOR DASHBOARD
      GoRoute(
        path: '/mentor-dashboard',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => MentorDashboardViewModel(),
          child: const MentorDashboardScreen(),
        ),
      ),

      // MENTOR BOOKINGS
      GoRoute(
        path: '/mentor-bookings',
        builder: (context, state) => const BookingsScreen(),
      ),

      // MENTOR SESSIONS
      GoRoute(
        path: '/mentor-sessions',
        builder: (context, state) => const SessionsScreen(),
      ),

      // MENTOR EARNINGS
      GoRoute(
        path: '/mentor-earnings',
        builder: (context, state) => const EarningsScreen(),
      ),

      // MENTOR PROFILE
      GoRoute(
        path: '/mentor-profile',
        builder: (context, state) => const MentorProfileScreen(),
      ),

      // TEST
      GoRoute(path: '/test', builder: (context, state) => const TestScreen()),
    ],
  );
}
