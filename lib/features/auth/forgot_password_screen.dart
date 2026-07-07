import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../../app/theme/tokens.dart';
import '../../data/repos/auth_repo.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/app_field.dart';
import '../../widgets/coacher_button.dart';
import '../../widgets/shell.dart';

/// Port van ForgotPassword.tsx.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String _err = '';

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _err = '';
      _loading = true;
    });
    try {
      await ref.read(authRepoProvider).sendPasswordReset(_email.text.trim());
      if (!mounted) return;
      setState(() => _sent = true);
    } catch (e) {
      if (!mounted) return;
      setState(
          () => _err = e is AuthException ? e.message : 'Er ging iets mis');
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
              'Wachtwoord vergeten',
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
              'We sturen je een link om opnieuw in te stellen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            if (_sent)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x402563EB)),
                ),
                child: Text.rich(
                  TextSpan(
                    text: 'Check je inbox op ',
                    children: [
                      TextSpan(
                        text: _email.text.trim(),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(
                        text:
                            '. Volg de link in de e-mail om je wachtwoord te resetten.',
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textP,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                ),
              )
            else ...[
              const AppLabel('E-mail'),
              AppField(
                controller: _email,
                hint: 'jij@email.nl',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                onSubmitted: (_) => _submit(),
              ),
              if (_err.isNotEmpty) FieldErrorText(_err),
              const SizedBox(height: 20),
              CoacherButton(
                size: ButtonSize.lg,
                fullWidth: true,
                loading: _loading,
                onPressed: _submit,
                child: const Text('Verstuur resetlink'),
              ),
            ],
            const SizedBox(height: 16),
            GestureDetector(
              onTap: widget.onBack,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Terug naar inloggen',
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
