import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/tokens.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/coacher_button.dart';

/// Port van KlantCoaching.tsx — tabs Training/Voeding/Voortgang/Check-in,
/// inclusief de gesimuleerde barcode-scanner en de voor/na-vergelijker.
class KlantCoaching extends StatefulWidget {
  const KlantCoaching({super.key});

  @override
  State<KlantCoaching> createState() => _KlantCoachingState();
}

class _KlantCoachingState extends State<KlantCoaching> {
  String _tab = 'training';

  static const _tabs = [
    ('training', 'Training'),
    ('voeding', 'Voeding'),
    ('voortgang', 'Voortgang'),
    ('checkin', 'Check-in'),
  ];

  @override
  Widget build(BuildContext context) {
    return FadeUp(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppGradients.primary.createShader(bounds),
              child: const Text(
                'Mijn coaching',
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
              'Week 8 · Yasmine El Karimi',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  for (final (key, label) in _tabs)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tab = key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 9),
                          decoration: BoxDecoration(
                            gradient:
                                _tab == key ? AppGradients.primary : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _tab == key
                                    ? Colors.white
                                    : AppColors.textS,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            switch (_tab) {
              'training' => const _TrainingTab(),
              'voeding' => const _VoedingTab(),
              'voortgang' => const _VoortgangTab(),
              _ => const _CheckinTab(),
            },
          ],
        ),
      ),
    );
  }
}

/* ─── TRAINING ─── */

class _TrainingTab extends StatefulWidget {
  const _TrainingTab();

  @override
  State<_TrainingTab> createState() => _TrainingTabState();
}

class _TrainingTabState extends State<_TrainingTab> {
  final _exercises = [
    ['Hip Thrust', '4×12 · 70kg', 'true'],
    ['Leg Press', '3×15', 'true'],
    ['Calf Raise', '3×20', 'false'],
  ];

  static const _week = [
    ('Ma', 'Rug', true, false),
    ('Wo', 'Borst', true, false),
    ('Vr', 'Billen', false, true),
    ('Za', 'Rust', false, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'VANDAAG',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textS,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Billen & Benen',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textP,
                ),
              ),
              const SizedBox(height: 16),
              for (final e in _exercises)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => setState(
                        () => e[2] = e[2] == 'true' ? 'false' : 'true'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              gradient: e[2] == 'true'
                                  ? AppGradients.primary
                                  : null,
                              borderRadius: BorderRadius.circular(7),
                              border: e[2] == 'true'
                                  ? null
                                  : Border.all(
                                      color: AppColors.borderHover,
                                      width: 1.5),
                            ),
                            child: e[2] == 'true'
                                ? const Icon(LucideIcons.check,
                                    size: 13, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Opacity(
                                  opacity: e[2] == 'true' ? 0.6 : 1,
                                  child: Text(
                                    e[0],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textP,
                                      decoration: e[2] == 'true'
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor: AppColors.textP,
                                    ),
                                  ),
                                ),
                                Text(
                                  e[1],
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
                  ),
                ),
              const SizedBox(height: 8),
              CoacherButton(
                fullWidth: true,
                onPressed: () {},
                child: const Text('Training starten'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Week overzicht',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textP,
          ),
        ),
        const SizedBox(height: 10),
        for (final (day, workout, done, today) in _week)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: today ? AppColors.primarySoft : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: today ? const Color(0x4D2563EB) : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textS,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    workout,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textP,
                    ),
                  ),
                ),
                if (done)
                  const Icon(LucideIcons.check,
                      size: 16, color: AppColors.primary),
                if (today)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'VANDAAG',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/* ─── VOEDING ─── */

class _VoedingTab extends StatefulWidget {
  const _VoedingTab();

  @override
  State<_VoedingTab> createState() => _VoedingTabState();
}

class _VoedingTabState extends State<_VoedingTab> {
  bool _showCompliment = true;
  final _meals = [
    ['Ontbijt', '420', 'true'],
    ['Lunch', '580', 'true'],
    ['Snack', '200', 'false'],
    ['Diner', '600', 'false'],
  ];

