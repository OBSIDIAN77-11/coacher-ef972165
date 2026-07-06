import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// `.spinner`: ronddraaiende ring, 0.7s linear infinite.
/// Ring: 2.5px rgba(255,255,255,0.25) met witte bovenkant.
class Spinner extends StatefulWidget {
  const Spinner({
    super.key,
    this.size = 16,
    this.strokeWidth = 2.5,
    this.color = const Color(0xFFFFFFFF),
  });

  final double size;
  final double strokeWidth;
  final Color color;

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _SpinnerPainter(widget.strokeWidth, widget.color),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter(this.strokeWidth, this.color);

  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    paint.color = color.withValues(alpha: 0.25);
    canvas.drawArc(rect.deflate(strokeWidth / 2), 0, math.pi * 2, false, paint);

    paint.color = color;
    canvas.drawArc(
        rect.deflate(strokeWidth / 2), -math.pi / 2, math.pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
