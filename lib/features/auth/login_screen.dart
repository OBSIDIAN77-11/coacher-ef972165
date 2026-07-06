import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens.dart';
import '../../data/repos/auth_repo.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/app_field.dart';
import '../../widgets/coacher_button.dart';
import '../../widgets/shell.dart';
import 'google_button.dart';

/// Port van Login.tsx.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    required this.onBack,
    required this.onSuccess,
    required this.onForgot,
  });

  final VoidCallback onBack;
  final VoidCallback onSuccess;
  final VoidCallback onForgot;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _loading = false;
  String _err = '';

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _err = '';
      _loading = true;
    });
    try {
      await ref
          .read(authRepoProvider)
          .signIn(email: _email.text.trim(), password: _pw.text);
      if (!mounted) return;
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      setState(() => _err = _friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shell(
      child: FadeUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Inloggen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textP,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Welkom terug bij Coacher',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            const AppLabel('E-mail'),
            AppField(
              controller: _email,
              hint: 'jij@email.nl',
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            const AppLabel('Wachtwoord'),
            AppField(
              controller: _pw,
              hint: 'Wachtwoord',
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
            ),
            if (_err.isNotEmpty) FieldErrorText(_err),
            const SizedBox(height: 20),
            CoacherButton(
              size: ButtonSize.lg,
              fullWidth: true,
              loading: _loading,
              onPressed: _submit,
              child: const Text('Inloggen'),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: widget.onForgot,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Wachtwoord vergeten?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Divider(color: AppColors.border, height: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OF',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textS,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.border, height: 1)),
              ],
            ),
            const SizedBox(height: 16),
            const GoogleButton(),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: widget.onBack,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Terug',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textS,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _friendlyAuthError(Object e) {
  final msg = e.toString();
  if (msg.contains('Invalid login credentials')) {
    return 'Ongeldige inloggegevens';
  }
  if (msg.contains('Email not confirmed')) {
    return 'Bevestig eerst je e-mailadres via de link in je inbox';
  }
  return 'Inloggen mislukt. Probeer het opnieuw.';
}
