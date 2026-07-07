import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/invert_filter.dart';
import '../../app/theme/tokens.dart';
import '../../data/models/role.dart';
import '../../widgets/anim/fade_up.dart';
import '../../widgets/anim/spinner.dart';
import '../../widgets/coacher_button.dart';
import '../../widgets/dashed_border.dart';
import '../../widgets/photo_upload.dart' show DashedCirclePainter;
import '../../widgets/shell.dart';

enum _Stage { intro, id, selfie, done }

/// Port van Verification.tsx — gesimuleerde ID-scan + selfie-check.
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({
    super.key,
    required this.role,
    required this.onSkip,
    required this.onDone,
  });

  final Role role;
  final VoidCallback onSkip;
  final VoidCallback onDone;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  _Stage _stage = _Stage.intro;

  void _next() {
    setState(() {
      _stage = switch (_stage) {
        _Stage.intro => _Stage.id,
        _Stage.id => _Stage.selfie,
        _Stage.selfie => _Stage.done,
        _Stage.done => _Stage.done,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Shell(
      child: FadeUp(
        child: switch (_stage) {
          _Stage.intro => _Intro(onStart: _next, onSkip: widget.onSkip),
          _Stage.id => _IdScan(onNext: _next),
          _Stage.selfie => _Selfie(onNext: _next),
          _Stage.done => _Done(onNext: widget.onDone),
        },
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, this.sub});

  final String title;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.textP,
              letterSpacing: -0.5,
            ),
          ),
          if (sub != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                sub!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onStart, required this.onSkip});

  final VoidCallback onStart;
  final VoidCallback onSkip;

  static const _steps = ['ID-bewijs scannen', 'Selfie maken — gezichtsherkenning'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(color: Color(0x6B2563EB), blurRadius: 40),
              ],
            ),
            child:
                const Icon(LucideIcons.shield, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Verificatie',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textP,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: SizedBox(
            width: 280,
            child: Text(
              'Veilig en snel — duurt 2 minuten.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        for (final (i, s) in _steps.indexed) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
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
                  child: Text(
                    s,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textP,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const Spacer(),
        const SizedBox(height: 32),
        CoacherButton(
          size: ButtonSize.lg,
          fullWidth: true,
          onPressed: onStart,
          child: const Text('Verificatie starten'),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onSkip,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Later doen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textS,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IdScan extends StatefulWidget {
  const _IdScan({required this.onNext});

  final VoidCallback onNext;

  @override
  State<_IdScan> createState() => _IdScanState();
}

class _IdScanState extends State<_IdScan> {
  Uint8List? _img;

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    ).catchError((_) async =>
        // Web/desktop zonder camera: val terug op galerij.
        ImagePicker().pickImage(source: ImageSource.gallery));
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted) setState(() => _img = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepHeader(
          title: 'ID scannen',
          sub: 'Stap 1 van 2 — paspoort of rijbewijs',
        ),
        GestureDetector(
          onTap: _pick,
          child: AspectRatio(
            aspectRatio: 1.6,
            child: DashedRRectBorder(
              color: _img != null ? AppColors.primary : AppColors.borderHover,
              radius: 18,
              strokeWidth: 2,
              child: Container(
              decoration: BoxDecoration(
                color: _img != null ? Colors.transparent : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: _img != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        MediaReInvert(
                            child: Image.memory(_img!, fit: BoxFit.cover)),
                        Container(
                          color: const Color(0x2E2563EB),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0x8C000000),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Tik om opnieuw te doen',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.camera,
                            color: AppColors.primary, size: 36),
                        SizedBox(height: 8),
                        Text(
                          'Tik om ID te fotograferen',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textP,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Achtercamera · zorg voor goed licht',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textS,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ),
        if (_img != null)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x4D2563EB)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.check, color: AppColors.primary, size: 14),
                SizedBox(width: 8),
                Text(
                  'ID gescand en gevalideerd',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        const Spacer(),
        const SizedBox(height: 32),
        CoacherButton(
          size: ButtonSize.lg,
          fullWidth: true,
          onPressed: _img != null ? widget.onNext : null,
          child: const Text('Doorgaan'),
        ),
      ],
    );
  }
}

class _Selfie extends StatefulWidget {
  const _Selfie({required this.onNext});

  final VoidCallback onNext;

  @override
  State<_Selfie> createState() => _SelfieState();
}

enum _SelfiePhase { idle, scanning, done }

class _SelfieState extends State<_Selfie> {
  Uint8List? _img;
  _SelfiePhase _phase = _SelfiePhase.idle;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    ).catchError((_) async =>
        ImagePicker().pickImage(source: ImageSource.gallery));
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted) {
      setState(() {
        _img = bytes;
        _phase = _SelfiePhase.idle;
      });
    }
  }

  void _verify() {
    setState(() => _phase = _SelfiePhase.scanning);
    _timer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _phase = _SelfiePhase.done);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepHeader(
          title: 'Selfie maken',
          sub: 'Stap 2 van 2 — gezichtsherkenning',
        ),
        Center(
          child: GestureDetector(
            onTap: _pick,
            child: CustomPaint(
              painter: DashedCirclePainter(
                color:
                    _img != null ? AppColors.primary : AppColors.borderHover,
                strokeWidth: 2,
              ),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _img != null ? Colors.transparent : AppColors.surface,
                ),
                clipBehavior: Clip.antiAlias,
                child: _img != null
                    ? MediaReInvert(
                        child: Image.memory(_img!, fit: BoxFit.cover))
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.user,
                              color: AppColors.primary, size: 38),
                          SizedBox(height: 8),
                          Text(
                            'SELFIE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        if (_phase == _SelfiePhase.scanning)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spinner(size: 14, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Gezichtsherkenning actief…',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textS,
                  ),
                ),
              ],
            ),
          ),
        if (_phase == _SelfiePhase.done)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overeenkomst',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textP,
                      ),
                    ),
                    Text(
                      '97%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 97,
                          child: Container(
                            decoration: const BoxDecoration(
                                gradient: AppGradients.primary),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(color: AppColors.border),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        const Spacer(),
        const SizedBox(height: 32),
        if (_phase != _SelfiePhase.done)
          CoacherButton(
            size: ButtonSize.lg,
            fullWidth: true,
            onPressed: _img != null && _phase != _SelfiePhase.scanning
                ? _verify
                : null,
            child: const Text('Gezicht verifiëren'),
          )
        else
          CoacherButton(
            size: ButtonSize.lg,
            fullWidth: true,
            onPressed: widget.onNext,
            child: const Text('Doorgaan'),
          ),
      ],
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return FadeUp(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
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
            child: const Icon(LucideIcons.check, color: Colors.white, size: 38),
          ),
          const SizedBox(height: 24),
          const Text(
            'Verificatie ingediend',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textP,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final label in const ['ID', 'Gezicht'])
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0x1F2563EB),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0x4D2563EB)),
                  ),
                  child: Text(
                    '$label ✓',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 40),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: CoacherButton(
              size: ButtonSize.lg,
              fullWidth: true,
              onPressed: onNext,
              child: const Text('Doorgaan →'),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