  static const _kcalTarget = 1900;

  void _openScanner() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, _, _) => const _ScannerView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kcalDone = _meals
        .where((m) => m[2] == 'true')
        .fold<int>(0, (s, m) => s + int.parse(m[1]));
    final kcalLeft = _kcalTarget - kcalDone;
    final pct = (kcalDone / _kcalTarget).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Streak-banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8A4C), Color(0xFFFFC857)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4DFF8A4C),
                offset: Offset(0, 4),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.flame, size: 28, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '10 dagen 🔥',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Nog 4 dagen tot volgende mijlpaal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xE6FFFFFF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showCompliment)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0x1AFFC857),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x4DFFC857)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.star,
                    size: 16, color: Color(0xFFFFC857)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '10 dagen bereikt! ⭐',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textP,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Geweldige consistentie, ga zo door!',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showCompliment = false),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(LucideIcons.x,
                        size: 14, color: AppColors.textS),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        // Macro-donut + balken
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 122,
                      height: 122,
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$kcalLeft',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textP,
                          ),
                        ),
                        const Text(
                          'kcal over',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textS,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  children: [
                    _MacroBar(
                        label: 'Eiwitten',
                        g: 98,
                        target: 140,
                        color: AppColors.primary),
                    SizedBox(height: 10),
                    _MacroBar(
                        label: 'Koolhydraten',
                        g: 150,
                        target: 220,
                        color: AppColors.accent),
                    SizedBox(height: 10),
                    _MacroBar(
                        label: 'Vetten',
                        g: 48,
                        target: 70,
                        color: AppColors.orange),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Barcode-scanknop
        GestureDetector(
          onTap: _openScanner,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0x0F2563EB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x662563EB), width: 1.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.camera, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Barcode scannen',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final m in _meals)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(
                  () => m[2] = m[2] == 'true' ? 'false' : 'true'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        gradient:
                            m[2] == 'true' ? AppGradients.primary : null,
                        borderRadius: BorderRadius.circular(7),
                        border: m[2] == 'true'
                            ? null
                            : Border.all(
                                color: AppColors.borderHover, width: 1.5),
                      ),
                      child: m[2] == 'true'
                          ? const Icon(LucideIcons.check,
                              size: 13, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        m[0],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textP,
                        ),
                      ),
                    ),
                    Text(
                      '${m[1]} kcal',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textS,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.g,
    required this.target,
    required this.color,
  });

  final String label;
  final int g;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = (g / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textP,
              ),
            ),
            Text(
              '$g/${target}g',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textS,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 6,
            child: Row(
              children: [
                Expanded(
                  flex: (pct * 100).round().clamp(1, 100),
                  child: Container(color: color),
                ),
                Expanded(
                  flex: (100 - pct * 100).round().clamp(0, 99),
                  child: Container(color: AppColors.border),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerView extends StatefulWidget {
  const _ScannerView();

  @override
  State<_ScannerView> createState() => _ScannerViewState();
}

enum _ScanStage { idle, scanning, result }

class _ScannerViewState extends State<_ScannerView> {
  _ScanStage _stage = _ScanStage.idle;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _stage = _ScanStage.scanning);
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _stage = _ScanStage.result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF2000000),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0x1AFFFFFF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x33FFFFFF)),
                  ),
                  child: const Icon(LucideIcons.x,
                      size: 16, color: Colors.white),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zoeker met hoekmarkeringen
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      children: [
                        for (final corner in const [
                          Alignment.topLeft,
                          Alignment.topRight,
                          Alignment.bottomLeft,
                          Alignment.bottomRight,
                        ])
                          Align(
                            alignment: corner,
                            child: _CornerMark(alignment: corner),
                          ),
                        if (_stage == _ScanStage.scanning)
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 2,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary,
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: switch (_stage) {
                        _ScanStage.idle => CoacherButton(
                            size: ButtonSize.lg,
                            fullWidth: true,
                            onPressed: _start,
                            child: const Text('Scan starten'),
                          ),
                        _ScanStage.scanning => const Text(
                            'Bezig met scannen…',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        _ScanStage.result => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: AppColors.border),
                                ),
                                child: const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Activia Aardbei',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '97 kcal · 4.3g eiwit · 14g koolh · 2.1g vet',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textS,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: CoacherButton(
                                      variant: ButtonVariant.muted,
                                      onPressed: () => setState(
                                          () => _stage = _ScanStage.idle),
                                      child: const Text('Opnieuw'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CoacherButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Toevoegen'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      },
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

class _CornerMark extends StatelessWidget {
  const _CornerMark({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: AppColors.primary, width: 3);
    final top = alignment.y < 0;
    final left = alignment.x < 0;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: top ? side : BorderSide.none,
          bottom: !top ? side : BorderSide.none,
          left: left ? side : BorderSide.none,
          right: !left ? side : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(12) : Radius.zero,
          topRight: top && !left ? const Radius.circular(12) : Radius.zero,
          bottomLeft:
              !top && left ? const Radius.circular(12) : Radius.zero,
          bottomRight:
              !top && !left ? const Radius.circular(12) : Radius.zero,
        ),
      ),
    );
  }
}

