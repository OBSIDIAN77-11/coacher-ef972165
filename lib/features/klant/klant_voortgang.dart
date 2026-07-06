import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/tokens.dart';
import '../../core/supabase.dart';
import '../../data/models/measurement.dart';
import '../../data/repos/progress_repo.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/dashed_border.dart';

/// Port van KlantVoortgang.tsx — het grootste echte-data scherm:
/// gewicht-gauge + grafiek, 17 metingen, progressiefoto's en de
/// foto-vergelijker met versleepbare divider.
class KlantVoortgang extends ConsumerStatefulWidget {
  const KlantVoortgang({super.key, this.viewUserId, this.standalone = false});

  /// Wanneer gezet bekijkt een coach de voortgang van deze klant
  /// (RLS staat dat toe via profiles.coach_id).
  final String? viewUserId;

  /// Als eigen tab in de AppShell: header blijft sticky en de inhoud
  /// scrolt eronder (position:sticky in de bron). Embedded (in
  /// ClientDetail) scrolt alles mee met de buitenste scroller.
  final bool standalone;

  @override
  ConsumerState<KlantVoortgang> createState() => _KlantVoortgangState();
}

class _KlantVoortgangState extends ConsumerState<KlantVoortgang> {
  String _tab = 'gewicht';
  String? _userId;
  Map<String, List<MeasurePoint>> _entries = {};
  Map<String, List<PhotoItem>> _photos = {
    for (final (key, _) in photoCategories) key: [],
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final targetId = widget.viewUserId ?? supabase.auth.currentUser?.id;
    if (targetId == null) return;
    _userId = targetId;
    final repo = ref.read(progressRepoProvider);
    try {
      final entries = await repo.fetchMeasurements(targetId);
      if (mounted) setState(() => _entries = entries);
      final photos = await repo.fetchPhotos(targetId);
      if (mounted) setState(() => _photos = photos);
    } catch (_) {
      // Demo-modus of netwerkfout: lege staat tonen.
    }
  }

  Future<void> _saveMeasurements(Map<String, double> values) async {
    final userId = _userId;
    if (userId == null || values.isEmpty) return;
    await ref.read(progressRepoProvider).addMeasurements(userId, values);
    final now = DateTime.now();
    setState(() {
      for (final e in values.entries) {
        (_entries[e.key] ??= []).add(MeasurePoint(now, e.value));
      }
    });
  }

  Future<void> _addPhoto(String key) async {
    final userId = _userId;
    if (userId == null) return;
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final ext = file.name.contains('.')
        ? file.name.split('.').last.toLowerCase()
        : 'jpg';
    final item = await ref.read(progressRepoProvider).addPhoto(
          userId: userId,
          photoKey: key,
          bytes: bytes,
          ext: ext,
          contentType: file.mimeType ?? 'image/jpeg',
        );
    if (mounted) {
      setState(() => _photos = {
            ..._photos,
            key: [..._photos[key] ?? [], item],
          });
    }
  }

  void _openAddSheet() {
    showAppBottomSheet(
      context: context,
      title: 'Nieuwe meting',
      builder: (sheetContext) => _AddMeasurementSheet(
        onSave: (values) {
          Navigator.of(sheetContext).pop();
          _saveMeasurements(values);
        },
      ),
    );
  }

  void _openDetail(MeasureMeta meta) {
    final data = <MeasurePoint>[...?_entries[meta.key]]
      ..sort((a, b) => a.date.compareTo(b.date));
    showAppBottomSheet(
      context: context,
      title: meta.label,
      builder: (context) => _MeasureDetailBody(meta: meta, data: data),
    );
  }

  Widget _tabBody(List<MeasurePoint> weightData) => switch (_tab) {
        'gewicht' => _GewichtTab(data: weightData),
        'metingen' => _MetingenTab(entries: _entries, onOpen: _openDetail),
        'fotos' => _FotosTab(
            photos: _photos,
            onAdd: _addPhoto,
            onCompare: () => setState(() => _tab = 'vergelijk'),
          ),
        _ => _VergelijkTab(photos: _photos),
      };

