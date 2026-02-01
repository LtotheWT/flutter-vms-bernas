import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../app/app_shell.dart';
import '../pages/home_page.dart';
import '../pages/invitation_add_page.dart';
import '../pages/invitation_listing_page.dart';
import '../pages/login_page.dart';
import '../pages/report_page.dart';
import '../pages/splash_page.dart';
import '../pages/visitor_walk_in_page.dart';
import '../pages/visitor_check_in_page.dart';
import '../pages/visitor_log_page.dart';
import '../pages/employee_log_page.dart';

const String loginRouteName = 'login';
const String loginRoutePath = '/login';
const String homeRouteName = 'home';
const String homeRoutePath = '/home';
const String reportRouteName = 'report';
const String reportRoutePath = '/report';
const String visitorLogRouteName = 'visitor_log';
const String visitorLogRoutePath = '/report/visitor-log';
const String employeeLogRouteName = 'employee_log';
const String employeeLogRoutePath = '/report/employee-log';
const String splashRouteName = 'splash';
const String splashRoutePath = '/';
const String invitationAddRouteName = 'invitation_add';
const String invitationAddRoutePath = '/invitation/add';
const String invitationListingRouteName = 'invitation_listing';
const String invitationListingRoutePath = '/invitation/listing';
const String visitorWalkInRouteName = 'visitor_walk_in';
const String visitorWalkInRoutePath = '/visitor/walk-in';
const String visitorCheckInRouteName = 'visitor_check_in';
const String visitorCheckInRoutePath = '/visitor/check-in';
const String visitorCheckOutRouteName = 'visitor_check_out';
const String visitorCheckOutRoutePath = '/visitor/check-out';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
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
      name: invitationAddRouteName,
      path: invitationAddRoutePath,
      builder: (context, state) => const InvitationAddPage(),
    ),
    GoRoute(
      name: invitationListingRouteName,
      path: invitationListingRoutePath,
      builder: (context, state) => const InvitationListingPage(),
    ),
    GoRoute(
      name: visitorWalkInRouteName,
      path: visitorWalkInRoutePath,
      builder: (context, state) => const VisitorWalkInPage(),
    ),
    GoRoute(
      name: visitorCheckInRouteName,
      path: visitorCheckInRoutePath,
      builder: (context, state) => const VisitorCheckInPage(isCheckIn: true),
    ),
    GoRoute(
      name: visitorCheckOutRouteName,
      path: visitorCheckOutRoutePath,
      builder: (context, state) => const VisitorCheckInPage(isCheckIn: false),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: homeRouteName,
              path: homeRoutePath,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: reportRouteName,
              path: reportRoutePath,
              builder: (context, state) => const ReportPage(),
              routes: [
                GoRoute(
                  name: visitorLogRouteName,
                  path: 'visitor-log',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const VisitorLogPage(),
                ),
                GoRoute(
                  name: employeeLogRouteName,
                  path: 'employee-log',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const EmployeeLogPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
