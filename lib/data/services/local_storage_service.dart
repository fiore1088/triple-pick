import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _searchHistoryKey = 'search_history';
  static const String _feedbackKey = 'feedback';
  static const String _excludedTitlesKey = 'excluded_titles';
  static const String _selectedPlatformsKey = 'selected_platforms';
  static const String _selectedModelKey = 'selected_model';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  static const int maxHistoryItems = 10;
  static const int maxExcludedTitles = 100;

  static LocalStorageService? _instance;
  static SharedPreferences? _prefs;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<List<SearchHistoryItem>> getSearchHistory() async {
    final jsonString = _prefs?.getString(_searchHistoryKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => SearchHistoryItem.fromJson(item)).toList();
    } catch (e) { return []; }
  }

  Future<void> addToHistory(SearchHistoryItem item) async {
    final history = await getSearchHistory();
    history.removeWhere((h) => h.query.toLowerCase() == item.query.toLowerCase());
    history.insert(0, item);
    if (history.length > maxHistoryItems) { history.removeRange(maxHistoryItems, history.length); }
    await _saveHistory(history);
  }

  Future<void> clearHistory() async { await _prefs?.remove(_searchHistoryKey); }

  Future<void> _saveHistory(List<SearchHistoryItem> history) async {
    final jsonList = history.map((item) => item.toJson()).toList();
    await _prefs?.setString(_searchHistoryKey, json.encode(jsonList));
  }

  Future<Map<int, FeedbackType>> getAllFeedback() async {
    final jsonString = _prefs?.getString(_feedbackKey);
    if (jsonString == null) return {};
    try {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return jsonMap.map((key, value) => MapEntry(int.parse(key), FeedbackType.values.firstWhere((e) => e.toString() == value, orElse: () => FeedbackType.none)));
    } catch (e) { return {}; }
  }

  Future<FeedbackType> getFeedback(int movieId) async {
    final allFeedback = await getAllFeedback();
    return allFeedback[movieId] ?? FeedbackType.none;
  }

  Future<void> saveFeedback(int movieId, FeedbackType type) async {
    final allFeedback = await getAllFeedback();
    allFeedback[movieId] = type;
    final jsonMap = allFeedback.map((key, value) => MapEntry(key.toString(), value.toString()));
    await _prefs?.setString(_feedbackKey, json.encode(jsonMap));
  }

  Future<void> removeFeedback(int movieId) async {
    final allFeedback = await getAllFeedback();
    allFeedback.remove(movieId);
    final jsonMap = allFeedback.map((key, value) => MapEntry(key.toString(), value.toString()));
    await _prefs?.setString(_feedbackKey, json.encode(jsonMap));
  }

  Future<FeedbackStats> getFeedbackStats() async {
    final allFeedback = await getAllFeedback();
    int likes = 0, dislikes = 0;
    for (var feedback in allFeedback.values) {
      if (feedback == FeedbackType.like) likes++;
      if (feedback == FeedbackType.dislike) dislikes++;
    }
    return FeedbackStats(likes: likes, dislikes: dislikes);
  }

  Future<List<int>> getExcludedTitles() async {
    final jsonString = _prefs?.getString(_excludedTitlesKey);
    if (jsonString == null) return [];
    try { final List<dynamic> jsonList = json.decode(jsonString); return jsonList.cast<int>(); }
    catch (e) { return []; }
  }

  Future<void> addExcludedTitle(int movieId) async {
    final excluded = await getExcludedTitles();
    if (!excluded.contains(movieId)) {
      excluded.add(movieId);
      if (excluded.length > maxExcludedTitles) { excluded.removeRange(0, excluded.length - maxExcludedTitles); }
      await _saveExcludedTitles(excluded);
    }
  }

  Future<void> removeExcludedTitle(int movieId) async {
    final excluded = await getExcludedTitles();
    excluded.remove(movieId);
    await _saveExcludedTitles(excluded);
  }

  Future<bool> isTitleExcluded(int movieId) async {
    final excluded = await getExcludedTitles();
    return excluded.contains(movieId);
  }

  Future<void> clearExclusions() async { await _prefs?.remove(_excludedTitlesKey); }

  Future<void> _saveExcludedTitles(List<int> titles) async {
    await _prefs?.setString(_excludedTitlesKey, json.encode(titles));
  }

  Future<List<String>> getSelectedPlatforms() async {
    return _prefs?.getStringList(_selectedPlatformsKey) ?? ['Netflix', 'Prime Video', 'Disney+'];
  }

  Future<void> saveSelectedPlatforms(List<String> platforms) async {
    await _prefs?.setStringList(_selectedPlatformsKey, platforms);
  }

  Future<String> getSelectedModel() async {
    return _prefs?.getString(_selectedModelKey) ?? 'meta-llama/llama-3.1-8b-instruct:free';
  }

  Future<void> saveSelectedModel(String modelId) async {
    await _prefs?.setString(_selectedModelKey, modelId);
  }

  Future<bool> isOnboardingComplete() async {
    return _prefs?.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> markOnboardingComplete() async {
    await _prefs?.setBool(_onboardingCompleteKey, true);
  }

  Future<void> clearAll() async { await _prefs?.clear(); }
}

enum FeedbackType { none, like, dislike }

class SearchHistoryItem {
  final String query;
  final List<String> platforms;
  final DateTime timestamp;
  final int resultCount;

  const SearchHistoryItem({required this.query, required this.platforms, required this.timestamp, this.resultCount = 0});

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(query: json['query'] ?? '', platforms: List<String>.from(json['platforms'] ?? []), timestamp: DateTime.parse(json['timestamp']), resultCount: json['resultCount'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'query': query, 'platforms': platforms, 'timestamp': timestamp.toIso8601String(), 'resultCount': resultCount};
  }
}

class FeedbackStats {
  final int likes;
  final int dislikes;
  const FeedbackStats({required this.likes, required this.dislikes});
  int get total => likes + dislikes;
  double get likePercentage => total > 0 ? (likes / total) * 100 : 0;
}