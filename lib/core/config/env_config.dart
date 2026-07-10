import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the app.
/// 
/// Loads values from .env file. Make sure to call `dotenv.load()` 
/// in main.dart before using these values.
abstract class EnvConfig {
  /// Supabase project URL
  static String get supabaseUrl => 
      dotenv.env['SUPABASE_URL'] ?? 
      const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://qwawmnbuuomcvsuxztmq.supabase.co');

  /// Supabase anonymous key (safe to expose in client)
  static String get supabaseAnonKey => 
      dotenv.env['SUPABASE_ANON_KEY'] ?? 
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3YXdtbmJ1dW9tY3ZzdXh6dG1xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk5OTczMzQsImV4cCI6MjA4NTU3MzMzNH0.P67zO4dYZ4ooIDyCzMCF-QNKVw5joCbd3fZJsMSopac');

  /// Base URL for emergency QR codes
  static String get emergencyBaseUrl => '$supabaseUrl/functions/v1/emergency';

  /// Custom Biometric API URL (local python server or deployed endpoint)
  static String get biometricApiUrl => 
      dotenv.env['BIOMETRIC_API_URL'] ?? 
      const String.fromEnvironment('BIOMETRIC_API_URL', defaultValue: 'https://ankurrera-caresync-biometrics.hf.space');

  /// Hugging Face Token for private Space API authentication
  static String? get hfToken => 
      dotenv.env['HF_TOKEN'] ?? 
      const String.fromEnvironment('HF_TOKEN');
}
