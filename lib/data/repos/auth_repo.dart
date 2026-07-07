import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/env.dart';
import '../../core/supabase.dart';
import '../models/role.dart';

final authRepoProvider = Provider<AuthRepo>((ref) => AuthRepo());

class AuthRepo {
  /// Redirect voor e-mail-links: op web de huidige origin (zoals de
  /// React-app window.location.origin gebruikte), op mobiel de site-URL.
  String get _emailRedirect =>
      kIsWeb ? Uri.base.origin : Env.siteUrl;

  /// Metadata-keys moeten exact matchen met de handle_new_user-trigger
  /// (supabase/migrations/20260612090157_*.sql).
  Future<void> signUpClient({
    required String name,
    required String email,
    required String password,
    required List<String> goals,
    String? inviteToken,
  }) async {
    await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: '$_emailRedirect/',
      data: {
        'name': name,
        'role': 'klant',
        'goals': goals,
        // handle_new_user koppelt de klant hiermee direct aan de coach.
        if (inviteToken != null) 'invite_token': inviteToken,
      },
    );
  }

  Future<void> signUpCoach({
    required String name,
    required String email,
    required String password,
    required String specialization,
    required String hourlyRate,
    required String location,
    required bool onlineCoaching,
  }) async {
    await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: '$_emailRedirect/',
      data: {
        'name': name,
        'role': 'coach',
        'specialization': specialization,
        'hourly_rate': hourlyRate,
        'location': location,
        'online_coaching': onlineCoaching,
      },
    );
  }

  Future<void> signIn({required String email, required String password}) =>
      supabase.auth.signInWithPassword(email: email, password: password);

  Future<void> signInWithGoogle() => supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'coacher://login-callback',
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

  Future<void> sendPasswordReset(String email) =>
      supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: '$_emailRedirect/reset-password',
      );

  Future<void> updatePassword(String newPassword) =>
      supabase.auth.updateUser(UserAttributes(password: newPassword));

  Future<void> signOut() => supabase.auth.signOut();

  Session? get session => supabase.auth.currentSession;
  User? get user => supabase.auth.currentUser;

  /// Voor bestaande OAuth-gebruikers zonder profiel: profiel + rol upserten
  /// (de trigger draait alleen bij nieuwe auth-users met metadata).
  Future<void> completeOauthProfile(Role role) async {
    final u = supabase.auth.currentUser;
    if (u == null) return;
    final name = (u.userMetadata?['full_name'] as String?) ??
        (u.userMetadata?['name'] as String?) ??
        u.email?.split('@').first ??
        '';
    await supabase.from('profiles').upsert(
      {'id': u.id, 'name': name, 'role': role.db},
      onConflict: 'id',
    );
    await supabase.from('user_roles').upsert(
      {'user_id': u.id, 'role': role.db},
      onConflict: 'user_id,role',
    );
  }

  /// Rol van huidige user bepalen: eerst user_metadata, anders profiles.
  Future<Role?> resolveRole() async {
    final u = supabase.auth.currentUser;
    if (u == null) return null;
    final metaRole = Role.tryParse(u.userMetadata?['role'] as String?);
    if (metaRole != null) return metaRole;
    final data = await supabase
        .from('profiles')
        .select('role')
        .eq('id', u.id)
        .maybeSingle();
    return Role.tryParse(data?['role'] as String?);
  }
}
