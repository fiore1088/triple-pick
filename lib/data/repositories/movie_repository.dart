import '../models/movie_model.dart';
import '../services/tmdb_service.dart';

class MovieRepository {
  final TmdbService _tmdbService;
  MovieRepository({TmdbService? tmdbService}) : _tmdbService = tmdbService ?? TmdbService();

  Future<List<MovieModel>> searchContent({required String query, int maxResults = 20}) async {
    try { return await _tmdbService.searchWithProviders(query: query, maxResults: maxResults); }
    catch (e) { throw Exception('Errore nella ricerca: $e'); }
  }

  Future<List<MovieModel>> getRecommendations({required List<int> genreIds, String? query, int maxResults = 20}) async {
    try {
      List<MovieModel> results = [];
      final movieResults = await _tmdbService.discoverMovies(genreIds: genreIds);
      final tvResults = await _tmdbService.discoverTv(genreIds: genreIds);
      results = [...movieResults, ...tvResults];
      final enrichedResults = await Future.wait(results.take(maxResults * 2).map((movie) async {
        try {
          final providers = movie.mediaType == 'movie' ? await _tmdbService.getMovieWatchProviders(movie.id) : await _tmdbService.getTvWatchProviders(movie.id);
          if (providers == null) return movie;
          final flatrate = providers['flatrate'] as List? ?? [];
          if (flatrate.isEmpty) return movie;
          final supportedProvider = flatrate.firstWhere(
            (p) => p['provider_name'] == 'Netflix' || p['provider_name'] == 'Prime Video' || p['provider_name'] == 'Disney+' || p['provider_name'] == 'Apple TV+' || p['provider_name'] == '.now' || p['provider_name'] == 'Infinity',
            orElse: () => null,
          );
          if (supportedProvider == null) return movie;
          return movie.copyWith(platformName: supportedProvider['provider_name'], providerId: supportedProvider['provider_id'], providerLogoPath: supportedProvider['logo_path'], watchLink: providers['link'], flatrateType: 'flatrate');
        } catch (e) { return movie; }
      }));
      return enrichedResults.where((m) => m.hasWatchProvider).take(maxResults).toList();
    } catch (e) { throw Exception('Errore nel recupero raccomandazioni: $e'); }
  }

  Future<List<MovieModel>> getTrending({int maxResults = 10}) async {
    try {
      final movies = await _tmdbService.getTrendingMovies();
      final enrichedResults = await Future.wait(movies.take(maxResults * 2).map((movie) async {
        try {
          final providers = await _tmdbService.getMovieWatchProviders(movie.id);
          if (providers == null) return movie;
          final flatrate = providers['flatrate'] as List? ?? [];
          if (flatrate.isEmpty) return movie;
          final supportedProvider = flatrate.firstWhere(
            (p) => p['provider_name'] == 'Netflix' || p['provider_name'] == 'Prime Video' || p['provider_name'] == 'Disney+' || p['provider_name'] == 'Apple TV+' || p['provider_name'] == '.now' || p['provider_name'] == 'Infinity',
            orElse: () => null,
          );
          if (supportedProvider == null) return movie;
          return movie.copyWith(platformName: supportedProvider['provider_name'], providerId: supportedProvider['provider_id'], providerLogoPath: supportedProvider['logo_path'], watchLink: providers['link'], flatrateType: 'flatrate');
        } catch (e) { return movie; }
      }));
      return enrichedResults.where((m) => m.hasWatchProvider).take(maxResults).toList();
    } catch (e) { throw Exception('Errore nel recupero trending: $e'); }
  }

  Future<MovieModel?> getMovieDetails(int movieId) async {
    try {
      final movie = await _tmdbService.getMovieDetails(movieId);
      if (movie == null) return null;
      final providers = await _tmdbService.getMovieWatchProviders(movieId);
      if (providers == null) return movie;
      final flatrate = providers['flatrate'] as List? ?? [];
      if (flatrate.isEmpty) return movie;
      final supportedProvider = flatrate.firstWhere(
        (p) => p['provider_name'] == 'Netflix' || p['provider_name'] == 'Prime Video' || p['provider_name'] == 'Disney+' || p['provider_name'] == 'Apple TV+' || p['provider_name'] == '.now' || p['provider_name'] == 'Infinity',
        orElse: () => null,
      );
      if (supportedProvider == null) return movie;
      return movie.copyWith(platformName: supportedProvider['provider_name'], providerId: supportedProvider['provider_id'], providerLogoPath: supportedProvider['logo_path'], watchLink: providers['link'], flatrateType: 'flatrate');
    } catch (e) { throw Exception('Errore nel recupero dettagli: $e'); }
  }

  Future<Map<int, String>> getMovieGenres() async { return await _tmdbService.getMovieGenres(); }
  Future<Map<int, String>> getTvGenres() async { return await _tmdbService.getTvGenres(); }
  void dispose() { _tmdbService.dispose(); }
}