import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/tokens.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/app_field.dart';
import '../../widgets/coacher_button.dart';
import '../../widgets/shell.dart';

const _goalOptions = [
  'Afvallen',
  'Spieropbouw',
  'Conditie',
  'Kracht',
  'Voeding',
  'Mindset',
];

class ClientRegisterData {
  const ClientRegisterData({
    required this.name,
    required this.email,
    required this.password,
    required this.goals,
  });

  final String name;
  final String email;
  final String password;
  final List<String> goals;
}

/// Port van ClientRegister.tsx.
class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({
    super.key,
    required this.onBack,
    required this.onSubmit,
  });

  final VoidCallback onBack;
  final Future<void> Function(ClientRegisterData data) onSubmit;

  @override
  State<ClientRegisterScreen> createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  final _goals = <String>{};
  var _touchedPw = false;
  var _touchedPw2 = false;
  var _loading = false;
  var _err = '';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  String get _pwError => _touchedPw && _pw.text.isNotEmpty && _pw.text.length < 8
      ? 'Minimaal 8 tekens'
      : '';

  String get _pw2Error => _touchedPw2 && _pw2.text != _pw.text
      ? 'Wachtwoorden komen niet overeen'
      : '';

  bool get _valid =>
      _name.text.isNotEmpty &&
      _email.text.isNotEmpty &&
      _pw.text.length >= 8 &&
      _pw.text == _pw2.text &&
      _goals.isNotEmpty;

  Future<void> _submit() async {
    if (!_valid) return;
    setState(() {
      _err = '';
      _loading = true;
    });
    try {
      await widget.onSubmit(ClientRegisterData(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _pw.text,
        goals: _goals.toList(),
      ));
    } catch (e) {
      if (mounted) setState(() => _err = 'Er ging iets mis');
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
            const SizedBox(height: 8),
            const Text(
              'Klant registratie',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textP,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '€10/maand — altijd opzegbaar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const AppLabel('Naam'),
            AppField(
              controller: _name,
              hint: 'Sophie Bakker',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            const AppLabel('E-mail'),
            AppField(
              controller: _email,
              hint: 'jij@email.nl',
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            const AppLabel('Wachtwoord'),
            Focus(
              onFocusChange: (has) {
                if (!has) setState(() => _touchedPw = true);
              },
              child: AppField(
                controller: _pw,
                hint: 'Min. 8 tekens',
                obscureText: true,
                error: _pwError.isNotEmpty,
                onChanged: (_) => setState(() {}),
              ),
            ),
            FieldErrorText(_pwError),
            const SizedBox(height: 12),
            const AppLabel('Bevestig wachtwoord'),
            Focus(
              onFocusChange: (has) {
                if (!has) setState(() => _touchedPw2 = true);
              },
              child: AppField(
                controller: _pw2,
                hint: 'Herhaal wachtwoord',
                obscureText: true,
                error: _pw2Error.isNotEmpty,
                onChanged: (_) => setState(() {}),
              ),
            ),
            FieldErrorText(_pw2Error),
            const SizedBox(height: 16),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppLabel('Mijn doelen'),
                SizedBox(width: 8),
                Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    '(meerdere mogelijk)',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textM,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3.6,
              children: [
                for (final g in _goalOptions)
                  _GoalChip(
                    label: g,
                    active: _goals.contains(g),
                    onTap: () => setState(() {
                      _goals.contains(g) ? _goals.remove(g) : _goals.add(g);
                    }),
                  ),
              ],
            ),
            if (_err.isNotEmpty) FieldErrorText(_err),
            const SizedBox(height: 20),
            Row(
              children: [
                CoacherButton(
                  variant: ButtonVariant.muted,
                  onPressed: widget.onBack,
                  child: const Text('Terug'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CoacherButton(
                    loading: _loading,
                    onPressed: _valid ? _submit : null,
                    child: const Text('Account aanmaken'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
            decoration: BoxDecoration(
              color: active ? AppColors.primarySoft : AppColors.card,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? AppColors.primary : AppColors.textS,
                ),
              ),
            ),
          ),
          if (active)
            Positioned(
              top: 5,
              right: 7,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(LucideIcons.check, color: Colors.white, size: 10),
              ),
            ),
        ],
      ),
    );
  }
}