  @override
  Widget build(BuildContext context) {
    final weightData = <MeasurePoint>[...?_entries['gewicht']]
      ..sort((a, b) => a.date.compareTo(b.date));

    return FadeUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sticky-achtige header met tabs
          ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                decoration: const BoxDecoration(
                  color: Color(0xED0F1525),
                  border:
                      Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Voortgang',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accent,
                            letterSpacing: -0.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: _openAddSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0x1F60A5FA),
                              borderRadius: BorderRadius.circular(999),
                              border:
                                  Border.all(color: AppColors.accent),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.plus,
                                    size: 14, color: AppColors.accent),
                                SizedBox(width: 6),
                                Text(
                                  'Meting',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final (key, label) in const [
                            ('gewicht', 'Gewicht'),
                            ('metingen', 'Metingen'),
                            ('fotos', "Progressiefoto's"),
                            ('vergelijk', "Vergelijk progressiefoto's"),
                          ]) ...[
                            GestureDetector(
                              onTap: () => setState(() => _tab = key),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 9),
                                decoration: BoxDecoration(
                                  color: _tab == key
                                      ? AppColors.accent
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(999),
                                  border: _tab == key
                                      ? null
                                      : Border.all(
                                          color: AppColors.border),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _tab == key
                                        ? Colors.white
                                        : AppColors.textS,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.standalone)
            // Eigen scroller: de header hierboven blijft staan
            // (position:sticky-parity met de bron).
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                child: _tabBody(weightData),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: _tabBody(weightData),
            ),
        ],
      ),
    );
  }
}

/* ------------------------ Gedeelde kaart ------------------------ */

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, this.right});

  final String title;
  final Widget? right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textP,
            ),
          ),
          if (right != null) right!,
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textP),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textP,
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------ Gewicht ------------------------ */

class _GewichtTab extends StatelessWidget {
  const _GewichtTab({required this.data});

  final List<MeasurePoint> data;

  @override
  Widget build(BuildContext context) {
    final start = data.isNotEmpty ? data.first.value : 0.0;
    final now = data.isNotEmpty ? data.last.value : 0.0;
    final lost = data.isNotEmpty
        ? double.parse((start - now).toStringAsFixed(1))
        : 0.0;
    final values = [for (final d in data) d.value];
    final min = values.isNotEmpty ? values.reduce(math.min) : 0.0;
    final max = values.isNotEmpty ? values.reduce(math.max) : 0.0;
    final avg = values.isNotEmpty
        ? double.parse(
            (values.reduce((a, b) => a + b) / values.length)
                .toStringAsFixed(1))
        : 0.0;

    final fmt = DateFormat('d-M-y');
    final today = DateTime.now();
    final past = today.subtract(const Duration(days: 30));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Card(
          child: Column(
            children: [
              const _CardHeader(
                title: 'Voortgang',
                right: _PillBadge(icon: LucideIcons.pencil, label: 'Bewerken'),
              ),
              _Gauge(value: lost, unit: 'kg', start: start, end: now),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _CardHeader(
                title: 'Gewicht',
                right: _PillBadge(
                    icon: LucideIcons.calendar, label: 'Laatste 30 dagen'),
              ),
              _LineChart(data: data, unit: 'kg'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fmt.format(past),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textS,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    fmt.format(today),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textS,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                icon: LucideIcons.trendingDown,
                color: AppColors.primary,
                label: 'Minimaal',
                value: '$min kg',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStat(
                icon: LucideIcons.minus,
                color: AppColors.cyan,
                label: 'Gemiddelde',
                value: '$avg kg',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStat(
                icon: LucideIcons.trendingUp,
                color: AppColors.red,
                label: 'Maximaal',
                value: '$max kg',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textS,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textP,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Gauge extends StatelessWidget {
  const _Gauge({
    required this.value,
    required this.unit,
    required this.start,
    required this.end,
  });

  final double value;
  final String unit;
  final double start;
  final double end;

  String _fmtNum(double n) =>
      n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toString();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 130,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                CustomPaint(
                  size: const Size(220, 130),
                  painter: _GaugePainter(value: value),
                ),
                Positioned(
                  top: 56,
                  child: Column(
                    children: [
                      const Text(
                        'nu',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textS,
                        ),
                      ),
                      Text(
                        '${_fmtNum(end)} $unit',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Verloren ${value >= 0 ? _fmtNum(value) : 0} $unit',
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmtNum(start),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textP,
                  ),
                ),
                Text(
                  _fmtNum(end),
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
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.value});

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, 110),
      radius: 90,
    );

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.border;
    canvas.drawArc(rect, math.pi, math.pi, false, bg);

    // Zelfde vulformule als de bron: |waarde| * 20 op een booglengte 283.
    final frac = math.min(283.0, value.abs() * 20) / 283.0;
    if (frac > 0) {
      final fg = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
        ).createShader(rect);
      canvas.drawArc(rect, math.pi, math.pi * frac, false, fg);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) => oldDelegate.value != value;
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.data, required this.unit});

  final List<MeasurePoint> data;
  final String unit;

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Geen grafiekgegevens beschikbaar.',
            style: TextStyle(
              color: AppColors.textS,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(data: data, unit: unit),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.data, required this.unit});

  final List<MeasurePoint> data;
  final String unit;

  String _fmtNum(double n) =>
      n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toString();

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 20.0;
    final values = [for (final d in data) d.value];
    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    final span = (max - min) == 0 ? 1.0 : max - min;

    final points = <Offset>[
      for (final (i, d) in data.indexed)
        Offset(
          pad + (i / (data.length - 1)) * (size.width - pad * 2),
          size.height -
              pad -
              ((d.value - min) / span) * (size.height - pad * 2),
        ),
    ];

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.accent;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, line);

    final dot = Paint()..color = AppColors.accent;
    for (final p in points) {
      canvas.drawCircle(p, 3, dot);
    }

    void label(String text, Offset anchor) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: AppColors.textS,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, anchor - Offset(tp.width, 0));
    }

    label('${_fmtNum(max)}$unit', Offset(size.width - pad, 2));
    label('${_fmtNum(min)}$unit', Offset(size.width - pad, size.height - 14));
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) =>
      oldDelegate.data != data;
}

