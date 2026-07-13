import 'package:supabase_flutter/supabase_flutter.dart';

/// Vertaalt een Supabase-authenticatiefout naar een Nederlandse,
/// gebruiksvriendelijke melding. Matcht primair op `error.code` (stabiel,
/// taalonafhankelijk) met een tekst-fallback voor gevallen zonder code
/// (zoals de klassieke "Invalid login credentials").
String authErrorMessage(Object error) {
  if (error is! AuthException) return 'Er ging iets mis. Probeer het opnieuw.';

  switch (error.code) {
    case 'user_already_exists':
    case 'email_exists':
      return 'Er bestaat al een account met dit e-mailadres.';
    case 'email_not_confirmed':
      return 'Bevestig eerst je e-mailadres via de link die we je gestuurd hebben.';
    case 'weak_password':
      return 'Dit wachtwoord is niet sterk genoeg. Kies een ander wachtwoord.';
    case 'same_password':
      return 'Het nieuwe wachtwoord moet verschillen van je huidige wachtwoord.';
    case 'user_not_found':
      return 'Er bestaat geen account met dit e-mailadres.';
    case 'user_banned':
      return 'Dit account is geblokkeerd. Neem contact op met support.';
    case 'over_request_rate_limit':
    case 'over_email_send_rate_limit':
    case 'over_sms_send_rate_limit':
      return 'Te veel pogingen. Probeer het over een paar minuten opnieuw.';
    case 'signup_disabled':
    case 'email_provider_disabled':
      return 'Registreren is momenteel niet mogelijk.';
    case 'session_expired':
    case 'session_not_found':
    case 'flow_state_expired':
    case 'flow_state_not_found':
    case 'otp_expired':
      return 'Deze link is verlopen. Vraag een nieuwe aan.';
    case 'bad_code_verifier':
    case 'bad_oauth_state':
    case 'bad_oauth_callback':
      return 'Inloggen via Google is mislukt. Probeer het opnieuw.';
    case 'captcha_failed':
      return 'Verificatie mislukt. Probeer het opnieuw.';
    case 'identity_already_exists':
      return 'Dit account is al gekoppeld.';
    case 'provider_disabled':
    case 'oauth_provider_not_supported':
      return 'Deze inlogmethode is niet beschikbaar.';
    case 'validation_failed':
    case 'bad_json':
      return 'Ongeldige gegevens. Controleer je invoer.';
  }

  final msg = error.message.toLowerCase();
  if (msg.contains('invalid login credentials')) {
    return 'Ongeldige inloggegevens. Controleer je e-mailadres en wachtwoord.';
  }
  if (msg.contains('email not confirmed')) {
    return 'Bevestig eerst je e-mailadres via de link die we je gestuurd hebben.';
  }
  if (msg.contains('user already registered') ||
      msg.contains('already registered')) {
    return 'Er bestaat al een account met dit e-mailadres.';
  }
  if (msg.contains('password should be at least') ||
      msg.contains('password is too short')) {
    return 'Wachtwoord voldoet niet aan de eisen (minimaal 8 tekens).';
  }
  if (msg.contains('token has expired') || msg.contains('invalid token')) {
    return 'Deze link is verlopen of al gebruikt. Vraag een nieuwe aan.';
  }
  if (error is AuthRetryableFetchException ||
      msg.contains('network') ||
      msg.contains('socket')) {
    return 'Kan geen verbinding maken. Controleer je internetverbinding.';
  }

  return 'Er ging iets mis. Probeer het opnieuw.';
}
