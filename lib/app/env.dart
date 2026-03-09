/// Supabase credentials.
/// Override at build time with:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=your-anon-key \
///     --dart-define=AUTH_REDIRECT_URL=io.kasway://login-callback
class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://127.0.0.1:54321',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
  );

  /// Deep-link redirect URL used for magic link and OAuth callbacks.
  /// Must be registered in Supabase dashboard → Authentication → URL Configuration.
  static const authRedirectUrl = String.fromEnvironment(
    'AUTH_REDIRECT_URL',
    defaultValue: 'io.kasway://login-callback',
  );
}
