import '../models/movie_model.dart';
import '../services/ai_service.dart';
import '../services/tmdb_service.dart';
import '../repositories/movie_repository.dart';

class RecommendationService {
  final AiService _aiService;
  final MovieRepository _movieRepository;

  RecommendationService({AiService? aiService, MovieRepository? movieRepository})
      : _aiService = aiService ?? AiService(),
        _movieRepository = movieRepository ?? MovieRepository();

  Future<RecommendationResult> getRecommendations({required String userRequest, required List<String> selectedPlatforms}) async {
    try {
      final criteria = await _aiService.parseUserRequest(userRequest);
      final genreIds = AiConstants.getGenreIds(criteria.genres);

      List<MovieModel> candidates;
      if (genreIds.isNotEmpty) {
        candidates = await _movieRepository.getRecommendations(genreIds: genreIds, maxResults: 30);
      } else {
        candidates = await _movieRepository.searchContent(query: criteria.query.isNotEmpty ? criteria.query : userRequest, maxResults: 30);
      }

      candidates = candidates.where((movie) {
        if (selectedPlatforms.isEmpty) return true;
        return selectedPlatforms.contains(movie.platformName);
      }).toList();

      candidates = _applyFilters(candidates, criteria);

      if (candidates.isEmpty) {
        return RecommendationResult(success: false, error: 'Nessun titolo trovato per i criteri selezionati', criteria: criteria);
      }

      final candidatesJson = candidates.map((m) => {
        'id': m.id, 'title': m.title, 'overview': m.overview ?? '',
        'genres': m.genreIds.join(', '), 'vote_average': m.voteAverage,
        'popularity': m.popularity, 'release_date': m.releaseDate,
        'platform_name': m.platformName, 'runtime': 0,
      }).toList();

      final recommendations = await _aiService.selectTop3(userRequest: userRequest, candidates: candidatesJson, criteria: criteria);

      final results = recommendations.map((rec) {
        final movie = candidates.firstWhere((m) => m.id == rec.movieId, orElse: () => MovieModel(id: rec.movieId, title: rec.title));
        return RecommendationResultItem(movie: movie, reason: rec.reason, confidence: rec.confidence);
      }).toList();

      return RecommendationResult(success: true, items: results, criteria: criteria, totalCandidates: candidates.length);
    } catch (e) {
      return RecommendationResult(success: false, error: 'Errore nel recupero raccomandazioni: $e');
    }
  }

  List<MovieModel> _applyFilters(List<MovieModel> movies, SearchCriteria criteria) {
    return movies.where((movie) {
      if (criteria.excludeViolence) {
        final overview = (movie.overview ?? '').toLowerCase();
        if (overview.contains('violenza') || overview.contains('splatter') || overview.contains('gore')) return false;
      }
      if (criteria.excludeHorror) { if (movie.genreIds.contains(27)) return false; }
      if (criteria.yearMin > 0 && movie.year != null) { if (movie.year! < criteria.yearMin) return false; }
      if (criteria.yearMax > 0 && movie.year != null) { if (movie.year! > criteria.yearMax) return false; }
      return true;
    }).toList();
  }

  void dispose() { _aiService.dispose(); _movieRepository.dispose(); }
}

class RecommendationResult {
  final bool success;
  final String? error;
  final List<RecommendationResultItem> items;
  final SearchCriteria? criteria;
  final int totalCandidates;
  const RecommendationResult({required this.success, this.error, this.items = const [], this.criteria, this.totalCandidates = 0});
  List<RecommendationResultItem> get top3 => items.take(3).toList();
}

class RecommendationResultItem {
  final MovieModel movie;
  final String reason;
  final double confidence;
  const RecommendationResultItem({required this.movie, required this.reason, required this.confidence});
}