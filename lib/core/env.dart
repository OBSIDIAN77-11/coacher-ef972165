/// Compile-time configuratie via --dart-define.
/// De defaults zijn de publieke waardes uit het bestaande Lovable-project
/// (anon key is client-side en dus geen geheim).
class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://bzdaxtzzxbyomwzdxrnz.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6ZGF4dHp6eGJ5b213emR4cm56Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNDY5NDIsImV4cCI6MjA5NjgyMjk0Mn0.28MyqsdqOgBLKtZu_goRGdVvBxLGZn5rS6lGezI8vxU',
  );

  /// Web-URL van de app (Vercel), gebruikt voor e-mail-redirects.
  static const siteUrl = String.fromEnvironment(
    'SITE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
