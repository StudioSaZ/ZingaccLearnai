import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'universal_diagram_engine.dart';

class UniversalDiagramRenderer extends StatelessWidget {
  final DiagramSpecification data;
  const UniversalDiagramRenderer({super.key, required this.data});

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1.4,
    child: CustomPaint(painter: _DiagramPainter(data)),
  );
}

class _DiagramPainter extends CustomPainter {
  final DiagramSpecification data;
  _DiagramPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    const gold = Color(0xFFD4AF37); // Premium Gold

    final stroke = Paint()
      ..color = gold.withOpacity(0.8) // Gold Outline
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final accent = Paint()
      ..color = gold // Gold Accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    void line(Offset a, Offset b, [Paint? pen]) =>
        canvas.drawLine(a, b, pen ?? stroke);

    void polygon(List<Offset> points) {
      if (points.isEmpty) return;
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path..close(), stroke);
    }

    void label(String text, Offset at) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)), // White Labels
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, at);
    }

    double measure(String key, double fallback) {
      final value = data.measurements[key];
      return value != null && value.isFinite && value > 0
          ? value : fallback;
    }

    switch (data.shape) {
      case DiagramShape.triangle:
        polygon([Offset(w * .5, h * .14), Offset(w * .15, h * .82),
          Offset(w * .85, h * .82)]);
        break;
      case DiagramShape.square:
        final side = math.min(w * .65, h * .7);
        canvas.drawRect(Rect.fromCenter(center: center,
            width: side, height: side), stroke);
        break;
      case DiagramShape.rectangle:
        final ratio = measure('width', 4) / measure('height', 3);
        // කැඩිලා තිබුණු ගුණ කිරීමේ ලකුණ (*) මෙතන නිවැරදි කරලා තියෙනවා
        final rw = math.min(w * .75, h * .7 * ratio);

        final rh = rw / ratio;
        canvas.drawRect(Rect.fromCenter(center: center,
            width: rw, height: rh), stroke);
        break;
      case DiagramShape.parallelogram:
        polygon([Offset(w * .30, h * .2), Offset(w * .85, h * .2),
          Offset(w * .70, h * .8), Offset(w * .15, h * .8)]);
        break;
      case DiagramShape.trapezoid:
        polygon([Offset(w * .32, h * .2), Offset(w * .68, h * .2),
          Offset(w * .88, h * .8), Offset(w * .12, h * .8)]);
        break;
      case DiagramShape.circle:
        final radius = math.min(w * .35, h * .38);
        canvas.drawCircle(center, radius, stroke);
        line(center, center + Offset(radius, 0), accent);
        canvas.drawCircle(center, 2.5, Paint()..color = gold);
        break;
      case DiagramShape.coordinateGraph:
        line(Offset(w * .12, h * .5), Offset(w * .9, h * .5));
        line(Offset(w * .5, h * .9), Offset(w * .5, h * .1));
        label('x', Offset(w * .9, h * .5));
        label('y', Offset(w * .5, h * .06));
        label('0', Offset(w * .51, h * .51));
        break;
      case DiagramShape.forceDiagram:
        canvas.drawRect(Rect.fromCenter(center: center,
            width: w * .25, height: h * .25), stroke);
        void arrow(Offset from, Offset to, String text) {
          line(from, to, accent);
          // කැඩිලා තිබුණු අඩු කිරීමේ ලකුණු (-) මෙතන නිවැරදි කරලා තියෙනවා
          final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
          const a = .5;
          const len = 11.0;
          line(to, to - Offset(len * math.cos(angle - a),
              len * math.sin(angle - a)), accent);
          line(to, to - Offset(len * math.cos(angle + a),
              len * math.sin(angle + a)), accent);
          label(text, to + const Offset(5, -14));
        }
        arrow(center + Offset(w * .125, 0),
            center + Offset(w * .38, 0), data.labels['force'] ?? 'F');
        break;
      case DiagramShape.electricalCircuit:
      // Electrical Circuit සඳහා අගයක්
        break;
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _DiagramPainter oldDelegate) =>
      oldDelegate.data != data;
}