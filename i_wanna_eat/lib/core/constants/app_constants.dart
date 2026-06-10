class AppConstants {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const horizontalPadding = 16.0;
  static const spacing8 = 8.0;
  static const spacing16 = 16.0;
  static const spacing24 = 24.0;
  static const radius12 = 12.0;
  static const radius16 = 16.0;
  static const radius24 = 24.0;
}
