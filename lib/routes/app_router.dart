import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:gyaanplant/viewmodels/tpo_viewmodels/tpo_dashboard_viewmodel.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/student_viewmodel.dart';
import 'package:gyaanplant/viewmodels/mentor_viewmodel/mentor_dashboard_viewmodel.dart';

import 'package:gyaanplant/views/auth/screens/sign_in_screen.dart';
import 'package:gyaanplant/views/auth/screens/sign_up_screen.dart';
import 'package:gyaanplant/views/auth/screens/forgot_password_screen.dart';
import 'package:gyaanplant/views/student_role/role_/screens/role_screen.dart';
import 'package:gyaanplant/views/student_role/student/widgets/leaderboard_view.dart';
import 'package:gyaanplant/views/shells/student_shell.dart';
import 'package:gyaanplant/views/shells/hod_shell.dart';
import 'package:gyaanplant/views/shells/tpo_shell.dart';
import 'package:gyaanplant/views/tpo_role/student/screens/student_screen.dart';
import 'package:gyaanplant/views/mentor/dashboard/screens/mentor_dashboard_screen.dart';
import 'package:gyaanplant/views/mentor/bookings/screens/booking_screen.dart';
import 'package:gyaanplant/views/mentor/sessions/screens/sessions_screen.dart';
import 'package:gyaanplant/views/mentor/earnings/screens/earnings_screen.dart';
import 'package:gyaanplant/views/mentor/profile/screens/mentor_profile_screen.dart';

import '../data/services/local_storage_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/role',
    debugLogDiagnostics: true,

    redirect: (context, state) async {
      final token = await LocalStorageService.getToken();
      final role = await LocalStorageService.getRole();
      final location = state.uri.toString();

      print(
        "🔄 ROUTER: Checking redirect - token=${token != null}, role=$role, location=$location",
      );

      // If user is logged in (has token) and on auth/role screens, redirect to dashboard
      if (token != null && role != null) {
        if (location == '/' || location == '/signup' || location == '/role') {
          print(
            "🔄 ROUTER: Redirecting logged-in user from $location to dashboard",
          );
          switch (role) {
            case 'student':
              return '/student-dashboard';
            case 'tpo':
              return '/tpo-dashboard';
            case 'hod':
              return '/overview';
            case 'mentor':
              return '/mentor-dashboard';
            default:
              return '/role';
          }
        }
      }

      // If user has role but no token, they need to sign in (but prevent loop)
      if (token == null && role != null && location == '/role') {
        print("🔄 ROUTER: User has role but no token - redirecting to sign in");
        return '/';
      }

      // If user is not logged in and has no role, go to role screen
      // But if they have a role, let them stay on sign-in screen
      if (token == null && role == null && location != '/role') {
        print("🔄 ROUTER: Redirecting to role screen (no role selected)");
        return '/role';
      }

      print("🔄 ROUTER: No redirect needed");
      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
      ),

      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: '/role',
        name: 'role',
        builder: (context, state) => const RoleScreen(),
      ),

      // STUDENT SHELL (tabs managed internally via IndexedStack + StudentTabController)
      GoRoute(
        path: '/student-dashboard',
        builder: (context, state) => const StudentShell(),
      ),

      // HOD SHELL (tabs managed internally via IndexedStack)
      GoRoute(path: '/overview', builder: (context, state) => const HODShell()),

      // TPO SHELL — provide TPO-specific VMs above the shell
      GoRoute(
        path: '/tpo-dashboard',
        builder: (context, state) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TpoDashboardViewModel()),
            ChangeNotifierProvider(create: (_) => StudentViewModel()),
          ],
          child: const TPOShell(),
        ),
      ),

      // Sub-screen pushed on top of student shell (not a tab)
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardView(),
      ),

      // Standalone students screen (for direct access outside TPO shell)
      GoRoute(
        path: '/students',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => StudentViewModel(),
          child: const StudentScreen(),
        ),
      ),

      // MENTOR
      GoRoute(
        path: '/mentor-dashboard',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => MentorDashboardViewModel(),
          child: const MentorDashboardScreen(),
        ),
      ),

      GoRoute(
        path: '/mentor-bookings',
        builder: (context, state) => const BookingsScreen(),
      ),

      GoRoute(
        path: '/mentor-sessions',
        builder: (context, state) => const SessionsScreen(),
      ),

      GoRoute(
        path: '/mentor-earnings',
        builder: (context, state) => const EarningsScreen(),
      ),

      GoRoute(
        path: '/mentor-profile',
        builder: (context, state) => const MentorProfileScreen(),
      ),
    ],
  );
}
