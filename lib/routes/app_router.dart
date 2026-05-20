import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/views/student_role/learn/screens/course_details_screen.dart';
import 'package:gyaanplant/views/student_role/learn/screens/my_courses_screen.dart';
import 'package:gyaanplant/views/student_role/student/widgets/student_notification_screen.dart';
import 'package:provider/provider.dart';

import 'package:gyaanplant/viewmodels/tpo_viewmodels/tpo_dashboard_viewmodel.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/student_viewmodel.dart';
import 'package:gyaanplant/viewmodels/mentor_viewmodel/mentor_dashboard_viewmodel.dart';

import 'package:gyaanplant/views/auth/screens/sign_in_screen.dart';
import 'package:gyaanplant/views/auth/screens/sign_up_screen.dart';
import 'package:gyaanplant/views/auth/screens/forgot_password_screen.dart';
import 'package:gyaanplant/views/auth/screens/splash_screen.dart';
import 'package:gyaanplant/views/student_role/career_roadmap/screens/ai_career_roadmap_screen.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/career_roadmap_viewmodel.dart';
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

import '../network/auth_cache.dart';
import '../data/services/local_storage_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/role',
    debugLogDiagnostics: kDebugMode,

    redirect: (context, state) async {
      // Use in-memory cache first (fast path); fall back to secure storage only
      // when the cache is cold (e.g. immediately after a cold start).
      final token = AuthCache.token ?? await LocalStorageService.getToken();
      final location = state.uri.toString();

      final isLoggedIn = token != null && token.isNotEmpty;

      if (!isLoggedIn) {
        const authPaths = {
          '/role',
          '/signin',
          '/',
          '/signup',
          '/forgot-password',
          '/splash'
        };
        return authPaths.contains(location) ? null : '/role';
      }

      // LOGGED IN → prevent going to auth / entry screens, route directly to role dashboard
      if (location == '/' ||
          location == '/signin' ||
          location == '/signup' ||
          location == '/forgot-password' ||
          location == '/role' ||
          location == '/splash') {
        final role = await LocalStorageService.getRole();
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

      return null;
    },

    routes: [
      ///  AUTH
      GoRoute(
        path: '/',
        name: 'root',
        redirect: (context, state) => '/splash',
      ),

      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/signin',
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

      ///  STUDENT
      GoRoute(
        path: '/student-dashboard',
        builder: (context, state) => const StudentShell(),
      ),
      GoRoute(
        path: '/my-courses',
        builder: (context, state) => const MyCoursesScreen(),
      ),
      GoRoute(
        path: '/course-details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CourseDetailsScreen(courseId: id);
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const StudentNotificationScreen(),
      ),
      GoRoute(
        path: '/ai-career-roadmap',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => CareerRoadmapViewModel(),
          child: const AICareerRoadmapScreen(),
        ),
      ),

      ///  HOD
      GoRoute(path: '/overview', builder: (context, state) => const HODShell()),

      ///  TPO
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

      ///  COMMON
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardView(),
      ),

      GoRoute(
        path: '/students',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => StudentViewModel(),
          child: const StudentScreen(),
        ),
      ),

      ///  MENTOR
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
