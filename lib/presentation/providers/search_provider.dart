import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie_model.dart';
import '../services/recommendation_service.dart';
import '../services/ai_service.dart';
import '../../core/constants/ai_constants.dart';

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService();
});

class SearchState {
  final String query;
  final List<MovieModel> results;
  final List<RecommendationResultItem> recommendations;
  final SearchCriteria? criteria;
  final bool isLoading;
  final String? error;
  final List<String> selectedPlatforms;
  final String selectedModel;

  const SearchState({this.query = '', this.results = const [], this.recommendations = const [], this.criteria, this.isLoading = false, this.error, this.selectedPlatforms = const ['Netflix', 'Prime Video', 'Disney+'], this.selectedModel = 'meta-llama/llama-3.1-8b-instruct:free'});

  SearchState copyWith({String? query, List<MovieModel>? results, List<RecommendationResultItem>? recommendations, SearchCriteria? criteria, bool? isLoading, String? error, List<String>? selectedPlatforms, String? selectedModel}) {
    return SearchState(query: query ?? this.query, results: results ?? this.results, recommendations: recommendations ?? this.recommendations, criteria: criteria ?? this.criteria, isLoading: isLoading ?? this.isLoading, error: error, selectedPlatforms: selectedPlatforms ?? this.selectedPlatforms, selectedModel: selectedModel ?? this.selectedModel);
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final RecommendationService _recommendationService;
  SearchNotifier(this._recommendationService) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) { state = state.copyWith(error: 'Scrivi cosa vuoi guardare'); return; }
    state = state.copyWith(query: query, isLoading: true, error: null, recommendations: []);
    try {
      final result = await _recommendationService.getRecommendations(userRequest: query, selectedPlatforms: state.selectedPlatforms);
      if (result.success) {
        state = state.copyWith(recommendations: result.top3, criteria: result.criteria, results: result.top3.map((r) => r.movie).toList(), isLoading: false);
      } else { state = state.copyWith(error: result.error, isLoading: false); }
    } catch (e) { state = state.copyWith(error: 'Errore nella ricerca: \$e', isLoading: false); }
  }

  void updatePlatforms(List<String> platforms) { state = state.copyWith(selectedPlatforms: platforms); }
  void updateModel(String modelId) { state = state.copyWith(selectedModel: modelId); }
  void clearSearch() { state = const SearchState(); }
  void clearError() { state = state.copyWith(error: null); }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final service = ref.watch(recommendationServiceProvider);
  return SearchNotifier(service);
});

final availableModelsProvider = Provider<List<AiModel>>((ref) { return AiConstants.allModels; });
final selectedModelProvider = StateProvider<String>((ref) { return AiConstants.defaultModelId; });