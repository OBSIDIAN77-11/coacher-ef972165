import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/tokens.dart';
import '../../core/supabase.dart';
import '../../widgets/anim/fade_up.dart';
import '../klant/klant_voortgang.dart';

/// Port van CoachClients.tsx — echte cliëntenlijst (profiles waar
/// coach_id = huidige coach) plus detailweergave met 5 tabs.
class CoachClients extends StatefulWidget {
  const CoachClients({super.key});

  @override
  State<CoachClients> createState() => _CoachClientsState();
}

class _RealClient {
  const _RealClient(this.id, this.name);

  final String id;
  final String name;

  String get initials => name
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p[0].toUpperCase())
      .join();
}

class _CoachClientsState extends State<CoachClients> {
  _RealClient? _selected;
  List<_RealClient> _clients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final rows = await supabase
          .from('profiles')
          .select('id, name')
          .eq('coach_id', user.id)
          .order('name');
      if (!mounted) return;
      setState(() {
        _clients = [
          for (final r in rows)
            _RealClient(
              r['id'] as String,
              (r['name'] as String?)?.isNotEmpty == true
                  ? r['name'] as String
                  : 'Naamloos',
            ),
        ];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    if (selected != null) {
      return _ClientDetail(
        client: selected,
        onBack: () => setState(() => _selected = null),
      );
    }

    final hasReal = _clients.isNotEmpty;

    return FadeUp(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Cliënten',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textP,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _loading
                  ? 'Laden…'
                  : hasReal
                      ? '${_clients.length} actieve cliënt${_clients.length == 1 ? '' : 'en'}'
                      : 'Nog geen cliënten gekoppeld',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!_loading && !hasReal)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: AppGradients.soft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: const BoxDecoration(
                        gradient: AppGradients.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.users,
                          color: Colors.white, size: 24),
                    ),
                    const Text(
                      'Nog geen cliënten',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textP,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Cliënten verschijnen hier zodra ze jou koppelen via hun profiel.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textS,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            if (hasReal) ...[
              const SizedBox(height: 20),
              for (final c in _clients)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = c),
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
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              gradient: AppGradients.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                c.initials,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textP,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Cliënt · tik om te openen',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textS,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClientDetail extends StatefulWidget {
  const _ClientDetail({required this.client, required this.onBack});

  final _RealClient client;
  final VoidCallback onBack;

  @override
  State<_ClientDetail> createState() => _ClientDetailState();
}

class _ClientDetailState extends State<_ClientDetail> {
  String _tab = 'voortgang';

  static const _tabs = [
    ('schema', 'Schema'),
    ('voeding', 'Voeding'),
    ('voortgang', 'Voortgang'),
    ('checkin', 'Check-in'),
    ('gezondheid', 'Gezondheid'),
  ];

  @override
  Widget build(BuildContext context) {
    return FadeUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: GestureDetector(
              onTap: widget.onBack,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.chevronLeft,
                      size: 16, color: AppColors.textS),
                  SizedBox(width: 4),
                  Text(
                    'Terug',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textS,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D000000),
                    offset: Offset(0, 10),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.client.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cliënt van jou',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xD9FFFFFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (key, label) in _tabs)
                    GestureDetector(
                      onTap: () => setState(() => _tab = key),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient:
                              _tab == key ? AppGradients.primary : null,
                          color: _tab == key ? null : AppColors.card,
                          borderRadius: BorderRadius.circular(999),
                          border: _tab == key
                              ? null
                              : Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _tab == key
                                ? Colors.white
                                : AppColors.textS,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_tab == 'voortgang')
            KlantVoortgang(viewUserId: widget.client.id)
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: switch (_tab) {
                'schema' => const _TabSchema(),
                'voeding' => const _TabVoeding(),
                'checkin' => const _TabCheckin(),
                _ => const _TabGezondheid(),
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _TabSchema extends StatelessWidget {
  const _TabSchema();

  static const _days = [
    (
      'Maandag',
      'Bovenlichaam',
      [
        'Bench press 4×8',
        'Pull-ups 3×10',
        'Shoulder press 3×12',
        'Tricep dips 3×10'
      ]
    ),
    (
      'Woensdag',
      'Onderlichaam',
      [
        'Squat 4×8',
        'Romanian deadlift 3×10',
        'Lunges 3×12',
        'Calf raises 3×15'
      ]
    ),
    (
      'Vrijdag',
      'Full body',
      ['Deadlift 4×6', 'Push press 3×8', 'Rows 3×10', 'Plank 3×60s']
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (day, focus, items) in _days)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textP,
                        ),
                      ),
                      Text(
                        focus,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final it in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '· $it',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TabVoeding extends StatelessWidget {
  const _TabVoeding();

  static const _meals = [
    ('Ontbijt', 'Havermout, banaan, walnoten', 420),
    ('Lunch', 'Kip, zoete aardappel, broccoli', 610),
    ('Diner', 'Zalm, quinoa, gegrilde groenten', 580),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (name, desc, kcal) in _meals)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DetailCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textP,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          desc,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0x1F2563EB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$kcal kcal',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TabCheckin extends StatelessWidget {
  const _TabCheckin();

  static const _qa = [
    (
      'Hoe voel je je deze week?',
      'Energiek, slaap is beter dan vorige week.'
    ),
    ('Hoe verliep je voeding?', '85% schema gevolgd, één keer afgeweken.'),
    (
      'Trainingsintensiteit?',
      'Squats waren zwaar, deadlifts gingen goed.'
    ),
    ('Wat wil je aanpassen?', 'Iets meer kracht in onderlichaam.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (q, a) in _qa)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _DetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textP,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D2563EB),
                  offset: Offset(0, 8),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Schema aanpassen',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TabGezondheid extends StatelessWidget {
  const _TabGezondheid();

  static const _bio = [
    ('Herstel', '78%', AppColors.primary),
    ('HRV', '52 ms', AppColors.accent),
    ('Hartslag', '58 bpm', AppColors.red),
    ('VO2Max', '44.5', AppColors.cyan),
  ];

  static const _phases = [
    ('Diep', 24, AppColors.accent),
    ('REM', 22, AppColors.primary),
    ('Licht', 48, AppColors.purple),
    ('Wakker', 6, AppColors.textM),
  ];

  static const _week = [4.8, 6.5, 7.8, 7.2, 8.1, 6.9, 7.4];
  static const _days = ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Biometrics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textP,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x1FFF4D6A),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.heart, size: 11, color: AppColors.red),
                  SizedBox(width: 6),
                  Text(
                    'Apple Health',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.2,
          children: [
            for (final (label, value, color) in _bio)
              _DetailCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textS,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _DetailCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Slaap',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textS,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '7.2u',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textP,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Score',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textS,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '84/100',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      for (final p in _phases)
                        Expanded(flex: p.$2, child: Container(color: p.$3)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final p in _phases)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: p.$3,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          p.$1,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textS,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _DetailCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Slaap deze week',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textP,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 118,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final (i, h) in _week.indexed) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: (h / 10) * 100,
                              constraints:
                                  const BoxConstraints(minHeight: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    AppColors.primary,
                                    AppColors.accent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _days[i],
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textS,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x4D2563EB)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x2E2563EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.lightbulb,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COACH ADVIES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sophie heeft goed geslapen, schema iets zwaarder.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textP,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
