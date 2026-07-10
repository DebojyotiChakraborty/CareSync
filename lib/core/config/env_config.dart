/// Environment configuration for the app.
/// 
/// Variables are injected at compile time using:
/// `flutter run --dart-define-from-file=.env`
abstract class EnvConfig {
  /// Supabase project URL
  static String get supabaseUrl {
    const value = String.fromEnvironment('SUPABASE_URL');
    if (value.isEmpty) {
      _throwMissingEnv('SUPABASE_URL');
    }
    return value;
  }

  /// Supabase anonymous key (safe to expose in client)
  static String get supabaseAnonKey {
    const value = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (value.isEmpty) {
      _throwMissingEnv('SUPABASE_ANON_KEY');
    }
    return value;
  }

  /// Base URL for emergency QR codes
  static String get emergencyBaseUrl => '$supabaseUrl/functions/v1/emergency';

  /// Custom Biometric API URL (local python server or deployed endpoint)
  static String get biometricApiUrl {
    const value = String.fromEnvironment('BIOMETRIC_API_URL');
    if (value.isEmpty) {
      return 'http://localhost:8000';
    }
    return value;
  }

  /// Hugging Face Token for private Space API authentication
  static String? get hfToken {
    const value = String.fromEnvironment('HF_TOKEN');
    if (value.isEmpty) {
      return null;
    }
    return value;
  }

  /// Helper to throw meaningful error for missing env vars
  static String _throwMissingEnv(String key) {
    throw Exception(
      'Missing environment variable: $key\n'
      'Please ensure you run/build the app with --dart-define-from-file=.env '
      'and that the .env file has this variable configured.',
    );
  }
}

