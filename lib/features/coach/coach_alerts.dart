import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/tokens.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/coacher_button.dart';

/// Port van CoachAlerts.tsx — meldingen/escalaties met ernst-niveaus
/// en een actie-sheet (mock-data).
class CoachAlerts extends StatefulWidget {
  const CoachAlerts({super.key});

  @override
  State<CoachAlerts> createState() => _CoachAlertsState();
}

class _AlertItem {
  const _AlertItem({
    required this.id,
    required this.title,
    required this.user,
    required this.severity,
    required this.color,
    required this.detail,
  });

  final String id;
  final String title;
  final String user;
  final String severity;
  final Color color;
  final String detail;
}

const _initialAlerts = [
  _AlertItem(
    id: 'a1',
    title: 'Ongepast gedrag tijdens sessie',
    user: 'Marco Jansen',
    severity: 'kritiek',
    color: AppColors.red,
    detail:
        'Twee cliënten melden grensoverschrijdend gedrag tijdens een groepssessie op donderdag. Beoordeel en kies een passende actie.',
  ),
  _AlertItem(
    id: 'a2',
    title: 'Herhaaldelijk te laat',
    user: 'Daan Verhoeven',
    severity: 'hoog',
    color: AppColors.red,
    detail:
        'Coach is de afgelopen 3 weken meermaals >15 min te laat verschenen bij geplande sessies.',
  ),
  _AlertItem(
    id: 'a3',
    title: 'Valse reviews geplaatst',
    user: 'Onbekend',
    severity: 'middel',
    color: AppColors.cyan,
    detail:
        'Vermoeden van zelfgeschreven positieve reviews op het profiel. Vraagt nader onderzoek.',
  ),
];

const _actions = [
  ('geen', 'Geen actie, sluiten', false),
  ('warn', 'Waarschuwing sturen', false),
  ('pause', 'Account tijdelijk non-actief', false),
  ('delete', 'Account permanent verwijderen', true),
];

class _CoachAlertsState extends State<CoachAlerts> {
  final _resolved = <String>{};

  void _openSheet(_AlertItem alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x99000000),
      constraints: const BoxConstraints(maxWidth: 430),
      builder: (sheetContext) => _ActionSheet(
        alert: alert,
        onConfirm: () {
          Navigator.of(sheetContext).pop();
          setState(() => _resolved.add(alert.id));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kritiek = _initialAlerts
        .where((a) => a.severity == 'kritiek' && !_resolved.contains(a.id))
        .length;
    final hoog = _initialAlerts
        .where((a) => a.severity == 'hoog' && !_resolved.contains(a.id))
        .length;

    return FadeUp(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Meldingen',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textP,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Beheer rapportages en escalaties',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _StatCard(
                        value: kritiek, label: 'Kritiek', color: AppColors.red)),
                const SizedBox(width: 8),
                Expanded(
                    child: _StatCard(
                        value: hoog, label: 'Hoog', color: AppColors.red)),
                const SizedBox(width: 8),
                Expanded(
                    child: _StatCard(
                        value: _resolved.length,
                        label: 'Afgehandeld',
                        color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 20),
            for (final a in _initialAlerts)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AlertCard(
                  alert: a,
                  done: _resolved.contains(a.id),
                  onOpen: () => _openSheet(a),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.33)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textS,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.done,
    required this.onOpen,
  });

  final _AlertItem alert;
  final bool done;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: done ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: done ? AppColors.surface : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border(
            left: done
                ? const BorderSide(color: AppColors.border)
                : BorderSide(color: alert.color, width: 4),
            top: BorderSide(
                color: done
                    ? AppColors.border
                    : alert.color.withValues(alpha: 0.33)),
            right: BorderSide(
                color: done
                    ? AppColors.border
                    : alert.color.withValues(alpha: 0.33)),
            bottom: BorderSide(
                color: done
                    ? AppColors.border
                    : alert.color.withValues(alpha: 0.33)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: done
                              ? const Color(0x262563EB)
                              : alert.color.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          (done ? 'Afgehandeld' : alert.severity)
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: done ? AppColors.primary : alert.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        alert.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textP,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.user,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: done
                        ? const Color(0x1F2563EB)
                        : alert.color.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    done ? LucideIcons.check : LucideIcons.triangleAlert,
                    size: 18,
                    color: done ? AppColors.primary : alert.color,
                  ),
                ),
              ],
            ),
            if (!done)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: GestureDetector(
                  onTap: onOpen,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'Bekijken',
                        style: TextStyle(
                          color: AppColors.textP,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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

class _ActionSheet extends StatefulWidget {
  const _ActionSheet({required this.alert, required this.onConfirm});

  final _AlertItem alert;
  final VoidCallback onConfirm;

  @override
  State<_ActionSheet> createState() => _ActionSheetState();
}

class _ActionSheetState extends State<_ActionSheet> {
  String _pick = 'warn';

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.border),
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderHover,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: alert.color.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.shieldAlert,
                      size: 20, color: alert.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textP,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.user,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              alert.detail,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'ONDERNEEM ACTIE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            for (final (key, label, danger) in _actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _pick = key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _pick == key
                          ? (danger
                              ? const Color(0x1AFF4D6A)
                              : AppColors.primarySoft)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _pick == key
                            ? (danger ? AppColors.red : AppColors.primary)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _pick == key
                                  ? (danger
                                      ? AppColors.red
                                      : AppColors.primary)
                                  : AppColors.textM,
                              width: 2,
                            ),
                          ),
                          child: _pick == key
                              ? Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: danger
                                          ? AppColors.red
                                          : AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color:
                                danger ? AppColors.red : AppColors.textP,
                          ),
                        ),
                      ],
                    ),
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.x, size: 14),
                        SizedBox(width: 8),
                        Text('Annuleren'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CoacherButton(
                    onPressed: widget.onConfirm,
                    child: const Text('Bevestigen'),
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
