import 'package:go_router/go_router.dart';
import 'package:gyaanplant/viewmodels/student_viewmodel/test_viewmodel.dart';

import 'package:gyaanplant/views/auth/screens/sign_in_screen.dart';
import 'package:gyaanplant/views/auth/screens/sign_up_screen.dart';

import 'package:gyaanplant/views/student_role/Test_/screens/test_screen.dart';
import 'package:gyaanplant/views/student_role/jobs/screens/job_screen.dart';
import 'package:gyaanplant/views/student_role/profile/screens/profile_screen.dart';
import 'package:gyaanplant/views/student_role/role_/screens/role_screen.dart';
import 'package:gyaanplant/views/student_role/student/screens/student_dashboard.dart';
import 'package:gyaanplant/views/student_role/learn/screens/learn_screen.dart';
import 'package:gyaanplant/views/student_role/student/widgets/leaderboard_view.dart';
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
        builder: (context, state) => const StudentDashboard(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const StudentDashboard(),
      ),
      GoRoute(path: '/learn', builder: (context, state) => const LearnScreen()),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardView(),
      ),
      GoRoute(path: '/jobs', builder: (context, state) => const JobScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
