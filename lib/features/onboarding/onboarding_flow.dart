import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase.dart';
import '../../data/models/role.dart';
import '../../data/repos/auth_repo.dart';
import '../auth/forgot_password_screen.dart';
import '../auth/login_screen.dart';
import '../shell/app_shell.dart';
import 'client_register_screen.dart';
import 'coach_register_screen.dart';
import 'payment_screen.dart';
import 'role_select_screen.dart';
import 'splash_screen.dart';
import 'success_screen.dart';
import 'verification_screen.dart';
import 'welcome_screen.dart';

enum _Step {
  splash,
  welcome,
  login,
  forgot,
  role,
  register,
  verification,
  payment,
  success,
  oauthRole,
  app,
}

/// Port van routes/index.tsx — de stap-state-machine van de hele
/// onboarding, inclusief het oppikken van bestaande sessies en
/// OAuth-gebruikers zonder rol.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  _Step _step = _Step.splash;
  Role? _role;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = supabase.auth.onAuthStateChange.listen((event) {
      final user = event.session?.user;
      if (user != null) _resolve(user);
    });
    final user = supabase.auth.currentUser;
    if (user != null) {
      // Na de eerste frame zodat setState veilig is.
      WidgetsBinding.instance.addPostFrameCallback((_) => _resolve(user));
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  /// Eenmalige welkomstmail (Resend via Edge Function) bij de eerste
  /// ingelogde sessie; user_metadata voorkomt herhaling. Best effort.
  Future<void> _maybeSendWelcome(User user) async {
    if (user.userMetadata?['welcome_sent'] == true) return;
    try {
      await supabase.functions.invoke('send-email', body: {
        'template': 'welcome',
        'name': (user.userMetadata?['name'] as String?) ?? '',
      });
      await supabase.auth.updateUser(
        UserAttributes(data: {'welcome_sent': true}),
      );
    } catch (_) {
      // Mail is niet kritisch voor de flow.
    }
  }

  /// Zelfde logica als resolve() in index.tsx: rol uit user_metadata,
  /// anders uit profiles; geen van beide → rol laten kiezen (OAuth).
  Future<void> _resolve(User user) async {
    _maybeSendWelcome(user);
    final metaRole = Role.tryParse(user.userMetadata?['role'] as String?);
    if (metaRole != null) {
      if (!mounted) return;
      setState(() {
        _role = metaRole;
        if (_step == _Step.splash ||
            _step == _Step.welcome ||
            _step == _Step.login) {
          _step = _Step.app;
        }
      });
      return;
    }
    final data = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    if (!mounted) return;
    final profileRole = Role.tryParse(data?['role'] as String?);
    setState(() {
      if (profileRole != null) {
        _role = profileRole;
        if (_step == _Step.splash ||
            _step == _Step.welcome ||
            _step == _Step.login) {
          _step = _Step.app;
        }
      } else {
        _step = _Step.oauthRole;
      }
    });
  }

  Future<void> _clientSignup(ClientRegisterData d) async {
    await ref.read(authRepoProvider).signUpClient(
          name: d.name,
          email: d.email,
          password: d.password,
          goals: d.goals,
        );
    if (mounted) setState(() => _step = _Step.verification);
  }

  Future<void> _coachSignup(CoachRegisterData d) async {
    await ref.read(authRepoProvider).signUpCoach(
          name: d.name,
          email: d.email,
          password: d.password,
          specialization: d.specialization,
          hourlyRate: d.hourlyRate,
          location: d.location,
          onlineCoaching: d.onlineCoaching,
        );
    if (mounted) setState(() => _step = _Step.verification);
  }

  Future<void> _oauthRole(Role r) async {
    final repo = ref.read(authRepoProvider);
    if (repo.user == null) {
      setState(() => _step = _Step.welcome);
      return;
    }
    await repo.completeOauthProfile(r);
    if (!mounted) return;
    setState(() {
      _role = r;
      _step = _Step.app;
    });
  }

  Future<void> _logout() async {
    await ref.read(authRepoProvider).signOut();
    if (!mounted) return;
    setState(() {
      _role = null;
      _step = _Step.welcome;
    });
  }

  void _go(_Step step) => setState(() => _step = step);

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _Step.splash => SplashScreen(onDone: () => _go(_Step.welcome)),
      _Step.welcome => WelcomeScreen(
          onStart: () => _go(_Step.role),
          onLogin: () => _go(_Step.login),
          onDemo: () => setState(() {
            _role = Role.klant;
            _step = _Step.app;
          }),
        ),
      _Step.login => LoginScreen(
          onBack: () => _go(_Step.welcome),
          onSuccess: () => _go(_Step.app),
          onForgot: () => _go(_Step.forgot),
        ),
      _Step.forgot => ForgotPasswordScreen(onBack: () => _go(_Step.login)),
      _Step.role => RoleSelectScreen(
          onBack: () => _go(_Step.welcome),
          onContinue: (r) => setState(() {
            _role = r;
            _step = _Step.register;
          }),
        ),
      _Step.register => _role == Role.coach
          ? CoachRegisterScreen(
              onBack: () => _go(_Step.role), onSubmit: _coachSignup)
          : ClientRegisterScreen(
              onBack: () => _go(_Step.role), onSubmit: _clientSignup),
      _Step.verification => VerificationScreen(
          role: _role ?? Role.klant,
          onSkip: () => _go(_Step.payment),
          onDone: () => _go(_Step.payment),
        ),
      _Step.payment => PaymentScreen(
          role: _role ?? Role.klant,
          onSkip: () => _go(_Step.success),
          onDone: () => _go(_Step.success),
        ),
      _Step.success => SuccessScreen(
          role: _role ?? Role.klant,
          onOpen: () => _go(_Step.app),
        ),
      _Step.oauthRole => RoleSelectScreen(
          onBack: _logout,
          onContinue: _oauthRole,
        ),
      _Step.app => AppShell(
          initialMode: _role ?? Role.klant,
          onLogout: _logout,
        ),
    };
  }
}
