import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../core/auth_error.dart';
import '../../data/repos/auth_repo.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/app_field.dart';
import '../../widgets/coacher_button.dart';
import '../../widgets/shell.dart';

/// Port van routes/reset-password.tsx.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _loading = false;
  bool _done = false;
  String _err = '';
  Timer? _timer;

  @override
  void dispose() {
    _pw.dispose();
    _pw2.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _err = '');
    if (_pw.text.length < 8 || !RegExp(r'\d').hasMatch(_pw.text)) {
      setState(() => _err = 'Minimaal 8 tekens en 1 cijfer.');
      return;
    }
    if (_pw.text != _pw2.text) {
      setState(() => _err = 'Wachtwoorden komen niet overeen.');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authRepoProvider).updatePassword(_pw.text);
      if (!mounted) return;
      setState(() => _done = true);
      _timer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) context.go('/');
      });
    } catch (e) {
      if (mounted) {
        setState(() => _err = authErrorMessage(e));
      }
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
              'Nieuw wachtwoord',
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
              'Kies een nieuw wachtwoord voor je account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            if (_done)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x402563EB)),
                ),
                child: const Text(
                  'Wachtwoord bijgewerkt — je wordt doorgestuurd…',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textP,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                ),
              )
            else ...[
              const AppLabel('Nieuw wachtwoord'),
              AppField(
                controller: _pw,
                hint: 'Min. 8 tekens en 1 cijfer',
                obscureText: true,
              ),
              const SizedBox(height: 12),
              const AppLabel('Bevestig wachtwoord'),
              AppField(
                controller: _pw2,
                hint: 'Herhaal wachtwoord',
                obscureText: true,
                onSubmitted: (_) => _submit(),
              ),
              if (_err.isNotEmpty) FieldErrorText(_err),
              const SizedBox(height: 20),
              CoacherButton(
                size: ButtonSize.lg,
                fullWidth: true,
                loading: _loading,
                onPressed: _submit,
                child: const Text('Opslaan'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
