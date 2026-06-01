import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'widgets/notification_toast_host.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiService();
  final dashboard = DashboardProvider();
  final notifications = NotificationProvider(api);
  final themeProvider = ThemeProvider();
  await themeProvider.hydrate();
  final auth = AuthProvider(
    api,
    onSessionCleared: () {
      dashboard.reset();
      notifications.reset();
    },
  );
  await auth.hydrate();
  if (auth.isAuthenticated) {
    await notifications.load();
  }
  final router = createRouter(auth);
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<DashboardProvider>.value(value: dashboard),
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider<NotificationProvider>.value(value: notifications),
      ],
      child: SocialEngineeringApp(router: router),
    ),
  );
}

class SocialEngineeringApp extends StatelessWidget {
  const SocialEngineeringApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final themeData = buildAppTheme(isDark: themeProvider.isDark);
        return AnimatedTheme(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          data: themeData,
          child: MaterialApp.router(
            title: 'Cybersecurity Awareness Training',
            theme: themeData,
            routerConfig: router,
            builder: (context, child) {
              return NotificationToastHost(
                child: child ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}
