import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_scenarios_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../screens/scenario_list_screen.dart';
import '../screens/scenario_play_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    navigatorKey: _rootKey,
    refreshListenable: auth,
    initialLocation: '/home',
    redirect: (context, state) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final loc = state.matchedLocation;
      final public = loc == '/login' || loc == '/register';
      if (!auth.isAuthenticated && !public) {
        return '/login';
      }
      if (auth.isAuthenticated && public) {
        return '/home';
      }
      if (loc.startsWith('/admin') && !auth.isAdmin) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/scenarios',
        builder: (context, state) => const ScenarioListScreen(),
      ),
      GoRoute(
        path: '/scenarios/:id/play',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ScenarioPlayScreen(scenarioId: id);
        },
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/scenarios',
        builder: (context, state) => const AdminScenariosScreen(),
      ),
    ],
  );
}
