import 'package:flutter/material.dart';
import 'diagram_model.dart';

class CircuitDiagramRenderer extends StatelessWidget {
  final CircuitDiagramData data;

  const CircuitDiagramRenderer({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);

    return Container(
      width: double.infinity,
      height: 220,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF112A20), // Dark Green Panel
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withOpacity(0.4)), // Gold Border
      ),
      child: CustomPaint(
        painter: _CircuitPainter(data),
      ),
    );
  }
}

class _CircuitPainter extends CustomPainter {
  final CircuitDiagramData data;

  _CircuitPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    const gold = Color(0xFFD4AF37);

    final wirePaint = Paint()
      ..color = gold.withOpacity(0.8) // Gold Wires
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final componentPaint = Paint()
      ..color = Colors.white // White Components
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;

    if (data.isParallel && data.resistors > 1) {
      // සමාන්තර පරිපථ සඳහා Short Circuit නොවන ලෙස වයර් රාමුව අඳිමු
      canvas.drawLine(const Offset(0, 0), Offset(0, height), wirePaint); // වම් රේඛාව
      canvas.drawLine(Offset(width, 0), Offset(width, height), wirePaint); // දකුණු රේඛාව
      canvas.drawLine(Offset(0, height), Offset(width, height), wirePaint); // යට රේඛාව
    } else {
      // ශ්‍රේණිගත පරිපථ සඳහා සම්පූර්ණ සෘජුකෝණාස්‍රය
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), wirePaint);
    }

    // 1. බැටරිය (කෝෂය) අඳිමු - යට පැත්තේ මැද
    _drawBattery(canvas, componentPaint, width / 2, height);

    // 2. ස්විචය අඳිමු - වම් පැත්තේ මැද
    if (data.hasSwitch) {
      _drawSwitch(canvas, componentPaint, 0, height / 2);
    }

    // 3. ප්‍රතිරෝධක (Resistors) අඳිමු
    _drawResistors(canvas, componentPaint, width, 0, data.resistors, data.isParallel, height, wirePaint);
  }

  void _drawBattery(Canvas canvas, Paint paint, double cx, double cy) {
    canvas.drawRect(Rect.fromLTRB(cx - 20, cy - 3, cx + 20, cy + 3), Paint()..color = const Color(0xFF112A20));
    canvas.drawLine(Offset(cx - 10, cy - 15), Offset(cx - 10, cy + 15), paint);
    canvas.drawLine(Offset(cx + 10, cy - 8), Offset(cx + 10, cy + 8), paint..strokeWidth = 5.0);
    paint.strokeWidth = 3.0;
  }

  void _drawSwitch(Canvas canvas, Paint paint, double cx, double cy) {
    canvas.drawRect(Rect.fromLTRB(cx - 3, cy - 20, cx + 3, cy + 20), Paint()..color = const Color(0xFF112A20));
    canvas.drawCircle(Offset(cx, cy - 12), 3, paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy + 12), 3, paint);
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, cy - 12), Offset(cx + 12, cy + 8), paint);
  }

  void _drawResistors(Canvas canvas, Paint paint, double width, double cy, int count, bool isParallel, double height, Paint wirePaint) {
    if (count <= 0) return;

    if (isParallel && count > 1) {
      // සමාන්තරගතව ප්‍රතිරෝධක අඳිමු (හිස් වයර් නොමැතිව)
      final double spacing = height / count;
      for (int i = 0; i < count; i++) {
        final double y = spacing * i;
        canvas.drawLine(Offset(0, y), Offset(width, y), wirePaint); // එක් එක් ශාඛාවට වයර් එකක්
        _drawZigZag(canvas, paint, width / 2, y);
      }
    } else {
      // ශ්‍රේණිගතව අඳිමු
      final double spacing = width / (count + 1);
      for (int i = 1; i <= count; i++) {
        _drawZigZag(canvas, paint, spacing * i, 0); // උඩම වයර් එකේ ශ්‍රේණිගතව
      }
    }
  }

  void _drawZigZag(Canvas canvas, Paint paint, double cx, double cy) {
    canvas.drawRect(Rect.fromLTRB(cx - 20, cy - 3, cx + 20, cy + 3), Paint()..color = const Color(0xFF112A20));
    final path = Path();
    path.moveTo(cx - 20, cy);
    path.lineTo(cx - 15, cy - 10);
    path.lineTo(cx - 5, cy + 10);
    path.lineTo(cx + 5, cy - 10);
    path.lineTo(cx + 15, cy + 10);
    path.lineTo(cx + 20, cy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}