/// No-op on non-web platforms.
Future<void> prepareLoginFieldsForBrowser() async {}

Future<void> onLoginSuccessForBrowser({
  required String email,
  required String password,
}) async {}
