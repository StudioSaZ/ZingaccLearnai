import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'diagram_geometry.dart';

class MeasuredCircleRenderer extends StatelessWidget {
  final double radius;
  final String unit;

  const MeasuredCircleRenderer({
    super.key,
    required this.radius,
    this.unit = 'cm',
  });

  @override
  Widget build(BuildContext context) {
    if (!DiagramGeometry.positive(radius)) {
      return const SizedBox.shrink();
    }
    return AspectRatio(
      aspectRatio: 1.4,
      child: CustomPaint(
        painter: _MeasuredCirclePainter(radius, unit),
      ),
    );
  }
}

class _MeasuredCirclePainter extends CustomPainter {
  final double radius;
  final String unit;

  _MeasuredCirclePainter(this.radius, this.unit);

  @override
  void paint(Canvas canvas, Size size) {
    // අර කැඩිලා තිබුණු ගුණ කිරීමේ ලකුණු (*) මෙතන නිවැරදි කරලා තියෙනවා
    final center = Offset(size.width * 0.48, size.height * 0.5);
    final drawnRadius = math.min(size.width * 0.30, size.height * 0.36);

    const gold = Color(0xFFD4AF37); // අපේ Luxury Gold පාට

    final outline = Paint()
      ..color = gold.withOpacity(0.8) // පරණ නිල් පාට වෙනුවට Gold
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final radiusPaint = Paint()
      ..color = gold // පරණ තද කොළ පාට වෙනුවට Gold
      ..strokeWidth = 2;

    canvas.drawCircle(center, drawnRadius, outline);
    canvas.drawLine(center, center + Offset(drawnRadius, 0), radiusPaint);
    canvas.drawCircle(center, 4, Paint()..color = gold);

    final text = TextPainter(
      text: TextSpan(
        text: 'r = $radius $unit',
        style: const TextStyle(
            color: Colors.white, // කළු පාට අකුරු වෙනුවට සුදු පාට
            fontSize: 14,
            fontWeight: FontWeight.w600
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    text.paint(canvas, center + const Offset(8, -24));
  }

  @override
  bool shouldRepaint(covariant _MeasuredCirclePainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.unit != unit;
}