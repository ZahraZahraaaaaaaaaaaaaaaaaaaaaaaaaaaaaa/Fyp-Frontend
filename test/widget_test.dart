import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:social_engineering_training/main.dart';
import 'package:social_engineering_training/providers/auth_provider.dart';
import 'package:social_engineering_training/routes/app_router.dart';
import 'package:social_engineering_training/services/api_service.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    final api = ApiService();
    final auth = AuthProvider(api);
    final router = createRouter(auth);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ApiService>.value(value: api),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ],
        child: SocialEngineeringApp(router: router),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
