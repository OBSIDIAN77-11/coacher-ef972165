import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/tokens.dart';
import '../../data/repos/auth_repo.dart';

const _googleSvg = '''
<svg width="18" height="18" viewBox="0 0 18 18" xmlns="http://www.w3.org/2000/svg">
  <path fill="#4285F4" d="M17.64 9.2c0-.64-.06-1.25-.17-1.84H9v3.48h4.84a4.14 4.14 0 0 1-1.8 2.72v2.26h2.92c1.7-1.57 2.68-3.88 2.68-6.62z"/>
  <path fill="#34A853" d="M9 18c2.43 0 4.47-.8 5.96-2.18l-2.92-2.26c-.81.54-1.84.86-3.04.86-2.34 0-4.32-1.58-5.03-3.7H.96v2.33A9 9 0 0 0 9 18z"/>
  <path fill="#FBBC05" d="M3.97 10.71A5.41 5.41 0 0 1 3.68 9c0-.6.1-1.18.29-1.71V4.96H.96A9 9 0 0 0 0 9c0 1.45.35 2.83.96 4.04l3.01-2.33z"/>
  <path fill="#EA4335" d="M9 3.58c1.32 0 2.5.45 3.44 1.35l2.58-2.58A9 9 0 0 0 .96 4.96l3.01 2.33C4.68 5.16 6.66 3.58 9 3.58z"/>
</svg>
''';

/// Port van GoogleButton.tsx — witte pill-knop met Google-logo.
/// Gebruikt native Supabase OAuth i.p.v. de Lovable cloud-auth.
class GoogleButton extends ConsumerStatefulWidget {
  const GoogleButton({super.key, this.label = 'Doorgaan met Google'});

  final String label;

  @override
  ConsumerState<GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends ConsumerState<GoogleButton> {
  bool _loading = false;
  String _error = '';

  Future<void> _click() async {
    setState(() {
      _error = '';
      _loading = true;
    });
    try {
      await ref.read(authRepoProvider).signInWithGoogle();
      // Sessie wordt opgepikt via onAuthStateChange in de flow-container.
    } catch (e) {
      if (mounted) setState(() => _error = 'Inloggen mislukt');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _loading ? null : _click,
          child: Opacity(
            opacity: _loading ? 0.7 : 1,
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.string(_googleSvg, width: 18, height: 18),
                  const SizedBox(width: 12),
                  Text(
                    _loading ? 'Bezig…' : widget.label,
                    style: const TextStyle(
                      color: AppColors.surface,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
