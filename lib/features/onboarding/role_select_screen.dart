import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/tokens.dart';
import '../../data/models/role.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/coacher_button.dart';
import '../../widgets/shell.dart';

class _RoleOption {
  const _RoleOption(this.role, this.title, this.sub, this.icon);

  final Role role;
  final String title;
  final String sub;
  final IconData icon;
}

const _options = [
  _RoleOption(Role.coach, 'Ik ben Coach',
      'Maak een profiel en begeleid cliënten', LucideIcons.dumbbell),
  _RoleOption(Role.klant, 'Ik zoek een Coach',
      'Vind een trainer en bereik je doelen', LucideIcons.search),
];

/// Port van RoleSelect.tsx.
class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({
    super.key,
    required this.onBack,
    required this.onContinue,
  });

  final VoidCallback onBack;
  final ValueChanged<Role> onContinue;

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  Role? _sel;

  @override
  Widget build(BuildContext context) {
    return Shell(
      child: FadeUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Wie ben jij?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.textP,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kies je rol — later altijd te wisselen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            for (final option in _options) ...[
              _RoleCard(
                option: option,
                active: _sel == option.role,
                onTap: () => setState(() => _sel = option.role),
              ),
              const SizedBox(height: 12),
            ],
            const Spacer(),
            const SizedBox(height: 32),
            CoacherButton(
              size: ButtonSize.lg,
              fullWidth: true,
              onPressed:
                  _sel == null ? null : () => widget.onContinue(_sel!),
              child: const Text('Doorgaan'),
            ),
            const SizedBox(height: 12),
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.option,
    required this.active,
    required this.onTap,
  });

  final _RoleOption option;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: active ? AppGradients.soft : null,
          color: active ? null : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          boxShadow: active ? const [AppShadows.glow] : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: active ? AppGradients.primary : null,
                color: active ? null : AppColors.border,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                option.icon,
                color: active ? Colors.white : AppColors.textS,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textP,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.sub,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textS,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
