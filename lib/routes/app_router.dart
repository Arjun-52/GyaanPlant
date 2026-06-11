import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/auth_viewmodel.dart';
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

      // NOT LOGGED IN → allow only auth screens & oauth callbacks
      if (!isLoggedIn) {
        final path = state.uri.path;
        print("🔄 ROUTER (Not Logged In): Checking access to path=$path");
        const authPaths = {
          '/role',
          '/signin',
          '/',
          '/signup',
          '/forgot-password',
          '/splash',
          '/auth/success',
          '/auth/signup'
        };
        return authPaths.contains(path) ? null : '/role';
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
        path: '/auth/success',
        name: 'authSuccess',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          final encodedUser = state.uri.queryParameters['user'];

          print("🌐 GoRouter incoming deep link '/auth/success': token=$token, user=$encodedUser");

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (token != null && token.isNotEmpty && encodedUser != null) {
              try {
                final userData = jsonDecode(Uri.decodeComponent(encodedUser));
                final roleStr = userData['role']?.toString().toLowerCase() ?? 'student';

                print("✅ [DeepLink Success] Saving Credentials. Token=$token, Role=$roleStr, UserData=$userData");

                // Save credentials in cache and local storage
                AuthCache.token = token;
                AuthCache.role = roleStr;
                await LocalStorageService.saveToken(token);
                await LocalStorageService.saveRole(roleStr);
                await LocalStorageService.saveUser(userData);

                print("🚀 [DeepLink Success] Credentials saved. Redirecting to root /");
                AppRouter.router.go('/');
              } catch (e) {
                print("💥 [DeepLink Success] Error parsing success redirect: $e");
              }
            } else {
              print("💥 [DeepLink Success] Missing token or user parameter.");
            }
          });

          return const Scaffold(
            backgroundColor: Color(0xFF020B08),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00E676)),
            ),
          );
        },
      ),

      GoRoute(
        path: '/auth/signup',
        name: 'authSignup',
        builder: (context, state) {
          final tempToken = state.uri.queryParameters['tempToken'];
          final email = state.uri.queryParameters['email'];
          final name = state.uri.queryParameters['name'];
          final picture = state.uri.queryParameters['picture'];

          print("🌐 GoRouter incoming deep link '/auth/signup': tempToken=$tempToken, email=$email, name=$name");

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (tempToken != null && tempToken.isNotEmpty) {
              try {
                final decodedName = Uri.decodeComponent(name ?? '');
                final decodedPicture = picture != null ? Uri.decodeComponent(picture) : null;

                print("✅ [DeepLink Signup] Prefilling registration. TempToken=$tempToken, Name=$decodedName, Email=$email");

                final vm = Provider.of<AuthViewModel>(context, listen: false);
                vm.prefillGoogleData(
                  name: decodedName,
                  email: email ?? '',
                  tempToken: tempToken,
                  picture: decodedPicture,
                );

                print("🚀 [DeepLink Signup] Prefilled state updated. Redirecting to /signup");
                AppRouter.router.go('/signup');
              } catch (e) {
                print("💥 [DeepLink Signup] Error parsing signup redirect: $e");
              }
            } else {
              print("💥 [DeepLink Signup] Missing tempToken parameter.");
            }
          });

          return const Scaffold(
            backgroundColor: Color(0xFF020B08),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00E676)),
            ),
          );
        },
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
