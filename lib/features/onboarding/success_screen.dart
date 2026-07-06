import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/tokens.dart';
import '../../data/models/role.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/coacher_button.dart';
import '../../widgets/shell.dart';

/// Port van Success.tsx.
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.role, required this.onOpen});

  final Role role;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final sub = role == Role.coach
        ? 'We verifiëren je diploma binnen 2 werkdagen'
        : 'Je account is actief. Vind nu je eerste coach!';

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
                child: const Icon(LucideIcons.check,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(height: 24),
              const Text(
                'Account aangemaakt!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textP,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 320,
                child: Text(
                  sub,
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
                  onPressed: onOpen,
                  child: const Text('App openen →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
