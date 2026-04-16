import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'routes/app_router.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiService();
  final auth = AuthProvider(api);
  await auth.hydrate();
  final router = createRouter(auth);
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
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
    return MaterialApp.router(
      title: 'Cybersecurity Awareness Training',
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