/* ------------------------ Metingen ------------------------ */

class _MetingenTab extends StatelessWidget {
  const _MetingenTab({required this.entries, required this.onOpen});

  final Map<String, List<MeasurePoint>> entries;
  final ValueChanged<MeasureMeta> onOpen;

  String _fmtNum(double n) =>
      n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toString();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Metingen',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textP,
            ),
          ),
        ),
        for (final m in measures)
          Builder(builder: (context) {
            final data = entries[m.key] ?? [];
            final last = data.isNotEmpty ? data.last.value : 0.0;
            final prev =
                data.length >= 2 ? data[data.length - 2].value : last;
            final delta =
                double.parse((last - prev).toStringAsFixed(1));
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onOpen(m),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            m.label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                          ),
                          const Icon(LucideIcons.chevronRight,
                              size: 18, color: AppColors.accent),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${_fmtNum(last)} ${m.unit}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textP,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _DeltaPill(delta: delta, unit: m.unit),
                            ],
                          ),
                          Text(
                            data.length >= 2
                                ? '${data.length} metingen'
                                : 'Geen grafiekgegevens beschikbaar.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textS,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vorig: ${_fmtNum(prev)} ${m.unit}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({required this.delta, required this.unit});

  final double delta;
  final String unit;

  @override
  Widget build(BuildContext context) {
    if (delta == 0) {
      return const Text(
        '—',
        style: TextStyle(
          color: AppColors.textS,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    final up = delta > 0;
    return Text(
      '${up ? '▲' : '▼'} ${delta.abs()}$unit',
      style: TextStyle(
        color: up ? AppColors.red : AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

/* ------------------------ Foto's ------------------------ */

class _FotosTab extends StatelessWidget {
  const _FotosTab({
    required this.photos,
    required this.onAdd,
    required this.onCompare,
  });

  final Map<String, List<PhotoItem>> photos;
  final ValueChanged<String> onAdd;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Progressiefoto's",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textP,
              ),
            ),
            GestureDetector(
              onTap: onCompare,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Foto's vergelijken",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(LucideIcons.chevronRight,
                      size: 14, color: AppColors.accent),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final (key, label) in photoCategories) ...[
          _PhotoRow(
            label: label,
            list: photos[key] ?? const [],
            onPick: () => onAdd(key),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({
    required this.label,
    required this.list,
    required this.onPick,
  });

  final String label;
  final List<PhotoItem> list;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textP,
              ),
            ),
            GestureDetector(
              onTap: onPick,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(LucideIcons.imagePlus,
                    size: 18, color: AppColors.textP),
              ),
            ),
          ],
        ),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Upload een foto om je fitnessreis bij te houden!',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    list[i].url,
                    width: 110,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 110,
                      height: 150,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/* ------------------------ Vergelijk ------------------------ */

class _VergelijkTab extends StatefulWidget {
  const _VergelijkTab({required this.photos});

  final Map<String, List<PhotoItem>> photos;

  @override
  State<_VergelijkTab> createState() => _VergelijkTabState();
}

class _VergelijkTabState extends State<_VergelijkTab> {
  String? _left;
  String? _right;
  double _pos = 0.5;

  List<(String, String)> get _all => [
        for (final (key, label) in photoCategories)
          for (final (i, item) in (widget.photos[key] ?? const <PhotoItem>[])
              .indexed)
            (item.url, '$label #${i + 1}'),
      ];

  @override
  Widget build(BuildContext context) {
    final all = _all;
    _left ??= all.isNotEmpty ? all[0].$1 : null;
    _right ??= all.length > 1 ? all[1].$1 : null;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Vergelijk progressiefoto's",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.textP,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Kies twee progressiefoto's om ze naast elkaar te vergelijken. Verschuif de lijn in het midden om het verschil te zien.",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textS,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          if (all.length < 2)
            DashedRRectBorder(
              color: AppColors.border,
              radius: 16,
              strokeWidth: 1,
              child: Container(
                height: 320,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "Upload minstens twee progressiefoto's om te vergelijken.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textS,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _PhotoPicker(
                    label: 'LINKS',
                    value: _left,
                    options: all,
                    onChanged: (v) => setState(() => _left = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PhotoPicker(
                    label: 'RECHTS',
                    value: _right,
                    options: all,
                    onChanged: (v) => setState(() => _right = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  onHorizontalDragUpdate: (details) => setState(() {
                    _pos = (details.localPosition.dx / width).clamp(0.0, 1.0);
                  }),
                  onTapDown: (details) => setState(() {
                    _pos = (details.localPosition.dx / width).clamp(0.0, 1.0);
                  }),
                  child: Container(
                    height: 380,
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_right != null)
                          Image.network(_right!, fit: BoxFit.cover),
                        if (_left != null)
                          ClipRect(
                            clipper: _LeftClipper(fraction: _pos),
                            child:
                                Image.network(_left!, fit: BoxFit.cover),
                          ),
                        Positioned(
                          left: _pos * width - 1,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 2, color: AppColors.accent),
                        ),
                        Positioned(
                          left: _pos * width - 18,
                          top: 380 / 2 - 18,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.accent, width: 2),
                            ),
                            child: const Center(
                              child: Text(
                                '⇆',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _LeftClipper extends CustomClipper<Rect> {
  _LeftClipper({required this.fraction});

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_LeftClipper oldClipper) =>
      oldClipper.fraction != fraction;
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<(String, String)> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textS,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.any((o) => o.$1 == value) ? value : null,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textS, size: 18),
              style: const TextStyle(
                color: AppColors.textP,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              items: [
                for (final (src, label) in options)
                  DropdownMenuItem(
                    value: src,
                    child: Text(label, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/* ------------------------ Sheets ------------------------ */

class _AddMeasurementSheet extends StatefulWidget {
  const _AddMeasurementSheet({required this.onSave});

  final ValueChanged<Map<String, double>> onSave;

  @override
  State<_AddMeasurementSheet> createState() => _AddMeasurementSheetState();
}

class _AddMeasurementSheetState extends State<_AddMeasurementSheet> {
  final _controllers = {
    for (final m in measures) m.key: TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final parsed = <String, double>{};
    for (final e in _controllers.entries) {
      final n = double.tryParse(e.value.text.replaceAll(',', '.'));
      if (n != null && n.isFinite) parsed[e.key] = n;
    }
    widget.onSave(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final m in measures)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    m.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textP,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: _controllers[m.key],
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.textP,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle:
                          const TextStyle(color: AppColors.textM),
                      filled: true,
                      fillColor: AppColors.surface,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.accent),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 26,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      m.unit,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textS,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _save,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'Opslaan',
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

class _MeasureDetailBody extends StatelessWidget {
  const _MeasureDetailBody({required this.meta, required this.data});

  final MeasureMeta meta;
  final List<MeasurePoint> data;

  String _fmtNum(double n) =>
      n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toString();

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d-M-y');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LineChart(data: data, unit: meta.unit),
        const SizedBox(height: 16),
        if (data.isEmpty)
          const Text(
            'Geen metingen.',
            style: TextStyle(
              color: AppColors.textS,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        for (final d in data.reversed)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fmt.format(d.date.toLocal()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textS,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_fmtNum(d.value)} ${meta.unit}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textP,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
