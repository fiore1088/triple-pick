import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get tmdbApiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static String get tmdbUsername => dotenv.env['TMDB_USERNAME'] ?? '';
  static String get openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get openRouterModel => dotenv.env['OPENROUTER_MODEL'] ?? 'meta-llama/llama-3.1-8b-instruct:free';
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get appName => dotenv.env['APP_NAME'] ?? 'TriplePick';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static bool get isProduction => appEnv == 'production';
  static bool get isOpenRouterConfigured => openRouterApiKey.isNotEmpty;
}