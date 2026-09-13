import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/env/env.dart';
import '../models/movie_model.dart';

class TmdbService {
  final http.Client _client;
  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<MovieModel>> searchMovies({required String query, String language = 'it-IT', int page = 1}) async {
    final response = await _makeRequest(endpoint: ApiConstants.tmdbSearchMovies, params: {'query': query, 'language': language, 'page': page.toString(), 'include_adult': 'false'});
    if (response == null) return [];
    final results = response['results'] as List? ?? [];
    return results.map((json) => MovieModel.fromSearchJson(json, mediaType: 'movie')).where((movie) => movie.title.isNotEmpty).toList();
  }

  Future<List<MovieModel>> searchTv({required String query, String language = 'it-IT', int page = 1}) async {
    final response = await _makeRequest(endpoint: ApiConstants.tmdbSearchTv, params: {'query': query, 'language': language, 'page': page.toString()});
    if (response == null) return [];
    final results = response['results'] as List? ?? [];
    return results.map((json) => MovieModel.fromSearchJson(json, mediaType: 'tv')).where((movie) => movie.title.isNotEmpty).toList();
  }

  Future<List<MovieModel>> searchMulti({required String query, String language = 'it-IT', int page = 1}) async {
    final moviesFuture = searchMovies(query: query, language: language, page: page);
    final tvFuture = searchTv(query: query, language: language, page: page);
    final results = await Future.wait([moviesFuture, tvFuture]);
    final allResults = [...results[0], ...results[1]];
    allResults.sort((a, b) => (b.popularity ?? 0).compareTo(a.popularity ?? 0));
    return allResults;
  }

  Future<List<MovieModel>> discoverMovies({required List<int> genreIds, String language = 'it-IT', int page = 1, String sortBy = 'popularity.desc'}) async {
    final response = await _makeRequest(endpoint: ApiConstants.tmdbDiscoverMovies, params: {'with_genres': genreIds.join(','), 'language': language, 'page': page.toString(), 'sort_by': sortBy, 'watch_region': 'IT', 'with_watch_providers': '8|119|337|350|44|531'});
    if (response == null) return [];
    final results = response['results'] as List? ?? [];
    return results.map((json) => MovieModel.fromSearchJson(json, mediaType: 'movie')).toList();
  }

  Future<List<MovieModel>> discoverTv({required List<int> genreIds, String language = 'it-IT', int page = 1, String sortBy = 'popularity.desc'}) async {
    final response = await _makeRequest(endpoint: ApiConstants.tmdbDiscoverTv, params: {'with_genres': genreIds.join(','), 'language': language, 'page': page.toString(), 'sort_by': sortBy, 'watch_region': 'IT', 'with_watch_providers': '8|119|337|350|44|531'});
    if (response == null) return [];
    final results = response['results'] as List? ?? [];
    return results.map((json) => MovieModel.fromSearchJson(json, mediaType: 'tv')).toList();
  }

  Future<Map<String, dynamic>?> getMovieWatchProviders(int movieId) async {
    final response = await _makeRequest(endpoint: '/movie/$movieId/watch/providers', params: {});
    if (response == null) return null;
    final results = response['results'] as Map<String, dynamic>? ?? {};
    return results['IT'];
  }

  Future<Map<String, dynamic>?> getTvWatchProviders(int tvId) async {
    final response = await _makeRequest(endpoint: '/tv/$tvId/watch/providers', params: {});
    if (response == null) return null;
    final results = response['results'] as Map<String, dynamic>? ?? {};
    return results['IT'];
  }

  Future<MovieModel?> getMovieDetails(int movieId, {String language = 'it-IT'}) async {
    final response = await _makeRequest(endpoint: '/movie/$movieId', params: {'language': language});
    if (response == null) return null;
    return MovieModel.fromSearchJson(response, mediaType: 'movie');
  }

  Future<MovieModel?> getTvDetails(int tvId, {String language = 'it-IT'}) async {
    final response = await _makeRequest(endpoint: '/tv/$tvId', params: {'language': language});
    if (response == null) return null;
    return MovieModel.fromSearchJson(response, mediaType: 'tv');
  }

  Future<Map<int, String>> getMovieGenres({String language = 'it-IT'}) async {
    final response = await _makeRequest(endpoint: '/genre/movie/list', params: {'language': language});
    if (response == null) return {};
    final genres = response['genres'] as List? ?? [];
    return {for (var genre in genres) genre['id'] as int: genre['name'] as String};
  }

  Future<Map<int, String>> getTvGenres({String language = 'it-IT'}) async {
    final response = await _makeRequest(endpoint: '/genre/tv/list', params: {'language': language});
    if (response == null) return {};
    final genres = response['genres'] as List? ?? [];
    return {for (var genre in genres) genre['id'] as int: genre['name'] as String};
  }

  Future<List<MovieModel>> getTrendingMovies({String timeWindow = 'week', String language = 'it-IT'}) async {
    final response = await _makeRequest(endpoint: '/trending/movie/$timeWindow', params: {'language': language});
    if (response == null) return [];
    final results = response['results'] as List? ?? [];
    return results.map((json) => MovieModel.fromSearchJson(json, mediaType: 'movie')).toList();
  }

  Future<List<MovieModel>> searchWithProviders({required String query, String language = 'it-IT', int maxResults = 10}) async {
    final searchResults = await searchMulti(query: query, language: language);
    if (searchResults.isEmpty) return [];
    final limitedResults = searchResults.take(maxResults).toList();
    final enrichedResults = await Future.wait(limitedResults.map((movie) async {
      try {
        final providers = movie.mediaType == 'movie' ? await getMovieWatchProviders(movie.id) : await getTvWatchProviders(movie.id);
        if (providers == null) return movie;
        final flatrate = providers['flatrate'] as List? ?? [];
        if (flatrate.isEmpty) return movie;
        final supportedProvider = flatrate.firstWhere(
          (p) => ApiConstants.netflixProviderId == p['provider_id'] || ApiConstants.primeVideoProviderId == p['provider_id'] || ApiConstants.disneyPlusProviderId == p['provider_id'] || ApiConstants.appleTvPlusProviderId == p['provider_id'] || ApiConstants.nowProviderId == p['provider_id'] || ApiConstants.infinityProviderId == p['provider_id'],
          orElse: () => null,
        );
        if (supportedProvider == null) return movie;
        return movie.copyWith(platformName: supportedProvider['provider_name'], providerId: supportedProvider['provider_id'], providerLogoPath: supportedProvider['logo_path'], watchLink: providers['link'], flatrateType: 'flatrate');
      } catch (e) { return movie; }
    }));
    return enrichedResults.where((m) => m.hasWatchProvider).toList();
  }

  Future<Map<String, dynamic>?> _makeRequest({required String endpoint, required Map<String, String> params}) async {
    try {
      final uri = Uri.parse('${ApiConstants.tmdbBaseUrl}$endpoint').replace(queryParameters: {'api_key': Env.tmdbApiKey, ...params});
      final response = await _client.get(uri, headers: {'Content-Type': 'application/json'}).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) { return json.decode(response.body); }
      else { print('TMDB API error: ${response.statusCode}'); return null; }
    } catch (e) { print('TMDB API exception: $e'); return null; }
  }

  void dispose() { _client.close(); }
}