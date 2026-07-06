import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/theme_provider.dart';
import '../../app/theme/tokens.dart';
import '../../core/supabase.dart';
import '../../data/models/role.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/coacher_button.dart';
import 'settings_modals.dart';

/// Port van Settings.tsx — profielkaart, thematoggle, menu-items,
/// uitloggen en account verwijderen (met VERWIJDER-bevestiging).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({
    super.key,
    required this.mode,
    required this.name,
    required this.initials,
    required this.onLogout,
  });

  final Role mode;
  final String name;
  final String initials;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    final items = [
      (
        'Betaling instellen',
        'iDEAL of incasso activeren',
        LucideIcons.creditCard,
        () => showPaymentModal(context),
      ),
      (
        'Notificaties',
        'Push meldingen beheren',
        LucideIcons.bell,
        () => showNotificationsModal(context),
      ),
      if (mode == Role.coach)
        (
          'Uitbetaling instellen',
          'Bepaal zelf wanneer je betaald wordt',
          LucideIcons.wallet,
          () => showPayoutModal(context),
        ),
      (
        'Wachtwoord wijzigen',
        'Beveilig je account',
        LucideIcons.lock,
        () => showPasswordModal(context),
      ),
      (
        'Privacy & AVG',
        'Jouw gegevens en rechten',
        LucideIcons.shield,
        () => showPrivacyModal(context),
      ),
      (
        'Algemene voorwaarden',
        'Lees onze voorwaarden',
        LucideIcons.fileText,
        () => showTermsModal(context),
      ),
      (
        'Help & support',
        'Veelgestelde vragen',
        LucideIcons.circleQuestionMark,
        () => showHelpModal(context),
      ),
    ];

    return FadeUp(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profielkaart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x402563EB),
                    offset: Offset(0, 8),
                    blurRadius: 30,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: const BoxDecoration(
                        color: Color(0x1AFFFFFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: -40,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0x14FFFFFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0x38FFFFFF),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0x59FFFFFF), width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mode == Role.coach
                                ? 'Coach · Maastricht'
                                : 'Klant · Week 8',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xD9FFFFFF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Theme toggle
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  for (final (t, label, icon) in [
                    (CoacherTheme.light, 'Licht', LucideIcons.sun),
                    (CoacherTheme.dark, 'Donker', LucideIcons.moon),
                  ])
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            ref.read(themeProvider.notifier).set(t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            gradient:
                                theme == t ? AppGradients.primary : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon,
                                  size: 15,
                                  color: theme == t
                                      ? Colors.white
                                      : AppColors.textS),
                              const SizedBox(width: 8),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: theme == t
                                      ? Colors.white
                                      : AppColors.textS,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Menu items
            for (final (title, sub, icon, onTap) in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x402563EB),
                                offset: Offset(0, 4),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                          child: Icon(icon, size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textP,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                sub,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textS,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(LucideIcons.chevronRight,
                            size: 16, color: AppColors.textM),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Uitloggen
            GestureDetector(
              onTap: onLogout,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0x1AFF4D6A),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: const Color(0x40FF4D6A)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.logOut, size: 15, color: AppColors.red),
                    SizedBox(width: 8),
                    Text(
                      'Uitloggen',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Account verwijderen
            GestureDetector(
              onTap: () => _showDeleteSheet(context, onLogout),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.trash2, size: 14, color: AppColors.textS),
                    SizedBox(width: 8),
                    Text(
                      'Account verwijderen',
                      style: TextStyle(
                        color: AppColors.textS,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Coacher · versie 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textM,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showDeleteSheet(BuildContext context, VoidCallback onLogout) {
  showAppBottomSheet(
    context: context,
    title: 'Account verwijderen?',
    builder: (sheetContext) => _DeleteAccountSheet(onLogout: onLogout),
  );
}

class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet({required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final _text = TextEditingController();
  bool _loading = false;
  String _err = '';

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() {
      _err = '';
      _loading = true;
    });
    try {
      // Edge Function verwijdert de auth-user met de service-role
      // (vervangt de TanStack server-functie deleteMyAccount).
      await supabase.functions.invoke('delete-account');
      await supabase.auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onLogout();
    } catch (e) {
      if (mounted) setState(() => _err = 'Mislukt');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            text:
                'Dit verwijdert je account en alle bijbehorende gegevens permanent. Typ ',
            children: [
              const TextSpan(
                text: 'VERWIJDER',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.red,
                ),
              ),
              const TextSpan(text: ' om te bevestigen.'),
            ],
          ),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textS,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _text,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            color: AppColors.textP,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'VERWIJDER',
            hintStyle: const TextStyle(color: AppColors.textM),
            filled: true,
            fillColor: AppColors.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.red),
            ),
          ),
        ),
        if (_err.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              _err,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CoacherButton(
                variant: ButtonVariant.muted,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuleren'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CoacherButton(
                variant: ButtonVariant.danger,
                loading: _loading,
                onPressed: _text.text == 'VERWIJDER' ? _delete : null,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.trash2, size: 14),
                    SizedBox(width: 8),
                    Text('Verwijder'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
