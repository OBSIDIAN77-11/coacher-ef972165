import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/tokens.dart';
import '../../core/supabase.dart';
import '../../widgets/anim/fade_up.dart';

/// Port van KlantHome.tsx — dashboard met herstel-donut, slaapkaart,
/// AI-tip, voortgangs-hero en trainingskaart. Naam en coach komen uit
/// de database, de rest is mock (parity met de bron).
class KlantHome extends StatefulWidget {
  const KlantHome({super.key});

  @override
  State<KlantHome> createState() => _KlantHomeState();
}

class _KlantHomeState extends State<KlantHome> {
  String _name = '';
  String _coachName = '';

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
          .select('name, coach_id')
          .eq('id', user.id)
          .maybeSingle();
      if (!mounted || me == null) return;
      setState(() => _name = (me['name'] as String?) ?? '');
      final coachId = me['coach_id'] as String?;
      if (coachId != null) {
        final coach = await supabase
            .from('profiles')
            .select('name')
            .eq('id', coachId)
            .maybeSingle();
        if (mounted && coach?['name'] != null) {
          setState(() => _coachName = coach!['name'] as String);
        }
      }
    } catch (_) {
      // Demo-modus zonder sessie.
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstName =
        _name.split(' ').firstOrNull?.trim().isNotEmpty == true
            ? _name.split(' ').first.trim()
            : 'daar';
    final today =
        DateFormat('EEEE, d MMMM', 'nl_NL').format(DateTime.now());

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
                'Hallo, $firstName',
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
              _coachName.isNotEmpty
                  ? 'Coach: ${_coachName.split(' ').first}'
                  : 'Nog geen coach gekoppeld',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gezondheid vandaag',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textP,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x1FFF4D6A),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.heart, size: 11, color: AppColors.red),
                      SizedBox(width: 4),
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
            const _RecoveryCard(),
            const SizedBox(height: 12),
            const _SleepCard(),
            const SizedBox(height: 12),
            const _AiTip(),
            const SizedBox(height: 20),
            const _ProgressHero(),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                    child: _Stat(
                        value: '28', label: 'Sessies', color: AppColors.primary)),
                SizedBox(width: 8),
                Expanded(
                    child: _Stat(
                        value: '14d',
                        label: 'Streak',
                        color: AppColors.cyan,
                        icon: LucideIcons.flame)),
                SizedBox(width: 8),
                Expanded(
                    child: _Stat(
                        value: '1.420', label: 'Kcal', color: AppColors.accent)),
              ],
            ),
            const SizedBox(height: 24),
            const _TrainingCard(),
          ],
        ),
      ),
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  const _RecoveryCard();

  static const _bio = [
    ('Hartslag', '58 bpm', AppColors.red),
    ('Slaap', '7.2u', AppColors.accent),
    ('Stappen', '8.4k', AppColors.primary),
    ('VO2Max', '44.5', AppColors.cyan),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Herstel',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textS,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '78%',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Klaar voor training',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textP,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(96, 96),
                      painter: _DonutPainter(pct: 0.78),
                    ),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'HRV',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textS,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '52',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textP,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final (i, b) in _bio.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          b.$2,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: b.$3,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b.$1,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textS,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.pct});

  final double pct;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 8.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2 + 5);

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.card;
    canvas.drawArc(arcRect, 0, math.pi * 2, false, bg);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = AppGradients.primary.createShader(rect);
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * pct, false, fg);
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) => oldDelegate.pct != pct;
}

class _SleepCard extends StatelessWidget {
  const _SleepCard();

  static const _phases = [
    ('Diep', 24, AppColors.accent),
    ('REM', 22, AppColors.primary),
    ('Licht', 48, AppColors.purple),
    ('Wakker', 6, AppColors.textM),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Slaapscore',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textS,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: const TextSpan(
                      text: '84',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textP,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: '/100',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textS,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '23:14 → 06:26',
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
                      fontSize: 13,
                      color: AppColors.textP,
                      fontWeight: FontWeight.w800,
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
              height: 12,
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
                      '${p.$1} ${p.$2}%',
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
    );
  }
}

class _AiTip extends StatelessWidget {
  const _AiTip();

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  'AI TIP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Je herstel is 78%, ideaal voor een zware training.',
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
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero();

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
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voortgang',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xA6FFFFFF),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '-4.2',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.5,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'kg verloren · Week 8',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xD9FFFFFF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '72%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 6,
                  child: Row(
                    children: [
                      Expanded(flex: 72, child: Container(color: Colors.white)),
                      Expanded(
                        flex: 28,
                        child: Container(color: const Color(0x38FFFFFF)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.color,
    this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData? icon;

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
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: color,
                ),
              ),
            ],
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

class _TrainingCard extends StatefulWidget {
  const _TrainingCard();

  @override
  State<_TrainingCard> createState() => _TrainingCardState();
}

class _TrainingCardState extends State<_TrainingCard> {
  final _done = <String>{'hip', 'leg'};

  static const _exercises = [
    ('hip', 'Hip Thrust', '4×12 · 70kg'),
    ('leg', 'Leg Press', '3×15'),
    ('calf', 'Calf Raise', '3×20'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TRAINING VANDAAG',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${_done.length}/${_exercises.length}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textS,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Vrijdag: Billen & Benen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textP,
            ),
          ),
          const SizedBox(height: 12),
          for (final e in _exercises)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ExerciseRow(
                name: e.$2,
                spec: e.$3,
                done: _done.contains(e.$1),
                onTap: () => setState(() {
                  _done.contains(e.$1) ? _done.remove(e.$1) : _done.add(e.$1);
                }),
              ),
            ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D2563EB),
                    offset: Offset(0, 6),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Training starten',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.name,
    required this.spec,
    required this.done,
    required this.onTap,
  });

  final String name;
  final String spec;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                gradient: done ? AppGradients.primary : null,
                borderRadius: BorderRadius.circular(6),
                border: done
                    ? null
                    : Border.all(color: AppColors.textM, width: 2),
              ),
              child: done
                  ? const Icon(LucideIcons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: done ? AppColors.textS : AppColors.textP,
                      decoration:
                          done ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.textS,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    spec,
                    style: const TextStyle(
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
    );
  }
}