/* ─── VOORTGANG ─── */

class _VoortgangTab extends StatefulWidget {
  const _VoortgangTab();

  @override
  State<_VoortgangTab> createState() => _VoortgangTabState();
}

class _VoortgangTabState extends State<_VoortgangTab> {
  Uint8List? _before;
  Uint8List? _now;

  static const _weeks = [
    ('Start', '72.4', false),
    ('Week 2', '71.8', false),
    ('Week 4', '71.2', false),
    ('Week 6', '70.7', false),
    ('Week 8', '70.2', true),
  ];

  Future<void> _pick(bool isBefore) async {
    final file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      if (isBefore) {
        _before = bytes;
      } else {
        _now = bytes;
      }
    });
  }

  void _openCompare() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, _, _) =>
            _CompareView(before: _before!, now: _now!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'GEWICHT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textS,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              for (final (label, weight, isNow) in _weeks)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isNow
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0x2E2563EB), Color(0x2E60A5FA)],
                          )
                        : null,
                    color: isNow ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isNow
                          ? const Color(0x4D2563EB)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textP,
                        ),
                      ),
                      if (isNow) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'NU',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '${weight}kg',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textP,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [AppShadows.glowStrong],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTALE AFNAME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xD9FFFFFF),
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '-2.2 kg',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _PhotoSlot(
                label: 'Startfoto',
                bytes: _before,
                onTap: () => _pick(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PhotoSlot(
                label: 'Huidige foto',
                bytes: _now,
                onTap: () => _pick(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CoacherButton(
          fullWidth: true,
          variant: ButtonVariant.outline,
          onPressed:
              _before != null && _now != null ? _openCompare : null,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.arrowLeftRight, size: 14),
              SizedBox(width: 8),
              Text('Vergelijk voor & na'),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    required this.label,
    required this.bytes,
    required this.onTap,
  });

  final String label;
  final Uint8List? bytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: bytes != null ? Colors.transparent : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: bytes != null
              ? null
              : Border.all(color: AppColors.borderHover, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: bytes != null
            ? Image.memory(bytes!, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.upload,
                      size: 22, color: AppColors.textS),
                  const SizedBox(height: 6),
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
      ),
    );
  }
}

class _CompareView extends StatefulWidget {
  const _CompareView({required this.before, required this.now});

  final Uint8List before;
  final Uint8List now;

  @override
  State<_CompareView> createState() => _CompareViewState();
}

