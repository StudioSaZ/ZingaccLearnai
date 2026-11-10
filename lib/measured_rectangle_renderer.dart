import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'diagram_geometry.dart';

class MeasuredRectangleRenderer extends StatelessWidget {
  final double width;
  final double height;

  const MeasuredRectangleRenderer({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (!DiagramGeometry.positive(width) ||
        !DiagramGeometry.positive(height)) {
      return const SizedBox.shrink();
    }
    return AspectRatio(
      aspectRatio: 1.4,
      child: CustomPaint(
        painter: _MeasuredRectanglePainter(width, height),
      ),
    );
  }
}

class _MeasuredRectanglePainter extends CustomPainter {
  final double rectWidth;
  final double rectHeight;

  _MeasuredRectanglePainter(this.rectWidth, this.rectHeight);

  @override
  void paint(Canvas canvas, Size size) {
    // අර මගෑරිලා තිබුණු ගුණ කිරීමේ ලකුණු (*) 4ම මෙතන නිවැරදි කරලා තියෙනවා
    final availableWidth = size.width * 0.75;
    final availableHeight = size.height * 0.70;

    final scale = math.min(
      availableWidth / rectWidth,
      availableHeight / rectHeight,
    );

    final drawnWidth = rectWidth * scale;
    final drawnHeight = rectHeight * scale;

    final center = Offset(size.width / 2, size.height / 2);

    const gold = Color(0xFFD4AF37); // අපේ Luxury Gold පාට

    final paint = Paint()
      ..color = gold.withOpacity(0.8) // පරණ නිල් පාට වෙනුවට Gold
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: drawnWidth,
        height: drawnHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MeasuredRectanglePainter oldDelegate) =>
      oldDelegate.rectWidth != rectWidth ||
          oldDelegate.rectHeight != rectHeight;
}