import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'diagram_model.dart';

class DynamicTriangleRenderer extends StatelessWidget {
  final TriangleDiagramData data;
  const DynamicTriangleRenderer({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (!data.hasValidAngles) return const SizedBox.shrink();
    return AspectRatio(
      aspectRatio: 1.4,
      child: CustomPaint(painter: _DynamicTrianglePainter(data)),
    );
  }
}

class _DynamicTrianglePainter extends CustomPainter {
  final TriangleDiagramData data;
  _DynamicTrianglePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final aRad = data.angleA! * math.pi / 180;
    final bRad = data.angleB! * math.pi / 180;
    final cRad = data.angleC! * math.pi / 180;
    final ab = math.sin(cRad);
    final ac = math.sin(bRad);
    final bx = ab * math.cos(aRad);
    final by = ab * math.sin(aRad);
    final cx = ac;
    final minX = math.min(0.0, math.min(bx, cx));
    final maxX = math.max(0.0, math.max(bx, cx));
    final scale = math.min(size.width * 0.72 / (maxX - minX), size.height * 0.60 / by);
    final origin = Offset(size.width * 0.5 - (minX + maxX) * scale / 2, size.height * 0.22);
    final a = origin;
    final b = Offset(origin.dx + bx * scale, origin.dy + by * scale);
    final c = Offset(origin.dx + cx * scale, origin.dy);
    final paint = Paint()..color = Colors.blue.shade700..strokeWidth = 2.5..style = PaintingStyle.stroke;
    canvas.drawPath(Path()..moveTo(a.dx,a.dy)..lineTo(b.dx,b.dy)..lineTo(c.dx,c.dy)..close(),paint);
    void label(String value, Offset point, {bool bold = false}) {
      final tp = TextPainter(text: TextSpan(text:value,style:TextStyle(color:Colors.black,fontSize:14,fontWeight:bold ? FontWeight.bold : FontWeight.normal)),textDirection:TextDirection.ltr)..layout();
      tp.paint(canvas,point);
    }
    Offset inward(Offset vertex, Offset p, Offset q, double distance) {
      final u = p - vertex;
      final v = q - vertex;
      final direction = u / u.distance + v / v.distance;
      return vertex + direction / direction.distance * distance;
    }
    label(data.vertexA, a + const Offset(-18,-22), bold:true);
    label(data.vertexB, b + const Offset(-8,8), bold:true);
    label(data.vertexC, c + const Offset(8,-22), bold:true);
    label('${data.angleA!.toStringAsFixed(0)}°', inward(a,b,c,34));
    label('${data.angleB!.toStringAsFixed(0)}°', inward(b,a,c,34));
    label('${data.angleC!.toStringAsFixed(0)}°', inward(c,a,b,34));
    // Angles validated before painting.
    assert((aRad + bRad + cRad - math.pi).abs() < 0.001);
  }

  @override
  bool shouldRepaint(covariant _DynamicTrianglePainter oldDelegate) => oldDelegate.data != data;
}
