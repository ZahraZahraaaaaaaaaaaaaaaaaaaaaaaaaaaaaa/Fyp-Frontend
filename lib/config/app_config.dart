/// API base URL. Override at build time:
/// flutter run -d chrome --dart-define=API_BASE=http://localhost:5000
class AppConfig {
  static const String apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:5000',
  );
}
