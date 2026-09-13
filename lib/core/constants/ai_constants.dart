class AiConstants {
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String openRouterChatCompletions = '/chat/completions';

  static const Map<String, AiModel> freeModels = {
    'meta-llama/llama-3.1-8b-instruct:free': AiModel(
      id: 'meta-llama/llama-3.1-8b-instruct:free',
      name: 'Llama 3.1 8B',
      provider: 'Meta',
      description: 'Modello versatile e veloce',
      maxTokens: 4096,
      isFree: true,
    ),
    'google/gemma-2-9b-it:free': AiModel(
      id: 'google/gemma-2-9b-it:free',
      name: 'Gemma 2 9B',
      provider: 'Google',
      description: 'Ottimo per analisi testuale',
      maxTokens: 4096,
      isFree: true,
    ),
    'mistralai/mistral-7b-instruct:free': AiModel(
      id: 'mistralai/mistral-7b-instruct:free',
      name: 'Mistral 7B',
      provider: 'Mistral',
      description: 'Modello europeo, buono per reasoning',
      maxTokens: 4096,
      isFree: true,
    ),
    'qwen/qwen-2-7b-instruct:free': AiModel(
      id: 'qwen/qwen-2-7b-instruct:free',
      name: 'Qwen 2 7B',
      provider: 'Alibaba',
      description: 'Eccellente per compiti multilingue',
      maxTokens: 4096,
      isFree: true,
    ),
    'nousresearch/hermes-3-llama-3.1-8b:free': AiModel(
      id: 'nousresearch/hermes-3-llama-3.1-8b:free',
      name: 'Hermes 3 8B',
      provider: 'Nous Research',
      description: 'Specializzato in conversazioni',
      maxTokens: 4096,
      isFree: true,
    ),
    'dzoxiesm/ds-13b:free': AiModel(
      id: 'dzoxiesm/ds-13b:free',
      name: 'DS 13B',
      provider: 'DeepSeek',
      description: 'Modello bilanciato per compiti generali',
      maxTokens: 4096,
      isFree: true,
    ),
  };

  static const String defaultModelId = 'meta-llama/llama-3.1-8b-instruct:free';

  static AiModel getModel(String id) {
    return freeModels[id] ?? freeModels[defaultModelId]!;
  }

  static List<String> get allModelIds => freeModels.keys.toList();
  static List<AiModel> get allModels => freeModels.values.toList();

  static const Map<String, int> genreNameToId = {
    'azione': 28, 'avventura': 12, 'animazione': 16, 'commedia': 35,
    'crimine': 80, 'documentario': 99, 'dramma': 18, 'famiglia': 10751,
    'fantascienza': 878, 'fantasy': 14, 'guerra': 10752, 'horror': 27,
    'musica': 10402, 'mistero': 9648, 'romantico': 10749, 'thriller': 53,
    'western': 37, 'azione e avventura': 10759, 'animazione kids': 10762,
    'commedia kids': 10764, 'news': 10763, 'reality': 10764,
    'soap': 10766, 'talk': 10767, 'guerra e politica': 10768,
  };

  static List<int> getGenreIds(List<String> genreNames) {
    return genreNames
        .map((name) => genreNameToId[name.toLowerCase()])
        .where((id) => id != null)
        .cast<int>()
        .toList();
  }
}

class AiModel {
  final String id;
  final String name;
  final String provider;
  final String description;
  final int maxTokens;
  final bool isFree;

  const AiModel({
    required this.id,
    required this.name,
    required this.provider,
    required this.description,
    this.maxTokens = 4096,
    this.isFree = true,
  });

  @override
  String toString() => '$name ($provider)';
}