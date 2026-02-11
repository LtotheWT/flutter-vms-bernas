class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    required this.ccn,
  });

  final String baseUrl;
  final String ccn;

  factory ApiConfig.fromEnvironment() {
    return const ApiConfig(
      baseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://103.170.207.30',
      ),
      ccn: String.fromEnvironment(
        'API_CCN',
        defaultValue: 'string',
      ),
    );
  }
}
