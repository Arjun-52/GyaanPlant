import 'package:go_router/go_router.dart';

import 'package:gyaanplant/views/auth/screens/sign_in_screen.dart';
import 'package:gyaanplant/views/auth/screens/sign_up_screen.dart';
import 'package:gyaanplant/views/student_role/role_/screens/role_screen.dart';
import 'package:gyaanplant/views/student_role/student/widgets/leaderboard_view.dart';
import 'package:gyaanplant/views/shells/student_shell.dart';
import 'package:gyaanplant/views/shells/hod_shell.dart';
import 'package:gyaanplant/views/shells/tpo_shell.dart';

import '../data/services/local_storage_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',

    redirect: (context, state) async {
      final token = await LocalStorageService.getToken();
      final isLoggedIn = token != null;

      final location = state.uri.toString();

      final isPublicRoute = location == '/' || location == '/signup';

      if (!isLoggedIn && !isPublicRoute) {
        return '/';
      }

      if (isLoggedIn && (location == '/' || location == '/signup')) {
        return '/role';
      }

      return null;
    },

    routes: [
      // AUTH
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

      // ROLE SELECTION
      GoRoute(
        path: '/role',
        name: 'role',
        builder: (context, state) => const RoleScreen(),
      ),

      // STUDENT SHELL (all student tabs managed internally via IndexedStack)
      GoRoute(
        path: '/student-dashboard',
        builder: (context, state) => const StudentShell(),
      ),

      // HOD SHELL
      GoRoute(
        path: '/overview',
        builder: (context, state) => const HODShell(),
      ),

      // TPO SHELL
      GoRoute(
        path: '/tpo-dashboard',
        builder: (context, state) => const TPOShell(),
      ),

      // Sub-screen pushed on top of student shell (not a tab)
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardView(),
      ),
    ],
  );
}
