import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/theme/tokens.dart';
import 'anim/float_anim.dart';

/// Port van archive/src/components/coacher/Logo.tsx.
class CoacherLogo extends StatelessWidget {
  const CoacherLogo({super.key, this.float = false, this.withTagline = true});

  final bool float;
  final bool withTagline;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [AppShadows.logoGlow],
      ),
      child: const Icon(LucideIcons.activity, color: Colors.white, size: 32),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        float ? FloatAnim(child: mark) : mark,
        const SizedBox(height: 20),
        const Text(
          'Coacher',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: AppColors.textP,
            letterSpacing: -1.5,
            height: 1,
          ),
        ),
        if (withTagline) ...[
          const SizedBox(height: 8),
          const Text(
            'PERSONAL TRAINING',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textM,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
