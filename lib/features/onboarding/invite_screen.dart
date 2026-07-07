import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/tokens.dart';
import '../../core/supabase.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/app_field.dart';
import '../../widgets/coacher_button.dart';
import '../../widgets/shell.dart';

/// Gevalideerde uitnodiging: token + gegevens voor het registratieformulier.
class ValidatedInvite {
  const ValidatedInvite({
    required this.token,
    required this.coachName,
    required this.email,
  });

  final String token;
  final String coachName;
  final String email;
}

/// Klanten registreren alleen op uitnodiging van een coach: hier plakken
/// ze de uitnodigingslink of -code uit de e-mail.
class InviteScreen extends StatefulWidget {
  const InviteScreen({
    super.key,
    required this.onBack,
    required this.onValidated,
    this.initialToken,
  });

  final VoidCallback onBack;
  final ValueChanged<ValidatedInvite> onValidated;

  /// Token uit de /invite-link — wordt direct gevalideerd.
  final String? initialToken;

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final _input = TextEditingController();
  bool _loading = false;
  String _err = '';

  @override
  void initState() {
    super.initState();
    final token = widget.initialToken;
    if (token != null && token.isNotEmpty) {
      _input.text = token;
      WidgetsBinding.instance.addPostFrameCallback((_) => _validate());
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  /// Accepteert zowel een kale code als een volledige uitnodigingslink.
  String _extractToken(String raw) {
    final text = raw.trim();
    final uri = Uri.tryParse(text);
    final fromLink = uri?.queryParameters['token'];
    return (fromLink != null && fromLink.isNotEmpty) ? fromLink : text;
  }

  Future<void> _validate() async {
    final token = _extractToken(_input.text);
    if (token.isEmpty) return;
    setState(() {
      _err = '';
      _loading = true;
    });
    try {
      final res = await supabase.functions
          .invoke('validate-invite', body: {'token': token});
      final data = res.data as Map<String, dynamic>;
      if (data['valid'] == true) {
        widget.onValidated(ValidatedInvite(
          token: token,
          coachName: (data['coachName'] as String?) ?? 'je coach',
          email: (data['email'] as String?) ?? '',
        ));
        return;
      }
      final reason = data['reason'] as String?;
      setState(() => _err = switch (reason) {
            'used' => 'Deze uitnodiging is al gebruikt.',
            'expired' => 'Deze uitnodiging is verlopen. Vraag je coach om een nieuwe.',
            _ => 'Ongeldige uitnodigingscode. Controleer de link of code.',
          });
    } catch (_) {
      setState(() =>
          _err = 'Controleren mislukt. Controleer je internetverbinding.');
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
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(color: Color(0x6B2563EB), blurRadius: 40),
                  ],
                ),
                child: const Icon(LucideIcons.mailOpen,
                    color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Uitnodiging',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textP,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: SizedBox(
                width: 300,
                child: Text(
                  'Je kunt alleen deelnemen op uitnodiging van een coach. Plak hieronder de link of code uit je uitnodigingsmail.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textS,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const AppLabel('Uitnodigingslink of -code'),
            AppField(
              controller: _input,
              hint: 'Plak hier je uitnodiging',
              onSubmitted: (_) => _validate(),
            ),
            if (_err.isNotEmpty) FieldErrorText(_err),
            const SizedBox(height: 20),
            CoacherButton(
              size: ButtonSize.lg,
              fullWidth: true,
              loading: _loading,
              onPressed: _validate,
              child: const Text('Doorgaan'),
            ),
            const Spacer(),
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
