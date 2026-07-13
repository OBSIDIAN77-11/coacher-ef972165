import 'package:flutter/material.dart';
import '../../app/theme/tokens.dart';
import '../../core/auth_error.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_toggle.dart';
import '../../widgets/coacher_button.dart';
import '../../widgets/photo_upload.dart';
import '../../widgets/shell.dart';

const _specializations = [
  'Personal Training',
  'Kickboksen',
  'Voeding',
  'CrossFit',
  'Yoga',
  'Hardlopen',
];

class CoachRegisterData {
  const CoachRegisterData({
    required this.name,
    required this.email,
    required this.password,
    required this.specialization,
    required this.hourlyRate,
    required this.location,
    required this.onlineCoaching,
  });

  final String name;
  final String email;
  final String password;
  final String specialization;
  final String hourlyRate;
  final String location;
  final bool onlineCoaching;
}

/// Port van CoachRegister.tsx.
class CoachRegisterScreen extends StatefulWidget {
  const CoachRegisterScreen({
    super.key,
    required this.onBack,
    required this.onSubmit,
  });

  final VoidCallback onBack;
  final Future<void> Function(CoachRegisterData data) onSubmit;

  @override
  State<CoachRegisterScreen> createState() => _CoachRegisterScreenState();
}

class _CoachRegisterScreenState extends State<CoachRegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  final _rate = TextEditingController();
  final _loc = TextEditingController();
  var _spec = _specializations.first;
  var _online = true;
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
    _rate.dispose();
    _loc.dispose();
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
      _rate.text.isNotEmpty &&
      _loc.text.isNotEmpty;

  Future<void> _submit() async {
    if (!_valid) return;
    setState(() {
      _err = '';
      _loading = true;
    });
    try {
      await widget.onSubmit(CoachRegisterData(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _pw.text,
        specialization: _spec,
        hourlyRate: _rate.text.trim(),
        location: _loc.text.trim(),
        onlineCoaching: _online,
      ));
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
            const SizedBox(height: 8),
            const Text(
              'Coach registratie',
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
              'Eerste maand gratis',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            const Center(child: PhotoUpload()),
            const SizedBox(height: 18),
            const AppLabel('Naam'),
            AppField(
              controller: _name,
              hint: 'Yasmine El Karimi',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            const AppLabel('E-mail'),
            AppField(
              controller: _email,
              hint: 'coach@email.nl',
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
            const SizedBox(height: 12),
            const AppLabel('Specialisatie'),
            AppSelect<String>(
              value: _spec,
              items: [
                for (final s in _specializations)
                  DropdownMenuItem(value: s, child: Text(s)),
              ],
              onChanged: (v) => setState(() => _spec = v ?? _spec),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppLabel('Uurtarief (€)'),
                      AppField(
                        controller: _rate,
                        hint: '50',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppLabel('Locatie'),
                      AppField(
                        controller: _loc,
                        hint: 'Maastricht',
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  AppToggle(
                    on: _online,
                    onChanged: (v) => setState(() => _online = v),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Online coaching aanbieden',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textP,
                          ),
                        ),
                        Text(
                          'Bereik klanten door heel NL',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textS,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0x142563EB),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0x402563EB)),
              ),
              child: const Text(
                'Na registratie verifiëren we je diploma — 1-2 werkdagen.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
