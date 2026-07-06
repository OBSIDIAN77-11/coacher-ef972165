import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/tokens.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/anim/soft_pulse.dart';
import '../../widgets/shell.dart';
import '../auth/google_button.dart';

const _trustItems = ['AVG-proof', 'iDEAL betaling'];

/// Port van Welcome.tsx.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onStart,
    required this.onLogin,
    required this.onDemo,
  });

  final VoidCallback onStart;
  final VoidCallback onLogin;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    return Shell(
      child: FadeUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),
            // Live pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0x402563EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SoftPulse(
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Nu beschikbaar in Nederland',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Headline
            const Text(
              'Jouw coach.',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: AppColors.textP,
                letterSpacing: -2,
                height: 1.04,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppGradients.primary.createShader(bounds),
              child: const Text(
                'Jouw resultaat.',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -2,
                  height: 1.04,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const SizedBox(
              width: 320,
              child: Text(
                'Vind een gecertificeerde personal trainer, plan sessies en bereik je doelen — alles in één app.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textS,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Trust badges
            Wrap(
              spacing: 20,
              runSpacing: 12,
              children: [
                for (final t in _trustItems)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Icon(LucideIcons.check,
                            color: Colors.white, size: 13),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textS,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 36),

            // CTAs — pill-vormig (borderRadius 50 in de bron)
            _PillButton(
              onTap: onStart,
              gradient: AppGradients.primary,
              child: const Text(
                'Account aanmaken',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _PillButton(
              onTap: onLogin,
              border: Border.all(color: AppColors.borderHover, width: 1.5),
              child: const Text(
                'Inloggen',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textP,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const GoogleButton(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onDemo,
              child: const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Demo bekijken →',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textS,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.onTap,
    required this.child,
    this.gradient,
    this.border,
  });

  final VoidCallback onTap;
  final Widget child;
  final Gradient? gradient;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient,
          border: border,
          borderRadius: BorderRadius.circular(50),
          boxShadow: gradient != null ? const [AppShadows.glowStrong] : null,
        ),
        child: Center(child: child),
      ),
    );
  }
}
