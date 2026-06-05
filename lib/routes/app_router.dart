import 'package:go_router/go_router.dart';
import 'package:gyaanplant/views/student_role/learn/screens/course_details_screen.dart';
import 'package:gyaanplant/views/student_role/learn/screens/my_courses_screen.dart';
import 'package:gyaanplant/views/HOD_role/depts/screens/department_details_screen.dart';
import 'package:gyaanplant/viewmodels/HOD_viewmodel/department_details_viewmodel.dart';
import 'package:gyaanplant/views/student_role/student/widgets/student_notification_screen.dart';
import 'package:provider/provider.dart';

import 'package:gyaanplant/viewmodels/tpo_viewmodels/tpo_dashboard_viewmodel.dart';
import 'package:gyaanplant/viewmodels/tpo_viewmodels/student_viewmodel.dart';
import 'package:gyaanplant/viewmodels/mentor_viewmodel/mentor_dashboard_viewmodel.dart';

import 'package:gyaanplant/views/auth/screens/sign_in_screen.dart';
import 'package:gyaanplant/views/auth/screens/sign_up_screen.dart';
import 'package:gyaanplant/views/auth/screens/forgot_password_screen.dart';
import 'package:gyaanplant/views/auth/screens/splash_screen.dart';
import 'package:gyaanplant/views/student_role/role_/screens/role_screen.dart';
import 'package:gyaanplant/views/student_role/support/screens/support_screen.dart';
import 'package:gyaanplant/views/student_role/support/screens/ticket_details_screen.dart';
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
import '../network/auth_cache.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    redirect: (context, state) async {
      // DEVELOPMENT-ONLY BYPASS
      // Set devBypass = true to bypass login/signup and go straight to Student Dashboard on launch.
      // Set to false to restore original login/registration routing.
      const bool devBypass = false;

      var token = await LocalStorageService.getToken();
      if (token == 'mock_dev_token') {
        print(" ROUTER: Found old mock_dev_token. Clearing session for a fresh login.");
        await LocalStorageService.clearToken();
        await LocalStorageService.removeRole();
        AuthCache.token = null;
        token = null;
      }
      final role = devBypass ? 'student' : await LocalStorageService.getRole();
      final location = state.uri.toString();

      final isLoggedIn = devBypass ? true : (token != null && token.isNotEmpty);

      print("🔄 ROUTER: token=$isLoggedIn role=$role location=$location");

      // NOT LOGGED IN → allow only auth screens
      if (!isLoggedIn) {
        const authPaths = {'/role', '/signin', '/', '/signup', '/forgot-password', '/splash'};
        return authPaths.contains(location) ? null : '/role';
      }

      // LOGGED IN → prevent going to auth screens
      if (location == '/' ||
          location == '/signin' ||
          location == '/signup' ||
          location == '/forgot-password' ||
          location == '/role') {
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
            if (location == '/role') return null; // Avoid infinite redirect loop
            return '/role';
        }
      }

      return null;
    },

    routes: [
      /// SPLASH
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      ///  AUTH
      GoRoute(
        path: '/',
        name: 'root',
        redirect: (context, state) => '/splash',
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
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/support/ticket/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TicketDetailsScreen(ticketId: id);
        },
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

      ///  HOD
      GoRoute(
        path: '/overview',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => StudentViewModel(),
          child: const HODShell(),
        ),
      ),
      // Department Details for HOD role
      GoRoute(
        path: '/department/:departmentId',
        builder: (context, state) {
          final departmentId = state.pathParameters['departmentId']!;
          return ChangeNotifierProvider(
            create: (_) => DepartmentDetailsViewModel(),
            child: DepartmentDetailsScreen(departmentId: departmentId),
          );
        },
      ),

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
