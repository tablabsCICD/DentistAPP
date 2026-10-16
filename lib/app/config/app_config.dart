/// Application environment configuration
class AppConfig {
  final String appName;
  final String apiBaseUrl;
  final bool isProduction;
  final bool useMockData;

  const AppConfig({
    required this.appName,
    required this.apiBaseUrl,
    this.isProduction = false,
    this.useMockData = true,
  });

  static AppConfig? _instance;
  static AppConfig get instance =>
      _instance ?? const AppConfig(appName: 'DentFlow AI', apiBaseUrl: 'https://api.dentflow.ai/v1');

  static void initialize(AppConfig config) {
    _instance = config;
  }
}
