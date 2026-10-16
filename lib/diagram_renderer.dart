import 'package:flutter/material.dart';

class DiagramRenderer extends StatelessWidget {
  const DiagramRenderer({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: CustomPaint(painter: _TrianglePainter()),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final a = Offset(size.width * 0.5, size.height * 0.1);
    final b = Offset(size.width * 0.12, size.height * 0.88);
    final c = Offset(size.width * 0.88, size.height * 0.88);
    final d = Offset(size.width * 0.5, size.height * 0.88);
    final line = Paint()..color = Colors.blue.shade700..strokeWidth = 2.5..style = PaintingStyle.stroke;
    final altitude = Paint()..color = Colors.green.shade700..strokeWidth = 2;
    canvas.drawPath(Path()..moveTo(a.dx,a.dy)..lineTo(b.dx,b.dy)..lineTo(c.dx,c.dy)..close(),line);
    canvas.drawLine(a,d,altitude);
    canvas.drawPath(Path()..moveTo(d.dx,d.dy-12)..lineTo(d.dx+12,d.dy-12)..lineTo(d.dx+12,d.dy),altitude);
    void label(String text, Offset point) {
      final painter = TextPainter(text: TextSpan(text:text,style:const TextStyle(color:Colors.black,fontSize:15,fontWeight:FontWeight.bold)),textDirection:TextDirection.ltr)..layout();
      painter.paint(canvas,point);
    }
    label('A',Offset(a.dx-5,a.dy-22));
    label('B',Offset(b.dx-18,b.dy));
    label('C',Offset(c.dx+5,c.dy));
    label('D',Offset(d.dx-5,d.dy+5));
    label('40°',Offset(a.dx-45,a.dy+38));
    label('40°',Offset(a.dx+13,a.dy+38));
    label('50°',Offset(b.dx+25,b.dy-27));
    label('50°',Offset(c.dx-58,c.dy-27));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
