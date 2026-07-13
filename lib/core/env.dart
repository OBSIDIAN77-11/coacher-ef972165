/// Compile-time configuratie via --dart-define.
/// De defaults zijn de publieke waardes uit het bestaande Lovable-project
/// (anon key is client-side en dus geen geheim).
class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://dhqiuxaefllhgrktcfbr.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRocWl1eGFlZmxsaGdya3RjZmJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNTkzMTAsImV4cCI6MjA5NjgzNTMxMH0.h4L9wm-OZQqYI5uU7E9CTzKoNY8oHjkeTAhAX-45U3M',
  );

  /// Web-URL van de app (Vercel), gebruikt voor e-mail-redirects.
  static const siteUrl = String.fromEnvironment(
    'SITE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
