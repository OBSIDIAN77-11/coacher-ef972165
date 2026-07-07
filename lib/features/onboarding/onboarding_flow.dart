import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/demo_mode.dart';
import '../../core/supabase.dart';
import '../../data/models/role.dart';
import '../../data/repos/auth_repo.dart';
import '../auth/forgot_password_screen.dart';
import '../auth/login_screen.dart';
import '../shell/app_shell.dart';
import 'client_register_screen.dart';
import 'coach_register_screen.dart';
import 'confirm_email_screen.dart';
import 'invite_screen.dart';
import 'payment_screen.dart';
import 'role_select_screen.dart';
import 'splash_screen.dart';
import 'success_screen.dart';
import 'veriff_verification_screen.dart';
import 'welcome_screen.dart';

enum _Step {
  splash,
  welcome,
  login,
  forgot,
  role,
  invite,
  register,
  confirmEmail,
  verification,
  payment,
  success,
  oauthRole,
  oauthInvite,
  app,
}

/// De onboarding-flow. Gebaseerd op routes/index.tsx uit het origineel,
/// maar met echte accountlogica:
/// - na registratie eerst e-mailbevestiging (geen demo-data meer);
/// - klanten registreren alleen op uitnodiging van een coach;
/// - coaches doorlopen na de eerste login echte ID-verificatie (Veriff)
///   en daarna de Mollie-betaling.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key, this.inviteToken});

  /// Token uit een /invite-link — start direct in de uitnodigingsflow.
  final String? inviteToken;

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  _Step _step = _Step.splash;
  Role? _role;
  ValidatedInvite? _invite;
  String _registeredEmail = '';
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    if (widget.inviteToken != null && widget.inviteToken!.isNotEmpty) {
      _step = _Step.invite;
      _role = Role.klant;
    }
    _authSub = supabase.auth.onAuthStateChange.listen((event) {
      final user = event.session?.user;
      if (user != null) _resolve(user);
    });
    final user = supabase.auth.currentUser;
    if (user != null) {
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

  bool get _atEntryStep =>
      _step == _Step.splash ||
      _step == _Step.welcome ||
      _step == _Step.login ||
      _step == _Step.confirmEmail;

  /// Rol bepalen (user_metadata → profiles) en daarna de poortjes:
  /// coach zonder goedgekeurde verificatie → Veriff; geen actief
  /// abonnement → betaling; anders de app.
  Future<void> _resolve(User user) async {
    ref.read(demoModeProvider.notifier).state = false;
    _maybeSendWelcome(user);

    var role = Role.tryParse(user.userMetadata?['role'] as String?);
    if (role == null) {
      final data = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      role = Role.tryParse(data?['role'] as String?);
    }
    if (!mounted) return;

    if (role == null) {
      setState(() => _step = _Step.oauthRole);
      return;
    }
    _role = role;
    if (!_atEntryStep) return;
    await _gate(user, role);
  }

  /// Poortjes na login. Faalt een query (bijv. migratie nog niet
  /// gedeployed), dan door naar de app — nooit blokkeren.
  Future<void> _gate(User user, Role role) async {
    try {
      if (role == Role.coach) {
        final v = await supabase
            .from('verifications')
            .select('status')
            .eq('user_id', user.id)
            .maybeSingle();
        if ((v?['status'] as String?) != 'approved') {
          if (mounted) setState(() => _step = _Step.verification);
          return;
        }
      }
      final sub = await supabase
          .from('subscriptions')
          .select('status')
          .eq('user_id', user.id)
          .maybeSingle();
      if ((sub?['status'] as String?) != 'active') {
        if (mounted) setState(() => _step = _Step.payment);
        return;
      }
    } catch (_) {
      // Tabellen nog niet aanwezig of netwerkfout.
    }
    if (mounted) setState(() => _step = _Step.app);
  }

  Future<void> _afterVerification() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _step = _Step.welcome);
      return;
    }
    try {
      final sub = await supabase
          .from('subscriptions')
          .select('status')
          .eq('user_id', user.id)
          .maybeSingle();
      if ((sub?['status'] as String?) != 'active') {
        if (mounted) setState(() => _step = _Step.payment);
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _step = _Step.app);
  }

  Future<void> _clientSignup(ClientRegisterData d) async {
    await ref.read(authRepoProvider).signUpClient(
          name: d.name,
          email: d.email,
          password: d.password,
          goals: d.goals,
          inviteToken: _invite?.token,
        );
    if (mounted) {
      setState(() {
        _registeredEmail = d.email;
        _step = _Step.confirmEmail;
      });
    }
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
    if (mounted) {
      setState(() {
        _registeredEmail = d.email;
        _step = _Step.confirmEmail;
      });
    }
  }

  Future<void> _oauthRoleChosen(Role r) async {
    final repo = ref.read(authRepoProvider);
    if (repo.user == null) {
      setState(() => _step = _Step.welcome);
      return;
    }
    if (r == Role.klant) {
      // Klanten alleen op uitnodiging — ook via Google.
      setState(() => _step = _Step.oauthInvite);
      return;
    }
    await repo.completeOauthProfile(r);
    if (!mounted) return;
    _role = r;
    await _gate(repo.user!, r);
  }

  Future<void> _oauthInviteValidated(ValidatedInvite invite) async {
    final repo = ref.read(authRepoProvider);
    final user = repo.user;
    if (user == null) {
      setState(() => _step = _Step.welcome);
      return;
    }
    await repo.completeOauthProfile(Role.klant);
    try {
      await supabase.functions
          .invoke('accept-invite', body: {'token': invite.token});
    } catch (_) {
      // Koppeling kan later alsnog; niet blokkeren.
    }
    if (!mounted) return;
    _role = Role.klant;
    await _gate(user, Role.klant);
  }

  Future<void> _logout() async {
    await ref.read(authRepoProvider).signOut();
    ref.read(demoModeProvider.notifier).state = false;
    if (!mounted) return;
    setState(() {
      _role = null;
      _invite = null;
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
          onDemo: () {
            ref.read(demoModeProvider.notifier).state = true;
            setState(() {
              _role = Role.klant;
              _step = _Step.app;
            });
          },
        ),
      _Step.login => LoginScreen(
          onBack: () => _go(_Step.welcome),
          // Sessie wordt opgepikt via onAuthStateChange → _resolve.
          onSuccess: () {},
          onForgot: () => _go(_Step.forgot),
        ),
      _Step.forgot => ForgotPasswordScreen(onBack: () => _go(_Step.login)),
      _Step.role => RoleSelectScreen(
          onBack: () => _go(_Step.welcome),
          onContinue: (r) => setState(() {
            _role = r;
            _step = r == Role.coach ? _Step.register : _Step.invite;
          }),
        ),
      _Step.invite => InviteScreen(
          initialToken: _invite == null ? widget.inviteToken : null,
          onBack: () => _go(_Step.role),
          onValidated: (invite) => setState(() {
            _invite = invite;
            _role = Role.klant;
            _step = _Step.register;
          }),
        ),
      _Step.register => _role == Role.coach
          ? CoachRegisterScreen(
              onBack: () => _go(_Step.role), onSubmit: _coachSignup)
          : ClientRegisterScreen(
              onBack: () => _go(_Step.invite),
              onSubmit: _clientSignup,
              initialEmail: _invite?.email,
              invitedBy: _invite?.coachName,
            ),
      _Step.confirmEmail => ConfirmEmailScreen(
          email: _registeredEmail,
          onToLogin: () => _go(_Step.login),
        ),
      _Step.verification => VeriffVerificationScreen(
          onSkip: _afterVerification,
          onDone: _afterVerification,
        ),
      _Step.payment => PaymentScreen(
          role: _role ?? Role.klant,
          onSkip: () => _go(_Step.app),
          onDone: () => _go(_Step.success),
        ),
      _Step.success => SuccessScreen(
          role: _role ?? Role.klant,
          onOpen: () => _go(_Step.app),
        ),
      _Step.oauthRole => RoleSelectScreen(
          onBack: _logout,
          onContinue: _oauthRoleChosen,
        ),
      _Step.oauthInvite => InviteScreen(
          onBack: _logout,
          onValidated: _oauthInviteValidated,
        ),
      _Step.app => AppShell(
          initialMode: _role ?? Role.klant,
          onLogout: _logout,
        ),
    };
  }
}
