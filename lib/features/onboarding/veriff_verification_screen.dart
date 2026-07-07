import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/tokens.dart';
import '../../core/supabase.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/anim/spinner.dart';
import '../../widgets/coacher_button.dart';
import '../../widgets/shell.dart';

/// Echte ID-verificatie via Veriff (hosted flow): Edge Function maakt
/// een sessie aan, de gebruiker doorloopt de Veriff-checkout (document +
/// selfie met echte gezichtsherkenning), en de webhook zet de uitslag in
/// de verifications-tabel die we hier pollen.
class VeriffVerificationScreen extends StatefulWidget {
  const VeriffVerificationScreen({
    super.key,
    required this.onSkip,
    required this.onDone,
  });

  final VoidCallback onSkip;
  final VoidCallback onDone;

  @override
  State<VeriffVerificationScreen> createState() =>
      _VeriffVerificationScreenState();
}

enum _Phase { intro, waiting, approved, declined, unavailable }

class _VeriffVerificationScreenState extends State<VeriffVerificationScreen> {
  _Phase _phase = _Phase.intro;
  String _err = '';
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _checkExisting() async {
    final status = await _fetchStatus();
    if (!mounted) return;
    if (status == 'approved') setState(() => _phase = _Phase.approved);
  }

  Future<String?> _fetchStatus() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    try {
      final row = await supabase
          .from('verifications')
          .select('status')
          .eq('user_id', user.id)
          .maybeSingle();
      return row?['status'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _start() async {
    setState(() => _err = '');
    try {
      final res = await supabase.functions.invoke('veriff-create-session');
      final data = res.data as Map<String, dynamic>;
      if (data['status'] == 'approved') {
        setState(() => _phase = _Phase.approved);
        return;
      }
      final url = data['url'] as String?;
      if (url == null) throw Exception('Geen verificatie-URL');
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      setState(() => _phase = _Phase.waiting);
      _poll = Timer.periodic(const Duration(seconds: 4), (_) async {
        final status = await _fetchStatus();
        if (!mounted) return;
        if (status == 'approved') {
          _poll?.cancel();
          setState(() => _phase = _Phase.approved);
        } else if (status == 'declined' || status == 'expired') {
          _poll?.cancel();
          setState(() => _phase = _Phase.declined);
        }
      });
    } catch (e) {
      // Functie niet gedeployed of VERIFF_API_KEY ontbreekt.
      final msg = e.toString();
      if (mounted) {
        setState(() {
          if (msg.contains('not_configured') || msg.contains('503')) {
            _phase = _Phase.unavailable;
          } else {
            _err = 'Verificatie starten mislukt. Probeer het later opnieuw.';
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shell(
      child: FadeUp(
        child: switch (_phase) {
          _Phase.intro => _buildIntro(),
          _Phase.waiting => _buildWaiting(),
          _Phase.approved => _buildResult(
              icon: LucideIcons.check,
              title: 'Identiteit geverifieerd',
              sub: 'Je ID en gezichtsherkenning zijn goedgekeurd.',
              buttonLabel: 'Doorgaan →',
              onPressed: widget.onDone,
            ),
          _Phase.declined => _buildResult(
              icon: LucideIcons.x,
              title: 'Verificatie niet gelukt',
              sub:
                  'De controle is afgewezen of verlopen. Je kunt het opnieuw proberen.',
              buttonLabel: 'Opnieuw proberen',
              onPressed: () => setState(() => _phase = _Phase.intro),
              danger: true,
            ),
          _Phase.unavailable => _buildResult(
              icon: LucideIcons.shieldOff,
              title: 'Verificatie nog niet beschikbaar',
              sub:
                  'De ID-verificatie is nog niet geactiveerd. Je kunt dit later doen via Instellingen.',
              buttonLabel: 'Doorgaan zonder verificatie',
              onPressed: widget.onSkip,
            ),
        },
      ),
    );
  }

  Widget _buildIntro() {
    const steps = [
      'ID-bewijs scannen (paspoort, ID-kaart of rijbewijs)',
      'Selfie maken — echte gezichtsherkenning',
    ];
    return Column(
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
            child: const Icon(LucideIcons.shield, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Verificatie',
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
              'Veilig en snel via Veriff — duurt 2 minuten. Je wordt doorgestuurd naar een beveiligde omgeving.',
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
        for (final (i, s) in steps.indexed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textP,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_err.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _err,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const Spacer(),
        const SizedBox(height: 32),
        CoacherButton(
          size: ButtonSize.lg,
          fullWidth: true,
          onPressed: _start,
          child: const Text('Verificatie starten'),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: widget.onSkip,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Later doen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaiting() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const Spinner(size: 28, color: AppColors.primary),
        const SizedBox(height: 20),
        const Text(
          'Wachten op verificatie…',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textP,
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(
          width: 300,
          child: Text(
            'Rond de stappen af in het Veriff-venster. Dit scherm werkt automatisch bij zodra de uitslag binnen is.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textS,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: widget.onSkip,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Later afronden',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult({
    required IconData icon,
    required String title,
    required String sub,
    required String buttonLabel,
    required VoidCallback onPressed,
    bool danger = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: danger ? null : AppGradients.primary,
            color: danger ? const Color(0x1FFF4D6A) : null,
            borderRadius: BorderRadius.circular(24),
            boxShadow: danger
                ? null
                : const [BoxShadow(color: Color(0x732563EB), blurRadius: 50)],
          ),
          child: Icon(icon,
              color: danger ? AppColors.red : Colors.white, size: 38),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textP,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 300,
          child: Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textS,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: CoacherButton(
            size: ButtonSize.lg,
            fullWidth: true,
            onPressed: onPressed,
            child: Text(buttonLabel),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
