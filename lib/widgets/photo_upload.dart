import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/theme/invert_filter.dart';
import '../app/theme/tokens.dart';

/// Port van archive/src/components/coacher/PhotoUpload.tsx —
/// cirkel met gestreepte rand, camera-icoon + "FOTO", toont preview na keuze.
class PhotoUpload extends StatefulWidget {
  const PhotoUpload({super.key, this.size = 84, this.onPicked});

  final double size;
  final ValueChanged<Uint8List>? onPicked;

  @override
  State<PhotoUpload> createState() => _PhotoUploadState();
}

class _PhotoUploadState extends State<PhotoUpload> {
  Uint8List? _bytes;

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _bytes = bytes);
    widget.onPicked?.call(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pick,
      child: CustomPaint(
        painter: DashedCirclePainter(
          color: _bytes != null ? AppColors.primary : AppColors.borderHover,
          strokeWidth: 2,
        ),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _bytes != null ? Colors.transparent : AppColors.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: _bytes != null
              ? MediaReInvert(
                  child: Image.memory(_bytes!, fit: BoxFit.cover))
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.camera, color: AppColors.primary, size: 22),
                    SizedBox(height: 4),
                    Text(
                      'FOTO',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashLength = 6,
    this.gapLength = 5,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final radius = size.shortestSide / 2 - strokeWidth / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * 3.141592653589793 * radius;
    final dashCount = (circumference / (dashLength + gapLength)).floor();
    final dashAngle = (dashLength / circumference) * 2 * 3.141592653589793;
    final gapAngle = (gapLength / circumference) * 2 * 3.141592653589793;

    var angle = -3.141592653589793 / 2;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        dashAngle,
        false,
        paint,
      );
      angle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