class _CompareViewState extends State<_CompareView> {
  double _split = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            onHorizontalDragUpdate: (details) => setState(() {
              _split =
                  (details.localPosition.dx / width).clamp(0.05, 0.95);
            }),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(widget.now, fit: BoxFit.cover),
                ClipRect(
                  clipper: _SplitClipper(fraction: _split),
                  child: Image.memory(widget.before, fit: BoxFit.cover),
                ),
                Positioned(
                  left: _split * width - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Color(0xCCFFFFFF), blurRadius: 12),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: _split * width - 22,
                  top: constraints.maxHeight / 2 - 22,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.arrowLeftRight,
                        size: 18, color: Colors.black),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: _CompareTag(label: 'Voor'),
                ),
                Positioned(
                  top: 20,
                  right: 70,
                  child: _CompareTag(label: 'Nu'),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: const Color(0x33FFFFFF)),
                      ),
                      child: const Icon(LucideIcons.x,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: width * 0.1,
                  right: width * 0.1,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: const Color(0x40FFFFFF),
                      thumbColor: Colors.white,
                      trackHeight: 3,
                    ),
                    child: Slider(
                      min: 0.05,
                      max: 0.95,
                      value: _split,
                      onChanged: (v) => setState(() => _split = v),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CompareTag extends StatelessWidget {
  const _CompareTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x80000000),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SplitClipper extends CustomClipper<Rect> {
  _SplitClipper({required this.fraction});

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_SplitClipper oldClipper) =>
      oldClipper.fraction != fraction;
}

/* ─── CHECK-IN ─── */

class _CheckinTab extends StatefulWidget {
  const _CheckinTab();

  @override
  State<_CheckinTab> createState() => _CheckinTabState();
}

class _CheckinTabState extends State<_CheckinTab> {
  double _energy = 7;
  double _intensity = 6;
  String _sleep = 'Goed';
  String _nutrition = 'Ja';
  final _notes = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x4D2563EB)),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                gradient: AppGradients.primary,
                shape: BoxShape.circle,
                boxShadow: [AppShadows.glowStrong],
              ),
              child:
                  const Icon(LucideIcons.check, size: 28, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Check-in verstuurd!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textP,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Yasmine reageert binnen 24 uur',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            CoacherButton(
              onPressed: () => setState(() => _sent = false),
              child: const Text('Nieuwe check-in'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0x142563EB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x402563EB)),
          ),
          child: const Text(
            'Yasmine reageert binnen 24 uur',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textP,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Question(
          label: 'Hoe is je energie deze week?',
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Laag',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textS,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${_energy.round()}/10',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Top',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textS,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              _CheckinSlider(
                value: _energy,
                onChanged: (v) => setState(() => _energy = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Question(
          label: 'Hoe sliep je gemiddeld?',
          child: _PillOptions(
            options: const ['Slecht', 'Matig', 'Goed', 'Top'],
            value: _sleep,
            onChanged: (v) => setState(() => _sleep = v),
          ),
        ),
        const SizedBox(height: 16),
        _Question(
          label: 'Hoe pittig was de training?',
          child: _CheckinSlider(
            value: _intensity,
            onChanged: (v) => setState(() => _intensity = v),
          ),
        ),
        const SizedBox(height: 16),
        _Question(
          label: 'Heb je je voeding gehaald?',
          child: _PillOptions(
            options: const ['Nee', 'Bijna', 'Ja'],
            value: _nutrition,
            onChanged: (v) => setState(() => _nutrition = v),
          ),
        ),
        const SizedBox(height: 16),
        _Question(
          label: 'Iets dat je wilt delen?',
          child: TextField(
            controller: _notes,
            maxLines: 3,
            style: const TextStyle(
              color: AppColors.textP,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Schrijf hier…',
              hintStyle: const TextStyle(color: AppColors.textS),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        CoacherButton(
          size: ButtonSize.lg,
          fullWidth: true,
          onPressed: () => setState(() => _sent = true),
          child: const Text('Verstuur check-in'),
        ),
      ],
    );
  }
}

class _CheckinSlider extends StatelessWidget {
  const _CheckinSlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.primary,
        overlayColor: const Color(0x1F2563EB),
        trackHeight: 4,
      ),
      child: Slider(
        min: 1,
        max: 10,
        divisions: 9,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _PillOptions extends StatelessWidget {
  const _PillOptions({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, s) in options.indexed) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(s),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
                decoration: BoxDecoration(
                  gradient: value == s ? AppGradients.primary : null,
                  color: value == s ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: value == s
                      ? null
                      : Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    s,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: value == s ? Colors.white : AppColors.textS,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textP,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
