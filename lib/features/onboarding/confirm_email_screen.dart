import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/tokens.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/coacher_button.dart';
import '../../widgets/shell.dart';

/// Na registratie: het account bestaat, maar de e-mail moet eerst
/// bevestigd worden voordat er ingelogd kan worden.
class ConfirmEmailScreen extends StatelessWidget {
  const ConfirmEmailScreen({
    super.key,
    required this.email,
    required this.onToLogin,
  });

  final String email;
  final VoidCallback onToLogin;

  @override
  Widget build(BuildContext context) {
    return Shell(
      scrollable: false,
      child: FadeUp(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Color(0x732563EB), blurRadius: 50),
                  ],
                ),
                child:
                    const Icon(LucideIcons.mail, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bevestig je e-mail',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textP,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 320,
                child: Text.rich(
                  TextSpan(
                    text: 'We hebben een bevestigingslink gestuurd naar ',
                    children: [
                      TextSpan(
                        text: email,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(
                        text:
                            '. Klik op de link in de e-mail om je account te activeren en log daarna in.',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textS,
                    height: 1.7,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: CoacherButton(
                  size: ButtonSize.lg,
                  fullWidth: true,
                  onPressed: onToLogin,
                  child: const Text('Ik heb bevestigd — inloggen'),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(
                width: 300,
                child: Text(
                  'Geen mail ontvangen? Check je spamfolder.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
