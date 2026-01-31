import 'package:go_router/go_router.dart';

import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/splash_page.dart';

const String loginRouteName = 'login';
const String loginRoutePath = '/login';
const String homeRouteName = 'home';
const String homeRoutePath = '/home';
const String splashRouteName = 'splash';
const String splashRoutePath = '/';

final GoRouter appRouter = GoRouter(
  initialLocation: splashRoutePath,
  routes: [
    GoRoute(
      name: splashRouteName,
      path: splashRoutePath,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      name: loginRouteName,
      path: loginRoutePath,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      name: homeRouteName,
      path: homeRoutePath,
      builder: (context, state) => const HomePage(),
    ),
  ],
);
