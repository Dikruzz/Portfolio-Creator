class AppConfig {
  const AppConfig({
    required this.appName,
    required this.enableFirebase,
    required this.aiEndpoint,
  });

  factory AppConfig.development() {
    return const AppConfig(
      appName: 'Portique',
      enableFirebase: false,
      aiEndpoint: 'https://example.cloudfunctions.net/generatePortfolioCopy',
    );
  }

  final String appName;
  final bool enableFirebase;
  final String aiEndpoint;
}

const appConfig = AppConfig(
  appName: 'Portique',
  enableFirebase: false,
  aiEndpoint: 'https://example.cloudfunctions.net/generatePortfolioCopy',
);
