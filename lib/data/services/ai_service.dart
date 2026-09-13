import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/ai_constants.dart';
import '../../core/env/env.dart';

class AiService {
  final http.Client _client;
  final String _modelId;

  AiService({http.Client? client, String? modelId})
      : _client = client ?? http.Client(),
        _modelId = modelId ?? Env.openRouterModel;

  Future<SearchCriteria> parseUserRequest(String userRequest) async {
    final prompt = _buildParsePrompt(userRequest);
    final response = await _callAi(prompt);
    if (response == null) {
      return SearchCriteria(query: userRequest, genres: [], mood: 'neutral', runtimeMax: 180, language: 'it', excludeViolence: false, excludeHorror: false);
    }
    return _parseSearchCriteria(response, userRequest);
  }

  Future<List<Recommendation>> selectTop3({required String userRequest, required List<Map<String, dynamic>> candidates, required SearchCriteria criteria}) async {
    final prompt = _buildSelectionPrompt(userRequest: userRequest, candidates: candidates, criteria: criteria);
    final response = await _callAi(prompt);
    if (response == null) {
      return candidates.take(3).map((c) => Recommendation(movieId: c['id'], title: c['title'] ?? '', reason: 'Consigliato in base alla tua ricerca', confidence: 0.7)).toList();
    }
    return _parseRecommendations(response, candidates);
  }

  String _buildParsePrompt(String userRequest) {
    return '''Sei un assistente esperto di film e serie TV. Analizza la richiesta dell'utente e estrai criteri strutturati per la ricerca.

Richiesta dell'utente: "\$userRequest"

Rispondi SOLO con un JSON valido (senza markdown o testo aggiunto) con questa struttura:
{
  "query": "query di ricerca per TMDB",
  "genres": ["lista di generi in italiano"],
  "mood": "tono del film",
  "runtime_max": durata massima in minuti,
  "language": "lingua preferita (it, en, o any)",
  "year_min": anno minimo (0 per qualsiasi),
  "year_max": anno massimo (0 per qualsiasi),
  "exclude_violence": true/false,
  "exclude_horror": true/false,
  "keywords": ["parole chiave"]
}''';
  }

  String _buildSelectionPrompt({required String userRequest, required List<Map<String, dynamic>> candidates, required SearchCriteria criteria}) {
    final candidatesText = candidates.map((c) => '- ID: \${c['id']}, Titolo: \${c['title']}, Genere: \${c['genres']}, Valutazione: \${c['vote_average']}, Piattaforma: \${c['platform_name'] ?? 'N/A'}').join('\n');
    return '''Sei un esperto di raccomandazioni film. Seleziona i TOP 3 film piu adatti per l'utente.

Richiesta originale: "\$userRequest"
Criteri estratti: Genere: \${criteria.genres.join(', ')}, Tono: \${criteria.mood}, Durata max: \${criteria.runtimeMax}min

Candidati disponibili:
\$candidatesText

Seleziona esattamente 3 film che meglio soddisfano la richiesta. Per ogni film, fornisci una motivazione personalizzata.

Rispondi SOLO con un JSON valido:
{
  "recommendations": [
    {"movie_id": 123, "title": "Titolo", "reason": "Motivazione (max 2 frasi)", "confidence": 0.95}
  ]
}''';
  }

  Future<String?> _callAi(String prompt) async {
    try {
      final model = AiConstants.getModel(_modelId);
      final response = await http.post(
        Uri.parse('\${AiConstants.openRouterBaseUrl}\${AiConstants.openRouterChatCompletions}'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer \${Env.openRouterApiKey}', 'HTTP-Referer': 'https://tripplepick.app', 'X-Title': 'TriplePick'},
        body: json.encode({'model': _modelId, 'messages': [{'role': 'system', 'content': 'Sei un assistente esperto di film e serie TV. Rispondi sempre in JSON valido senza markdown.'}, {'role': 'user', 'content': prompt}], 'max_tokens': model.maxTokens, 'temperature': 0.7}),
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices']?[0]?['message']?[0]?['content'];
        if (content != null) {
          String cleaned = content.toString().trim();
          if (cleaned.startsWith('```json')) cleaned = cleaned.substring(7);
          if (cleaned.startsWith('```')) cleaned = cleaned.substring(3);
          if (cleaned.endsWith('```')) cleaned = cleaned.substring(0, cleaned.length - 3);
          return cleaned.trim();
        }
      }
      return null;
    } catch (e) { print('AI API exception: \$e'); return null; }
  }

  SearchCriteria _parseSearchCriteria(String jsonStr, String originalRequest) {
    try {
      final data = json.decode(jsonStr);
      return SearchCriteria(query: data['query'] ?? originalRequest, genres: List<String>.from(data['genres'] ?? []), mood: data['mood'] ?? 'neutral', runtimeMax: data['runtime_max'] ?? 180, language: data['language'] ?? 'it', yearMin: data['year_min'] ?? 0, yearMax: data['year_max'] ?? 0, excludeViolence: data['exclude_violence'] ?? false, excludeHorror: data['exclude_horror'] ?? false, keywords: List<String>.from(data['keywords'] ?? []));
    } catch (e) { return SearchCriteria(query: originalRequest, genres: [], mood: 'neutral', runtimeMax: 180, language: 'it'); }
  }

  List<Recommendation> _parseRecommendations(String jsonStr, List<Map<String, dynamic>> candidates) {
    try {
      final data = json.decode(jsonStr);
      final recommendations = data['recommendations'] as List? ?? [];
      return recommendations.map((r) {
        final candidate = candidates.firstWhere((c) => c['id'] == r['movie_id'], orElse: () => {'id': r['movie_id'], 'title': r['title'] ?? ''});
        return Recommendation(movieId: candidate['id'], title: candidate['title'] ?? r['title'] ?? '', reason: r['reason'] ?? 'Consigliato per te', confidence: (r['confidence'] ?? 0.8).toDouble());
      }).toList();
    } catch (e) {
      return candidates.take(3).map((c) => Recommendation(movieId: c['id'], title: c['title'] ?? '', reason: 'Consigliato in base alla tua ricerca', confidence: 0.7)).toList();
    }
  }

  void dispose() { _client.close(); }
}

class SearchCriteria {
  final String query;
  final List<String> genres;
  final String mood;
  final int runtimeMax;
  final String language;
  final int yearMin;
  final int yearMax;
  final bool excludeViolence;
  final bool excludeHorror;
  final List<String> keywords;

  const SearchCriteria({required this.query, required this.genres, required this.mood, required this.runtimeMax, required this.language, this.yearMin = 0, this.yearMax = 0, this.excludeViolence = false, this.excludeHorror = false, this.keywords = const []});

  @override
  String toString() => 'SearchCriteria(query: \$query, genres: \$genres, mood: \$mood)';
}

class Recommendation {
  final int movieId;
  final String title;
  final String reason;
  final double confidence;

  const Recommendation({required this.movieId, required this.title, required this.reason, required this.confidence});

  @override
  String toString() => 'Recommendation(id: \$movieId, title: \$title, confidence: \$confidence)';
}