import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demo_mode.dart';
import '../../app/theme/tokens.dart';
import '../../core/supabase.dart';
import '../../mock/mock_data.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/anim/soft_pulse.dart';
import '../../widgets/section.dart';

/// Port van CoachHome.tsx. In demo-modus de mock-data uit het origineel;
/// met een echte sessie het eigen (lege) coach-account: echte naam,
/// echte cliëntentelling, €0 en lege agenda.
class CoachHome extends ConsumerStatefulWidget {
  const CoachHome({super.key, required this.onOpenClient});

  final VoidCallback onOpenClient;

  @override
  ConsumerState<CoachHome> createState() => _CoachHomeState();
}

class _CoachHomeState extends ConsumerState<CoachHome> {
  String _name = '';
  int _clientCount = 0;
  List<String> _clientNames = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      final me = await supabase
          .from('profiles')
          .select('name')
          .eq('id', user.id)
          .maybeSingle();
      final clients = await supabase
          .from('profiles')
          .select('name')
          .eq('coach_id', user.id)
          .order('name');
      if (!mounted) return;
      setState(() {
        _name = (me?['name'] as String?) ?? '';
        _clientNames = [
          for (final c in clients)
            (c['name'] as String?)?.isNotEmpty == true
                ? c['name'] as String
                : 'Naamloos',
        ];
        _clientCount = _clientNames.length;
      });
    } catch (_) {
      // Geen sessie of netwerkfout: lege staten volstaan.
    }
  }

  @override
  Widget build(BuildContext context) {
    final demo = ref.watch(demoModeProvider);
    if (demo) return _DemoCoachHome(onOpenClient: widget.onOpenClient);

    final firstName = _name.split(' ').isNotEmpty && _name.isNotEmpty
        ? _name.split(' ').first
        : 'coach';
    final today = DateFormat('EEEE d MMMM', 'nl_NL').format(DateTime.now());

    return FadeUp(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              today.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textS,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppGradients.primary.createShader(bounds),
              child: Text(
                'Goedemorgen, $firstName',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '0 sessies vandaag · $_clientCount actieve cliënt${_clientCount == 1 ? '' : 'en'}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const _RealIncomeHero(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: LucideIcons.users,
                    value: '$_clientCount',
                    title: 'Cliënten',
                    label: 'actief',
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: _StatCard(
                    icon: LucideIcons.star,
                    value: '—',
                    title: 'Rating',
                    label: 'nog geen reviews',
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: _StatCard(
                    icon: LucideIcons.activity,
                    value: '0',
                    title: 'Sessies',
                    label: 'totaal',
                  ),
                ),
              ],
            ),
            SectionBlock(
              title: 'Agenda vandaag',
              child: const _EmptyCard(
                icon: LucideIcons.calendar,
                text: 'Nog geen sessies gepland.',
              ),
            ),
            SectionBlock(
              title: 'Cliënt voortgang',
              child: _clientNames.isEmpty
                  ? const _EmptyCard(
                      icon: LucideIcons.users,
                      text:
                          'Nog geen cliënten. Nodig je eerste cliënt uit via de Cliënten-tab.',
                    )
                  : Column(
                      children: [
                        for (final name in _clientNames)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: widget.onOpenClient,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        gradient: AppGradients.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          name
                                              .split(' ')
                                              .where((p) => p.isNotEmpty)
                                              .take(2)
                                              .map((p) => p[0])
                                              .join()
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textP,
                                        ),
                                      ),
                                    ),
                                    const Icon(LucideIcons.chevronRight,
                                        size: 16, color: AppColors.textM),
                                  ],
                                ),
                              ),
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

class _RealIncomeHero extends StatelessWidget {
  const _RealIncomeHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D2563EB),
            offset: Offset(0, 10),
            blurRadius: 30,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -62,
            right: -62,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0x12FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deze maand',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xA6FFFFFF),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '€0',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Nog geen sessies deze maand',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xD9FFFFFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textM),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Demo-weergave: exact het Lovable-origineel (mock-data van Yasmine).
class _DemoCoachHome extends StatelessWidget {
  const _DemoCoachHome({required this.onOpenClient});

  final VoidCallback onOpenClient;

  @override
  Widget build(BuildContext context) {
    return FadeUp(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'VRIJDAG, 6 JUNI',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textS,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppGradients.primary.createShader(bounds),
              child: const Text(
                'Goedemorgen, Yasmine',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '4 sessies vandaag · 24 actieve cliënten',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const _IncomeHero(),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: LucideIcons.users,
                    value: '24',
                    title: 'Cliënten',
                    label: '4 nieuw',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: LucideIcons.star,
                    value: '4.9',
                    title: 'Rating',
                    label: '87 reviews',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: LucideIcons.activity,
                    value: '312',
                    title: 'Sessies',
                    label: 'totaal',
                  ),
                ),
              ],
            ),
            SectionBlock(
              title: 'Agenda vandaag',
              badge: '4 sessies',
              badgeColor: AppColors.accent,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final (i, s) in coachSessions.indexed)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: i == 0
                              ? null
                              : const Border(
                                  top: BorderSide(color: AppColors.border)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Center(
                                child: Text(
                                  s.time,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textP,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${s.type} · ${s.dur}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textS,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: Color(0x262563EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.check,
                                  color: AppColors.primary, size: 14),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SectionBlock(
              title: 'Cliënt voortgang',
              child: Column(
                children: [
                  for (final c in coachClients)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ClientProgressCard(
                          client: c, onTap: onOpenClient),
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

class _IncomeHero extends StatelessWidget {
  const _IncomeHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D2563EB),
            offset: Offset(0, 10),
            blurRadius: 30,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -62,
            right: -62,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0x12FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deze maand',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xA6FFFFFF),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '€2.640',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.5,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '28 sessies · 78% van doel',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xD9FFFFFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0x2EFFFFFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SoftPulse(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF93C5FD),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Actief',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 6,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 78,
                        child: Container(color: Colors.white),
                      ),
                      Expanded(
                        flex: 22,
                        child: Container(color: const Color(0x33FFFFFF)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Doel: €3.400',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xBFFFFFFF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.title,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String title;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0x1F2563EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textP,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textS,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientProgressCard extends StatelessWidget {
  const _ClientProgressCard({required this.client, required this.onTap});

  final MockClient client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: client.gradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      client.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textP,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${client.goal} · ${client.week}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  client.delta,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: client.pct,
                      child: Container(
                        decoration:
                            BoxDecoration(gradient: client.gradient),
                      ),
                    ),
                    Expanded(
                      flex: 100 - client.pct,
                      child: Container(color: AppColors.card),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
