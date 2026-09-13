class AppConstants {
  static const String appName = 'TriplePick';
  static const String appTagline = 'Riguarda la scelta, non il catalogo';
  static const int maxRecommendations = 3;
  static const int maxSearchResults = 20;
  static const int maxRecentSearches = 10;
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration aiTimeout = Duration(seconds: 60);
  static const String defaultCountry = 'IT';
  static const List<String> supportedPlatforms = [
    'Netflix', 'Prime Video', 'Disney+', 'Apple TV+', '.now', 'Infinity',
  ];
  static const String recentSearchesKey = 'recent_searches';
  static const String userPreferencesKey = 'user_preferences';
  static const String excludedTitlesKey = 'excluded_titles';
}