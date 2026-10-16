import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/measured_circle_renderer.dart';

void main() {
  Widget screen(double radius) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 280,
          child: MeasuredCircleRenderer(radius: radius),
        ),
      ),
    ),
  );

  testWidgets('valid radius draws a circle', (tester) async {
    await tester.pumpWidget(screen(7));
    final drawing = find.descendant(
      of: find.byType(MeasuredCircleRenderer),
      matching: find.byType(CustomPaint),
    );
    expect(drawing, findsOneWidget);
    expect(drawing, paints..circle());
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid radius does not draw', (tester) async {
    await tester.pumpWidget(screen(-7));
    expect(find.byType(AspectRatio), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing radius updates widget data', (tester) async {
    await tester.pumpWidget(screen(7));
    await tester.pumpWidget(screen(14));
    final circle = tester.widget<MeasuredCircleRenderer>(
      find.byType(MeasuredCircleRenderer),
    );
    expect(circle.radius, 14);
    expect(tester.takeException(), isNull);
  });
}
