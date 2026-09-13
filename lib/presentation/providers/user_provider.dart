import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('Must be overridden with ProviderScope');
});

class UserPreferencesState {
  final List<String> selectedPlatforms;
  final String selectedModel;
  final bool onboardingComplete;
  final List<SearchHistoryItem> searchHistory;
  final Map<int, FeedbackType> feedback;
  final List<int> excludedTitles;

  const UserPreferencesState({this.selectedPlatforms = const ['Netflix', 'Prime Video', 'Disney+'], this.selectedModel = 'meta-llama/llama-3.1-8b-instruct:free', this.onboardingComplete = false, this.searchHistory = const [], this.feedback = const {}, this.excludedTitles = const []});

  UserPreferencesState copyWith({List<String>? selectedPlatforms, String? selectedModel, bool? onboardingComplete, List<SearchHistoryItem>? searchHistory, Map<int, FeedbackType>? feedback, List<int>? excludedTitles}) {
    return UserPreferencesState(selectedPlatforms: selectedPlatforms ?? this.selectedPlatforms, selectedModel: selectedModel ?? this.selectedModel, onboardingComplete: onboardingComplete ?? this.onboardingComplete, searchHistory: searchHistory ?? this.searchHistory, feedback: feedback ?? this.feedback, excludedTitles: excludedTitles ?? this.excludedTitles);
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferencesState> {
  final LocalStorageService _storage;
  UserPreferencesNotifier(this._storage) : super(const UserPreferencesState()) { _loadPreferences(); }

  Future<void> _loadPreferences() async {
    final platforms = await _storage.getSelectedPlatforms();
    final model = await _storage.getSelectedModel();
    final onboarding = await _storage.isOnboardingComplete();
    final history = await _storage.getSearchHistory();
    final feedbackMap = await _storage.getAllFeedback();
    final excluded = await _storage.getExcludedTitles();
    state = state.copyWith(selectedPlatforms: platforms, selectedModel: model, onboardingComplete: onboarding, searchHistory: history, feedback: feedbackMap, excludedTitles: excluded);
  }

  Future<void> updatePlatforms(List<String> platforms) async { await _storage.saveSelectedPlatforms(platforms); state = state.copyWith(selectedPlatforms: platforms); }
  Future<void> togglePlatform(String platform) async { final current = List<String>.from(state.selectedPlatforms); if (current.contains(platform)) { current.remove(platform); } else { current.add(platform); } await updatePlatforms(current); }
  Future<void> updateModel(String modelId) async { await _storage.saveSelectedModel(modelId); state = state.copyWith(selectedModel: modelId); }
  Future<void> completeOnboarding() async { await _storage.markOnboardingComplete(); state = state.copyWith(onboardingComplete: true); }

  Future<void> addToHistory({required String query, required List<String> platforms, int resultCount = 0}) async {
    final item = SearchHistoryItem(query: query, platforms: platforms, timestamp: DateTime.now(), resultCount: resultCount);
    await _storage.addToHistory(item);
    final history = await _storage.getSearchHistory();
    state = state.copyWith(searchHistory: history);
  }

  Future<void> clearHistory() async { await _storage.clearHistory(); state = state.copyWith(searchHistory: []); }
  Future<void> saveFeedback(int movieId, FeedbackType type) async { await _storage.saveFeedback(movieId, type); final feedbackMap = await _storage.getAllFeedback(); state = state.copyWith(feedback: feedbackMap); }
  Future<void> removeFeedback(int movieId) async { await _storage.removeFeedback(movieId); final feedbackMap = await _storage.getAllFeedback(); state = state.copyWith(feedback: feedbackMap); }
  FeedbackType getFeedback(int movieId) { return state.feedback[movieId] ?? FeedbackType.none; }
  Future<void> addExcludedTitle(int movieId) async { await _storage.addExcludedTitle(movieId); final excluded = await _storage.getExcludedTitles(); state = state.copyWith(excludedTitles: excluded); }
  Future<void> removeExcludedTitle(int movieId) async { await _storage.removeExcludedTitle(movieId); final excluded = await _storage.getExcludedTitles(); state = state.copyWith(excludedTitles: excluded); }
  bool isTitleExcluded(int movieId) { return state.excludedTitles.contains(movieId); }
  Future<void> clearExclusions() async { await _storage.clearExclusions(); state = state.copyWith(excludedTitles: []); }
  Future<void> clearAll() async { await _storage.clearAll(); state = const UserPreferencesState(); }
}

final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>((ref) {
  final storage = ref.watch(localStorageProvider);
  return UserPreferencesNotifier(storage);
});

final feedbackStatsProvider = FutureProvider<FeedbackStats>((ref) async {
  final storage = ref.watch(localStorageProvider);
  return await storage.getFeedbackStats();
});