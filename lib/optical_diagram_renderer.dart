import 'package:flutter/material.dart';
import 'diagram_model.dart';

class OpticalDiagramRenderer extends StatelessWidget {
  final OpticalDiagramData data;

  const OpticalDiagramRenderer({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101F43),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF365393)),
      ),
      child: CustomPaint(
        painter: _OpticsPainter(data),
      ),
    );
  }
}

class _OpticsPainter extends CustomPainter {
  final OpticalDiagramData data;
  _OpticsPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()..color = const Color(0xFF5A75A6)..strokeWidth = 1.5;
    final lensPaint = Paint()..color = const Color(0xFF70CFFF)..strokeWidth = 3.0..style = PaintingStyle.stroke;
    final objectPaint = Paint()..color = Colors.orangeAccent..strokeWidth = 3.0;
    final imagePaint = Paint()..color = Colors.greenAccent..strokeWidth = 3.0;
    final rayPaint = Paint()..color = Colors.yellowAccent.withOpacity(0.8)..strokeWidth = 1.5;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. ප්‍රධාන අක්ෂය (Principal Axis)
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), axisPaint);

    // 2. කාචය අඳිමු (Lens)
    canvas.drawLine(Offset(cx, 20), Offset(cx, size.height - 20), lensPaint);

    // උත්තල/අවතල ඊතල සලකුණු (Convex/Concave arrows)
    if (data.isConvex) {
      _drawArrow(canvas, Offset(cx, 20), Offset(cx, 10), lensPaint);
      _drawArrow(canvas, Offset(cx, size.height - 20), Offset(cx, size.height - 10), lensPaint);
    } else {
      _drawArrow(canvas, Offset(cx, 10), Offset(cx, 20), lensPaint);
      _drawArrow(canvas, Offset(cx, size.height - 10), Offset(cx, size.height - 20), lensPaint);
    }

    // දුර ගණනය කිරීම (කාච සූත්‍රය: 1/v = 1/f - 1/u)
    double scale = 3.0; // තිරයේ ප්‍රමාණයට ගැළපීමට පරිමාණයක්
    double u = data.objectDistance;
    double f = data.isConvex ? data.focalLength : -data.focalLength;

    // v (ප්‍රතිබිම්බ දුර) සෙවීම
    double v = (u == f) ? 1000 : (u * f) / (u - f);

    double objHeight = 35.0;
    double mag = v / (-u); // විශාලනය
    double imgHeight = objHeight * mag;

    double objX = cx - (u * scale);
    double imgX = cx + (v * scale);
    double fDist = data.focalLength * scale;

    // F සහ 2F අක්ෂය මත ලකුණු කිරීම
    _markPoint(canvas, cx + fDist, cy, 'F', axisPaint);
    _markPoint(canvas, cx - fDist, cy, 'F', axisPaint);
    _markPoint(canvas, cx + 2 * fDist, cy, '2F', axisPaint);
    _markPoint(canvas, cx - 2 * fDist, cy, '2F', axisPaint);
    _markPoint(canvas, cx, cy, 'O', axisPaint); // ප්‍රකාශ කේන්ද්‍රය

    // 3. වස්තුව අඳිමු (Object - තැඹිලි පාටින්)
    _drawArrow(canvas, Offset(objX, cy), Offset(objX, cy - objHeight), objectPaint);

    // 4. ප්‍රතිබිම්බය අඳිමු (Image - කොළ පාටින්)
    if (u != f) {
      _drawArrow(canvas, Offset(imgX, cy), Offset(imgX, cy - imgHeight), imagePaint);
    }

    // 5. ආලෝක කිරණ අඳිමු (Rays - කහ පාටින්)
    // Ray 1: ප්‍රධාන අක්ෂයට සමාන්තර කිරණය -> නාභිය (F) හරහා යයි
    canvas.drawLine(Offset(objX, cy - objHeight), Offset(cx, cy - objHeight), rayPaint);
    canvas.drawLine(Offset(cx, cy - objHeight), Offset(imgX, cy - imgHeight), rayPaint);

    // Ray 2: ප්‍රකාශ කේන්ද්‍රය (O) හරහා යන කිරණය
    canvas.drawLine(Offset(objX, cy - objHeight), Offset(imgX, cy - imgHeight), rayPaint);
  }

  void _markPoint(Canvas canvas, double x, double y, String label, Paint paint) {
    canvas.drawLine(Offset(x, y - 4), Offset(x, y + 4), paint);
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y + 6));
  }

  void _drawArrow(Canvas canvas, Offset base, Offset tip, Paint paint) {
    canvas.drawLine(base, tip, paint);
    final double d = 6.0;
    if (tip.dy < base.dy) { // ඊතලය උඩට
      canvas.drawLine(tip, Offset(tip.dx - d, tip.dy + d), paint);
      canvas.drawLine(tip, Offset(tip.dx + d, tip.dy + d), paint);
    } else { // ඊතලය පහළට
      canvas.drawLine(tip, Offset(tip.dx - d, tip.dy - d), paint);
      canvas.drawLine(tip, Offset(tip.dx + d, tip.dy - d), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}