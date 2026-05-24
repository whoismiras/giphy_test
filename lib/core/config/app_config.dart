abstract final class AppConfig {
  static const String giphyBaseUrl = 'https://api.giphy.com/v1';

  // Paste your Giphy API key here, or pass it as a --dart-define
  // (see README). The key is shared with reviewers separately.
  static const String _fallbackApiKey = '';

  static const String giphyApiKey = String.fromEnvironment(
    'GIPHY_API_KEY',
    // ignore: avoid_redundant_argument_values
    defaultValue: _fallbackApiKey,
  );

  static bool get hasApiKey => giphyApiKey.isNotEmpty;

  static const int pageSize = 25;
  static const Duration searchDebounce = Duration(milliseconds: 400);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
